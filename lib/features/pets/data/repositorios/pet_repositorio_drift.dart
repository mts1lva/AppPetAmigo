import 'package:drift/drift.dart';

import '../../../../core/banco/daos/config_dao.dart';
import '../../../../core/banco/database.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../domain/entidades/pet.dart';
import '../../domain/repositorios/pet_repositorio.dart';

/// Implementação drift do [PetRepositorio]: o **exemplo de referência** de
/// repositório para os outros pacotes (`dados-e-sync.md` → Contrato da fila).
///
/// Cada gravação é uma transação que:
/// 1. grava com `versao + 1`, `atualizadoEm` e o `estadoSync` da fila;
/// 2. chama `fila.enfileirar` para cada registro alterado;
/// 3. nunca apaga de verdade: exclusão vira lápide (`excluido = true`).
final class PetRepositorioDrift implements PetRepositorio {
  PetRepositorioDrift(this._banco, this._fila, {required this.novoId});

  final BancoLocal _banco;
  final FilaSync _fila;
  /// Gera IDs estáveis (UUID v4).
  final String Function() novoId;

  /// Tabelas com `petId`, que a exclusão do pet leva junto (lápide). Os nomes
  /// das tabelas no SQLite são iguais aos das coleções.
  static const _tabelasDoPet = [
    ColecoesSync.alimentos,
    ColecoesSync.refeicoes,
    ColecoesSync.extras,
    ColecoesSync.atividades,
    ColecoesSync.lembretes,
    ColecoesSync.pesagens,
    ColecoesSync.referencias,
  ];

  /// Ordem de cadastro; `rowid` desempata pets criados no mesmo segundo.
  static List<OrderingTerm Function($PetsTable)> get _ordemDeCadastro => [
        (p) => OrderingTerm.asc(p.criadoEm),
        (p) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
      ];

  SimpleSelectStatement<$PetsTable, PetLinha> _petsAtivos() =>
      _banco.select(_banco.pets)..where((p) => p.excluido.equals(false));

  SimpleSelectStatement<$PesagensTable, PesagemLinha> _primeiraPesagem(String petId) =>
      _banco.select(_banco.pesagens)
        ..where((p) => p.petId.equals(petId) & p.excluido.equals(false))
        ..orderBy([(p) => OrderingTerm.asc(p.dataHora), (p) => OrderingTerm.asc(p.criadoEm)])
        ..limit(1);

  @override
  Stream<List<Pet>> observarTodos() =>
      (_petsAtivos()..orderBy(_ordemDeCadastro)).watch().map((linhas) => linhas.map(_paraEntidade).toList());

  @override
  Stream<Pet?> observar(String id) => (_petsAtivos()..where((p) => p.id.equals(id)))
      .watchSingleOrNull()
      .map((linha) => linha == null ? null : _paraEntidade(linha));

  @override
  Stream<double?> observarPesoInicial(String petId) =>
      _primeiraPesagem(petId).watchSingleOrNull().map((linha) => linha?.pesoKg);

  @override
  Future<void> cadastrar(Pet pet, {required double pesoInicialKg, required DateTime agora}) {
    return _banco.transaction(() async {
      final estado = (await _fila.estadoInicial()).name;
      await _banco.into(_banco.pets).insert(PetsCompanion.insert(
            id: pet.id,
            criadoEm: agora,
            atualizadoEm: agora,
            estadoSync: Value(estado),
            nome: pet.nome,
            especie: pet.especie.name,
            sexo: pet.sexo.name,
            idadeMeses: pet.idadeMeses,
            idadeInformadaEm: pet.idadeInformadaEm,
            castrado: pet.castrado,
            nivelAtividade: pet.nivelAtividade.name,
            fotoArquivo: Value(pet.fotoArquivo),
          ));
      await _fila.enfileirar(ColecoesSync.pets, pet.id, OperacaoSync.upsert);

      // A primeira pesagem é o peso inicial (U2-06), gravada aqui, sem depender
      // do código do P4.
      final pesagemId = novoId();
      await _banco.into(_banco.pesagens).insert(PesagensCompanion.insert(
            id: pesagemId,
            criadoEm: agora,
            atualizadoEm: agora,
            estadoSync: Value(estado),
            petId: pet.id,
            pesoKg: pesoInicialKg,
            dataHora: agora,
          ));
      await _fila.enfileirar(ColecoesSync.pesagens, pesagemId, OperacaoSync.upsert);

      // Cadastrar um pet sempre o torna o atual (U2-10).
      await _banco.configDao.gravar(ChavesConfig.petAtualId, pet.id);
    });
  }

  @override
  Future<void> editar(Pet pet, {double? pesoInicialKg, required DateTime agora}) {
    return _banco.transaction(() async {
      final atual = await (_petsAtivos()..where((p) => p.id.equals(pet.id))).getSingleOrNull();
      if (atual == null) throw StateError('Pet não encontrado: ${pet.id}');
      final estado = (await _fila.estadoInicial()).name;

      await (_banco.update(_banco.pets)..where((p) => p.id.equals(pet.id))).write(PetsCompanion(
        nome: Value(pet.nome),
        especie: Value(pet.especie.name),
        sexo: Value(pet.sexo.name),
        idadeMeses: Value(pet.idadeMeses),
        idadeInformadaEm: Value(pet.idadeInformadaEm),
        castrado: Value(pet.castrado),
        nivelAtividade: Value(pet.nivelAtividade.name),
        fotoArquivo: Value(pet.fotoArquivo),
        versao: Value(atual.versao + 1),
        atualizadoEm: Value(agora),
        estadoSync: Value(estado),
      ));
      await _fila.enfileirar(ColecoesSync.pets, pet.id, OperacaoSync.upsert);

      if (pesoInicialKg != null) {
        final primeira = await _primeiraPesagem(pet.id).getSingleOrNull();
        if (primeira == null) {
          final pesagemId = novoId();
          await _banco.into(_banco.pesagens).insert(PesagensCompanion.insert(
                id: pesagemId,
                criadoEm: agora,
                atualizadoEm: agora,
                estadoSync: Value(estado),
                petId: pet.id,
                pesoKg: pesoInicialKg,
                dataHora: agora,
              ));
          await _fila.enfileirar(ColecoesSync.pesagens, pesagemId, OperacaoSync.upsert);
        } else {
          await (_banco.update(_banco.pesagens)..where((p) => p.id.equals(primeira.id))).write(PesagensCompanion(
            pesoKg: Value(pesoInicialKg),
            versao: Value(primeira.versao + 1),
            atualizadoEm: Value(agora),
            estadoSync: Value(estado),
          ));
          await _fila.enfileirar(ColecoesSync.pesagens, primeira.id, OperacaoSync.upsert);
        }
      }
    });
  }

  @override
  Future<void> excluir(String id, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual = await (_petsAtivos()..where((p) => p.id.equals(id))).getSingleOrNull();
      if (atual == null) return;
      final estado = (await _fila.estadoInicial()).name;

      await (_banco.update(_banco.pets)..where((p) => p.id.equals(id))).write(PetsCompanion(
        excluido: const Value(true),
        versao: Value(atual.versao + 1),
        atualizadoEm: Value(agora),
        estadoSync: Value(estado),
      ));
      await _fila.enfileirar(ColecoesSync.pets, id, OperacaoSync.excluir);

      for (final tabela in _tabelasDoPet) {
        final info = _banco.allTables.firstWhere((t) => t.actualTableName == tabela);
        final ids = await _banco
            .customSelect(
              'SELECT id FROM $tabela WHERE pet_id = ? AND excluido = 0',
              variables: [Variable.withString(id)],
              readsFrom: {info},
            )
            .map((linha) => linha.read<String>('id'))
            .get();
        if (ids.isEmpty) continue;
        await _banco.customUpdate(
          'UPDATE $tabela SET excluido = 1, versao = versao + 1, atualizado_em = ?, estado_sync = ? '
          'WHERE pet_id = ? AND excluido = 0',
          variables: [Variable<DateTime>(agora), Variable.withString(estado), Variable.withString(id)],
          updates: {info},
          updateKind: UpdateKind.update,
        );
        for (final registroId in ids) {
          await _fila.enfileirar(tabela, registroId, OperacaoSync.excluir);
        }
      }

      // Excluir o pet atual passa para o primeiro da lista; sem pets, o app
      // volta ao 26 (navegacao.md → Estados que trocam a tela inteira).
      if (await _banco.configDao.ler(ChavesConfig.petAtualId) == id) {
        final primeiro = await (_petsAtivos()
              ..orderBy(_ordemDeCadastro)
              ..limit(1))
            .getSingleOrNull();
        await _banco.configDao.gravar(ChavesConfig.petAtualId, primeiro?.id);
      }
    });
  }

  static Pet _paraEntidade(PetLinha l) => Pet(
        id: l.id,
        nome: l.nome,
        especie: Especie.values.byName(l.especie),
        sexo: Sexo.values.byName(l.sexo),
        idadeMeses: l.idadeMeses,
        idadeInformadaEm: l.idadeInformadaEm,
        castrado: l.castrado,
        nivelAtividade: NivelAtividade.values.byName(l.nivelAtividade),
        fotoArquivo: l.fotoArquivo,
      );
}
