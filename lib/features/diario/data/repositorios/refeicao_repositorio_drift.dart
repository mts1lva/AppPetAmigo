import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../domain/entidades/refeicao.dart';
import '../../domain/periodo.dart';
import '../../domain/repositorios/refeicao_repositorio.dart';

/// Refeições no drift: gravação atômica com a fila; exclusão vira lápide.
final class RefeicaoRepositorioDrift implements RefeicaoRepositorio {
  RefeicaoRepositorioDrift(this._banco, this._fila);

  final BancoLocal _banco;
  final FilaSync _fila;

  Expression<bool> _ativasDoPet($RefeicoesTable r, String petId) =>
      r.petId.equals(petId) & r.excluido.equals(false);

  List<OrderingTerm Function($RefeicoesTable)> get _porHorario => [
        (r) => OrderingTerm.asc(r.dataHora),
        (r) => OrderingTerm.asc(r.criadoEm),
      ];

  List<OrderingTerm Function($RefeicoesTable)> get _maisRecente => [
        (r) => OrderingTerm.desc(r.dataHora),
        (r) => OrderingTerm.desc(r.criadoEm),
      ];

  @override
  Stream<List<Refeicao>> observarEntre(String petId, DateTime inicio, DateTime fim) =>
      (_banco.select(_banco.refeicoes)
            ..where((r) =>
                _ativasDoPet(r, petId) & r.dataHora.isBiggerOrEqualValue(inicio) & r.dataHora.isSmallerThanValue(fim))
            ..orderBy(_porHorario))
          .watch()
          .map((linhas) => linhas.map(_paraEntidade).toList());

  @override
  Stream<Refeicao?> observar(String id) => (_banco.select(_banco.refeicoes)
        ..where((r) => r.id.equals(id) & r.excluido.equals(false)))
      .watchSingleOrNull()
      .map((linha) => linha == null ? null : _paraEntidade(linha));

  @override
  Stream<Refeicao?> observarMaisRecente(String petId) => (_banco.select(_banco.refeicoes)
        ..where((r) => _ativasDoPet(r, petId))
        ..orderBy(_maisRecente)
        ..limit(1))
      .watchSingleOrNull()
      .map((linha) => linha == null ? null : _paraEntidade(linha));

  @override
  Stream<Refeicao?> observarMaisRecenteDoDia(String petId, DateTime dia) {
    final inicio = diaDe(dia);
    final fim = inicio.add(const Duration(days: 1));
    return (_banco.select(_banco.refeicoes)
          ..where((r) =>
              _ativasDoPet(r, petId) & r.dataHora.isBiggerOrEqualValue(inicio) & r.dataHora.isSmallerThanValue(fim))
          ..orderBy(_maisRecente)
          ..limit(1))
        .watchSingleOrNull()
        .map((linha) => linha == null ? null : _paraEntidade(linha));
  }

  @override
  Future<void> salvar(Refeicao refeicao, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual =
          await (_banco.select(_banco.refeicoes)..where((r) => r.id.equals(refeicao.id))).getSingleOrNull();
      final estado = (await _fila.estadoInicial()).name;
      if (atual == null) {
        await _banco.into(_banco.refeicoes).insert(RefeicoesCompanion.insert(
              id: refeicao.id,
              criadoEm: agora,
              atualizadoEm: agora,
              estadoSync: Value(estado),
              petId: refeicao.petId,
              alimentoId: Value(refeicao.alimentoId),
              alimentoNome: refeicao.alimentoNome,
              densidadeKcalPor100g: refeicao.densidadeKcalPor100g,
              quantidadeG: refeicao.quantidadeG,
              energiaKcal: refeicao.energiaKcal,
              dataHora: refeicao.dataHora,
            ));
      } else {
        await (_banco.update(_banco.refeicoes)..where((r) => r.id.equals(refeicao.id))).write(RefeicoesCompanion(
          alimentoId: Value(refeicao.alimentoId),
          alimentoNome: Value(refeicao.alimentoNome),
          densidadeKcalPor100g: Value(refeicao.densidadeKcalPor100g),
          quantidadeG: Value(refeicao.quantidadeG),
          energiaKcal: Value(refeicao.energiaKcal),
          dataHora: Value(refeicao.dataHora),
          versao: Value(atual.versao + 1),
          atualizadoEm: Value(agora),
          estadoSync: Value(estado),
        ));
      }
      await _fila.enfileirar(ColecoesSync.refeicoes, refeicao.id, OperacaoSync.upsert);
    });
  }

  @override
  Future<void> excluir(String id, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual = await (_banco.select(_banco.refeicoes)
            ..where((r) => r.id.equals(id) & r.excluido.equals(false)))
          .getSingleOrNull();
      if (atual == null) return;
      final estado = (await _fila.estadoInicial()).name;
      await (_banco.update(_banco.refeicoes)..where((r) => r.id.equals(id))).write(RefeicoesCompanion(
        excluido: const Value(true),
        versao: Value(atual.versao + 1),
        atualizadoEm: Value(agora),
        estadoSync: Value(estado),
      ));
      await _fila.enfileirar(ColecoesSync.refeicoes, id, OperacaoSync.excluir);
    });
  }

  static Refeicao _paraEntidade(RefeicaoLinha l) => Refeicao(
        id: l.id,
        petId: l.petId,
        alimentoId: l.alimentoId,
        alimentoNome: l.alimentoNome,
        densidadeKcalPor100g: l.densidadeKcalPor100g,
        quantidadeG: l.quantidadeG,
        energiaKcal: l.energiaKcal,
        dataHora: l.dataHora,
      );
}
