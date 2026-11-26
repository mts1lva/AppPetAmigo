import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../domain/entidades/alimento_cadastrado.dart';
import '../../domain/entidades/petisco.dart';
import '../../domain/repositorios/petisco_repositorio.dart';

/// Petiscos cadastrados no drift (P-32): linhas `tipo = petisco` da tabela
/// `alimentos`, com a mesma fila e o mesmo arquivamento das rações.
final class PetiscoRepositorioDrift implements PetiscoRepositorio {
  PetiscoRepositorioDrift(this._banco, this._fila);

  final BancoLocal _banco;
  final FilaSync _fila;

  @override
  Stream<List<Petisco>> observarDoPet(String petId) => (_banco.select(_banco.alimentos)
        ..where((a) =>
            a.petId.equals(petId) &
            a.tipo.equals(tipoPetisco) &
            a.excluido.equals(false) &
            a.arquivado.equals(false))
        ..orderBy([
          (a) => OrderingTerm.desc(a.criadoEm),
          (a) => OrderingTerm.desc(const CustomExpression<int>('rowid')),
        ]))
      .watch()
      .map((linhas) => linhas.map(_paraEntidade).toList());

  @override
  Future<void> salvar(Petisco petisco, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual =
          await (_banco.select(_banco.alimentos)..where((a) => a.id.equals(petisco.id))).getSingleOrNull();
      final estado = (await _fila.estadoInicial()).name;
      if (atual == null) {
        await _banco.into(_banco.alimentos).insert(AlimentosCompanion.insert(
              id: petisco.id,
              criadoEm: agora,
              atualizadoEm: agora,
              estadoSync: Value(estado),
              petId: petisco.petId,
              nome: petisco.nome,
              tipo: const Value(tipoPetisco),
              kcalPorUnidade: Value(petisco.kcalPorUnidade),
              unidadesHabituais: Value(petisco.unidadesHabituais),
              arquivado: Value(petisco.arquivado),
            ));
      } else {
        await (_banco.update(_banco.alimentos)..where((a) => a.id.equals(petisco.id))).write(AlimentosCompanion(
          nome: Value(petisco.nome),
          kcalPorUnidade: Value(petisco.kcalPorUnidade),
          unidadesHabituais: Value(petisco.unidadesHabituais),
          arquivado: Value(petisco.arquivado),
          versao: Value(atual.versao + 1),
          atualizadoEm: Value(agora),
          estadoSync: Value(estado),
        ));
      }
      await _fila.enfileirar(ColecoesSync.alimentos, petisco.id, OperacaoSync.upsert);
    });
  }

  @override
  Future<void> arquivar(String id, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual = await (_banco.select(_banco.alimentos)
            ..where((a) => a.id.equals(id) & a.tipo.equals(tipoPetisco) & a.excluido.equals(false)))
          .getSingleOrNull();
      if (atual == null || atual.arquivado) return;
      final estado = (await _fila.estadoInicial()).name;
      await (_banco.update(_banco.alimentos)..where((a) => a.id.equals(id))).write(AlimentosCompanion(
        arquivado: const Value(true),
        versao: Value(atual.versao + 1),
        atualizadoEm: Value(agora),
        estadoSync: Value(estado),
      ));
      await _fila.enfileirar(ColecoesSync.alimentos, id, OperacaoSync.upsert);
    });
  }

  /// Só recebe linhas `tipo = petisco`, que sempre têm os campos por unidade.
  static Petisco _paraEntidade(AlimentoLinha l) => Petisco(
        id: l.id,
        petId: l.petId,
        nome: l.nome,
        kcalPorUnidade: l.kcalPorUnidade!,
        unidadesHabituais: l.unidadesHabituais!,
        arquivado: l.arquivado,
      );
}
