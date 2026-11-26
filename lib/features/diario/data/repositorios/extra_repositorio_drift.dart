import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../domain/entidades/extra.dart';
import '../../domain/periodo.dart';
import '../../domain/repositorios/extra_repositorio.dart';

/// Extras no drift: gravação atômica com a fila; exclusão vira lápide.
final class ExtraRepositorioDrift implements ExtraRepositorio {
  ExtraRepositorioDrift(this._banco, this._fila);

  final BancoLocal _banco;
  final FilaSync _fila;

  Expression<bool> _ativosDoPet($ExtrasTable e, String petId) =>
      e.petId.equals(petId) & e.excluido.equals(false);

  List<OrderingTerm Function($ExtrasTable)> get _porHorario => [
        (e) => OrderingTerm.asc(e.dataHora),
        (e) => OrderingTerm.asc(e.criadoEm),
      ];

  List<OrderingTerm Function($ExtrasTable)> get _maisRecente => [
        (e) => OrderingTerm.desc(e.dataHora),
        (e) => OrderingTerm.desc(e.criadoEm),
      ];

  @override
  Stream<List<Extra>> observarEntre(String petId, DateTime inicio, DateTime fim) =>
      (_banco.select(_banco.extras)
            ..where((e) =>
                _ativosDoPet(e, petId) & e.dataHora.isBiggerOrEqualValue(inicio) & e.dataHora.isSmallerThanValue(fim))
            ..orderBy(_porHorario))
          .watch()
          .map((linhas) => linhas.map(_paraEntidade).toList());

  @override
  Stream<Extra?> observar(String id) => (_banco.select(_banco.extras)
        ..where((e) => e.id.equals(id) & e.excluido.equals(false)))
      .watchSingleOrNull()
      .map((linha) => linha == null ? null : _paraEntidade(linha));

  @override
  Stream<Extra?> observarMaisRecenteDoDia(String petId, DateTime dia) {
    final inicio = diaDe(dia);
    final fim = somarDias(inicio, 1);
    return (_banco.select(_banco.extras)
          ..where((e) =>
              _ativosDoPet(e, petId) & e.dataHora.isBiggerOrEqualValue(inicio) & e.dataHora.isSmallerThanValue(fim))
          ..orderBy(_maisRecente)
          ..limit(1))
        .watchSingleOrNull()
        .map((linha) => linha == null ? null : _paraEntidade(linha));
  }

  @override
  Future<void> salvar(Extra extra, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual = await (_banco.select(_banco.extras)..where((e) => e.id.equals(extra.id))).getSingleOrNull();
      final estado = (await _fila.estadoInicial()).name;
      if (atual == null) {
        await _banco.into(_banco.extras).insert(ExtrasCompanion.insert(
              id: extra.id,
              criadoEm: agora,
              atualizadoEm: agora,
              estadoSync: Value(estado),
              petId: extra.petId,
              descricao: extra.descricao,
              quantidadeG: Value(extra.quantidadeG),
              alimentoId: Value(extra.alimentoId),
              unidades: Value(extra.unidades),
              energiaKcal: extra.energiaKcal,
              dataHora: extra.dataHora,
            ));
      } else {
        await (_banco.update(_banco.extras)..where((e) => e.id.equals(extra.id))).write(ExtrasCompanion(
          descricao: Value(extra.descricao),
          quantidadeG: Value(extra.quantidadeG),
          alimentoId: Value(extra.alimentoId),
          unidades: Value(extra.unidades),
          energiaKcal: Value(extra.energiaKcal),
          dataHora: Value(extra.dataHora),
          versao: Value(atual.versao + 1),
          atualizadoEm: Value(agora),
          estadoSync: Value(estado),
        ));
      }
      await _fila.enfileirar(ColecoesSync.extras, extra.id, OperacaoSync.upsert);
    });
  }

  @override
  Future<void> excluir(String id, {required DateTime agora}) {
    return _banco.transaction(() async {
      final atual = await (_banco.select(_banco.extras)
            ..where((e) => e.id.equals(id) & e.excluido.equals(false)))
          .getSingleOrNull();
      if (atual == null) return;
      final estado = (await _fila.estadoInicial()).name;
      await (_banco.update(_banco.extras)..where((e) => e.id.equals(id))).write(ExtrasCompanion(
        excluido: const Value(true),
        versao: Value(atual.versao + 1),
        atualizadoEm: Value(agora),
        estadoSync: Value(estado),
      ));
      await _fila.enfileirar(ColecoesSync.extras, id, OperacaoSync.excluir);
    });
  }

  static Extra _paraEntidade(ExtraLinha l) => Extra(
        id: l.id,
        petId: l.petId,
        descricao: l.descricao,
        quantidadeG: l.quantidadeG,
        alimentoId: l.alimentoId,
        unidades: l.unidades,
        energiaKcal: l.energiaKcal,
        dataHora: l.dataHora,
      );
}
