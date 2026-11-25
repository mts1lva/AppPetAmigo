import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../domain/entidades/atividade.dart';
import '../../domain/repositorios/atividade_repositorio.dart';

final class AtividadeRepositorioDrift implements AtividadeRepositorio {
  const AtividadeRepositorioDrift(this._banco, this._fila);
  final BancoLocal _banco;
  final FilaSync _fila;

  @override
  Stream<List<Atividade>> observar(
    String petId, {
    required DateTime inicio,
    required DateTime fim,
  }) =>
      (_banco.select(_banco.atividades)
            ..where(
              (a) =>
                  a.petId.equals(petId) &
                  a.excluido.equals(false) &
                  a.dataHora.isBiggerOrEqualValue(inicio) &
                  a.dataHora.isSmallerThanValue(fim),
            )
            ..orderBy([
              (a) => OrderingTerm.asc(a.dataHora),
              (a) => OrderingTerm.asc(a.id),
            ]))
          .watch()
          .map((linhas) => linhas.map(_entidade).toList());

  @override
  Future<void> salvar(
    Atividade a, {
    required DateTime agora,
  }) => _banco.transaction(() async {
    if (validarAtividade(a, agora).isNotEmpty) {
      throw ArgumentError('Atividade inválida.');
    }
    final pet =
        await (_banco.select(_banco.pets)
              ..where((p) => p.id.equals(a.petId) & p.excluido.equals(false)))
            .getSingleOrNull();
    if (pet == null) throw StateError('Pet indisponível.');
    final anterior = await (_banco.select(
      _banco.atividades,
    )..where((r) => r.id.equals(a.id))).getSingleOrNull();
    if (anterior != null && (anterior.petId != a.petId || anterior.excluido)) {
      throw StateError('Registro indisponível.');
    }
    final estado = (await _fila.estadoInicial()).name;
    await _banco
        .into(_banco.atividades)
        .insertOnConflictUpdate(
          AtividadesCompanion.insert(
            id: a.id,
            petId: a.petId,
            criadoEm: anterior?.criadoEm ?? agora,
            atualizadoEm: agora,
            tipo: a.tipo.name,
            duracaoMin: a.duracaoMin,
            dataHora: a.dataHora,
            versao: Value((anterior?.versao ?? 0) + 1),
            estadoSync: Value(estado),
            versaoRemota: Value(anterior?.versaoRemota),
          ),
        );
    await _fila.enfileirar(ColecoesSync.atividades, a.id, OperacaoSync.upsert);
  });

  @override
  Future<void> excluir(
    String petId,
    String id, {
    required DateTime agora,
  }) => _banco.transaction(() async {
    final consulta = _banco.select(_banco.atividades)
      ..where(
        (a) =>
            a.id.equals(id) & a.petId.equals(petId) & a.excluido.equals(false),
      );
    final anterior = await consulta.getSingleOrNull();
    if (anterior == null) return;
    await (_banco.update(
      _banco.atividades,
    )..where((a) => a.id.equals(id))).write(
      AtividadesCompanion(
        excluido: const Value(true),
        versao: Value(anterior.versao + 1),
        atualizadoEm: Value(agora),
        estadoSync: Value((await _fila.estadoInicial()).name),
      ),
    );
    await _fila.enfileirar(ColecoesSync.atividades, id, OperacaoSync.excluir);
  });

  static Atividade _entidade(AtividadeLinha a) => Atividade(
    id: a.id,
    petId: a.petId,
    tipo: TipoAtividade.values.byName(a.tipo),
    duracaoMin: a.duracaoMin,
    dataHora: a.dataHora,
  );
}
