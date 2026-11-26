import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../banco/banco_provider.dart';
import '../relogio.dart';
import 'fila_sync.dart';
import 'fila_sync_ativa.dart';

/// Fila de sincronização usada pelos repositórios (`P5-1.4`).
///
/// Com a cópia remota desligada (`copiaRemotaAtiva != 'true'`), comporta-se
/// como [FilaSyncInativa]: devolve [EstadoSync.local] e não grava na fila.
final filaSyncProvider = Provider<FilaSync>(
  (ref) => FilaSyncAtiva(
    ref.watch(bancoProvider),
    agora: ref.watch(agoraProvider),
  ),
);
