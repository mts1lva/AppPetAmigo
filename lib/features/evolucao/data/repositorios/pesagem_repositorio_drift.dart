import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../domain/entidades/pesagem.dart';
import '../../domain/repositorios/pesagem_repositorio.dart';

/// Implementação drift do [PesagemRepositorio], no padrão do
/// `PetRepositorioDrift`: cada gravação é uma transação que grava com
/// `versao + 1` e o `estadoSync` da fila e chama `fila.enfileirar`.
final class PesagemRepositorioDrift implements PesagemRepositorio {
  const PesagemRepositorioDrift(this._banco, this._fila);

  final BancoLocal _banco;
  final FilaSync _fila;

  SimpleSelectStatement<$PesagensTable, PesagemLinha> _doPet(String petId) =>
      _banco.select(_banco.pesagens)..where((p) => p.petId.equals(petId) & p.excluido.equals(false));

  @override
  Stream<Pesagem?> observarUltima(String petId) {
    final consulta = _doPet(petId)
      ..orderBy([(p) => OrderingTerm.desc(p.dataHora), (p) => OrderingTerm.desc(p.criadoEm)])
      ..limit(1);
    return consulta.watchSingleOrNull().map((linha) => linha == null ? null : _paraEntidade(linha));
  }

  @override
  Stream<List<Pesagem>> observarTodas(String petId) {
    final consulta = _doPet(petId)
      ..orderBy([(p) => OrderingTerm.asc(p.dataHora), (p) => OrderingTerm.asc(p.criadoEm)]);
    return consulta.watch().map((linhas) => linhas.map(_paraEntidade).toList());
  }

  @override
  Future<void> salvar(Pesagem pesagem, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual = await (_banco.select(_banco.pesagens)..where((p) => p.id.equals(pesagem.id))).getSingleOrNull();
      final estado = (await _fila.estadoInicial()).name;

      if (atual == null) {
        await _banco.into(_banco.pesagens).insert(PesagensCompanion.insert(
              id: pesagem.id,
              criadoEm: agora,
              atualizadoEm: agora,
              estadoSync: Value(estado),
              petId: pesagem.petId,
              pesoKg: pesagem.pesoKg,
              dataHora: pesagem.dataHora,
              conferida: Value(pesagem.conferida),
            ));
      } else {
        if (atual.excluido) throw StateError('Pesagem excluída: ${pesagem.id}');
        await (_banco.update(_banco.pesagens)..where((p) => p.id.equals(pesagem.id))).write(PesagensCompanion(
          pesoKg: Value(pesagem.pesoKg),
          dataHora: Value(pesagem.dataHora),
          conferida: Value(pesagem.conferida),
          versao: Value(atual.versao + 1),
          atualizadoEm: Value(agora),
          estadoSync: Value(estado),
        ));
      }
      await _fila.enfileirar(ColecoesSync.pesagens, pesagem.id, OperacaoSync.upsert);
    });
  }

  @override
  Future<void> excluir(String id, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual = await (_banco.select(_banco.pesagens)
            ..where((p) => p.id.equals(id) & p.excluido.equals(false)))
          .getSingleOrNull();
      if (atual == null) return;
      final estado = (await _fila.estadoInicial()).name;
      await (_banco.update(_banco.pesagens)..where((p) => p.id.equals(id))).write(PesagensCompanion(
        excluido: const Value(true),
        versao: Value(atual.versao + 1),
        atualizadoEm: Value(agora),
        estadoSync: Value(estado),
      ));
      await _fila.enfileirar(ColecoesSync.pesagens, id, OperacaoSync.excluir);
    });
  }

  static Pesagem _paraEntidade(PesagemLinha l) =>
      Pesagem(id: l.id, petId: l.petId, pesoKg: l.pesoKg, dataHora: l.dataHora, conferida: l.conferida);
}
