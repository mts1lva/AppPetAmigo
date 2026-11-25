import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/relogio.dart';
import '../../../../core/resultado.dart';
import '../../../nutricao/apresentacao/providers/meta_provider.dart';
import '../../domain/aderencia.dart';
import 'resumo_dia_provider.dart';

/// Aderência ao plano alimentar (M7), por pet. `null` enquanto a meta ou os
/// resumos ainda carregam.
final aderenciaProvider = Provider.family<Resultado<Aderencia>?, String>((ref, petId) {
  final meta = ref.watch(metaProvider(petId));
  final dias = ref.watch(resumosJanelaProvider(petId)).value;
  if (meta == null || dias == null) return null;
  return aderencia(dias: dias, meta: meta, hoje: ref.watch(agoraProvider)());
});
