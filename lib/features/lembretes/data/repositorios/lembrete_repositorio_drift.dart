import 'package:drift/drift.dart';

import '../../../../core/banco/database.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../domain/entidades/lembrete.dart';
import '../../domain/repositorios/lembrete_repositorio.dart';

final class LembreteRepositorioDrift implements LembreteRepositorio {
  const LembreteRepositorioDrift(
    this._banco,
    this._fila, {
    required this.novoId,
  });
  final BancoLocal _banco;
  final FilaSync _fila;
  final String Function() novoId;

  SimpleSelectStatement<$LembretesTable, LembreteLinha> _consulta(
    String petId,
    bool incluirExcluidos,
  ) => _banco.select(_banco.lembretes)
    ..where(
      (l) =>
          l.petId.equals(petId) &
          (incluirExcluidos ? const Constant(true) : l.excluido.equals(false)),
    )
    ..orderBy([(l) => OrderingTerm.asc(l.hora), (l) => OrderingTerm.asc(l.id)]);

  @override
  Stream<List<Lembrete>> observar(String petId) => _consulta(
    petId,
    false,
  ).watch().map((linhas) => linhas.map(_entidade).toList());
  @override
  Future<List<Lembrete>> listar(
    String petId, {
    bool incluirExcluidos = false,
  }) async =>
      (await _consulta(petId, incluirExcluidos).get()).map(_entidade).toList();

  @override
  Future<Lembrete> salvar(Lembrete l, {required DateTime agora}) =>
      _banco.transaction(() => _salvar(l, agora));

  Future<Lembrete> _salvar(Lembrete l, DateTime agora) async {
    final pet =
        await (_banco.select(_banco.pets)
              ..where((p) => p.id.equals(l.petId) & p.excluido.equals(false)))
            .getSingleOrNull();
    if (pet == null) throw StateError('Pet indisponível.');
    validarLembrete(l, await listar(l.petId));
    final anterior = await (_banco.select(
      _banco.lembretes,
    )..where((r) => r.id.equals(l.id))).getSingleOrNull();
    if (anterior != null && (anterior.petId != l.petId || anterior.excluido))
      throw StateError('Registro indisponível.');
    // A alocação ocorre na mesma transação; inclui lápides para não reutilizar
    // um id cujo alarme antigo ainda possa existir no Android.
    final maior =
        await (_banco.select(_banco.lembretes)
              ..orderBy([(r) => OrderingTerm.desc(r.notificacaoId)])
              ..limit(1))
            .getSingleOrNull();
    final notificacaoId =
        anterior?.notificacaoId ?? (maior?.notificacaoId ?? 0) + 1;
    if (notificacaoId > 0x7fffffff)
      throw StateError('Limite de notificações atingido.');
    await _banco
        .into(_banco.lembretes)
        .insertOnConflictUpdate(
          LembretesCompanion.insert(
            id: l.id,
            petId: l.petId,
            criadoEm: anterior?.criadoEm ?? agora,
            atualizadoEm: agora,
            hora: l.horaMinutos,
            tipo: l.tipo.name,
            ativo: Value(l.ativo),
            notificacaoId: notificacaoId,
            versao: Value((anterior?.versao ?? 0) + 1),
            versaoRemota: Value(anterior?.versaoRemota),
            estadoSync: Value((await _fila.estadoInicial()).name),
          ),
        );
    await _fila.enfileirar(ColecoesSync.lembretes, l.id, OperacaoSync.upsert);
    return Lembrete(
      id: l.id,
      petId: l.petId,
      horaMinutos: l.horaMinutos,
      tipo: l.tipo,
      ativo: l.ativo,
      notificacaoId: notificacaoId,
    );
  }

  @override
  Future<List<Lembrete>> criarSugeridos(
    String petId, {
    required DateTime agora,
  }) => _banco.transaction(() async {
    final salvos = <Lembrete>[];
    for (final hora in [480, 840, 1200]) {
      salvos.add(
        await _salvar(
          Lembrete(
            id: novoId(),
            petId: petId,
            horaMinutos: hora,
            tipo: TipoLembrete.refeicao,
            ativo: true,
            notificacaoId: 0,
          ),
          agora,
        ),
      );
    }
    return salvos;
  });

  @override
  Future<void> excluir(String petId, String id, {required DateTime agora}) =>
      _banco.transaction(() async {
        final anterior = await (_consulta(
          petId,
          false,
        )..where((l) => l.id.equals(id))).getSingleOrNull();
        if (anterior == null) return;
        await (_banco.update(
          _banco.lembretes,
        )..where((l) => l.id.equals(id))).write(
          LembretesCompanion(
            excluido: const Value(true),
            versao: Value(anterior.versao + 1),
            atualizadoEm: Value(agora),
            estadoSync: Value((await _fila.estadoInicial()).name),
          ),
        );
        await _fila.enfileirar(
          ColecoesSync.lembretes,
          id,
          OperacaoSync.excluir,
        );
      });

  static Lembrete _entidade(LembreteLinha l) => Lembrete(
    id: l.id,
    petId: l.petId,
    horaMinutos: l.hora,
    tipo: TipoLembrete.values.byName(l.tipo),
    ativo: l.ativo,
    notificacaoId: l.notificacaoId,
  );
}
