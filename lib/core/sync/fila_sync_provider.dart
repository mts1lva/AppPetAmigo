import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'fila_sync.dart';

/// Fila de sincronização usada pelos repositórios. Até a etapa 5 é a
/// [FilaSyncInativa]; o P5 troca pela `FilaSyncAtiva` (P5-1.4) sem mudar a
/// assinatura.
final filaSyncProvider = Provider<FilaSync>((ref) => const FilaSyncInativa());
