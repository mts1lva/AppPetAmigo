import 'package:petamigo/core/sync/fila_sync.dart';

/// Fila que registra as chamadas; pode simular a cópia ligada ou uma falha.
final class FilaGravadora implements FilaSync {
  EstadoSync estado = EstadoSync.local;
  bool falhar = false;
  final chamadas = <(String, String, OperacaoSync)>[];

  @override
  Future<EstadoSync> estadoInicial() async => estado;

  @override
  Future<void> enfileirar(String tabela, String registroId, OperacaoSync op) async {
    if (falhar) throw StateError('falha simulada');
    chamadas.add((tabela, registroId, op));
  }
}
