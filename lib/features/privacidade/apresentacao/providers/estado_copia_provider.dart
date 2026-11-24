import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entidades/estado_copia.dart';

/// Estado da cópia remota (vale para todos os pets do aparelho).
///
/// **STUB** criado pelo P1 na etapa 1 (`plano-de-execucao.md` → Stubs):
/// sempre desligada.
final estadoCopiaProvider = StreamProvider<EstadoCopia>(
  (ref) => Stream.value(const CopiaDesligada()), // TODO(P5-3.3): estado real da fila
);
