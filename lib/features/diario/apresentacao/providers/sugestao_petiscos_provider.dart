import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/relogio.dart';
import '../../../../core/sugestao.dart';
import '../../domain/sugestao_petiscos.dart';
import 'resumo_dia_provider.dart';

/// S1 — reduzir petiscos (M8), por pet. `null` se a regra não se aplica ou
/// enquanto os resumos carregam.
final sugestaoPetiscosProvider = Provider.family<Sugestao?, String>((ref, petId) {
  final dias = ref.watch(resumosJanelaProvider(petId)).value;
  if (dias == null) return null;
  return sugestaoPetiscos(dias: dias, hoje: ref.watch(agoraProvider)());
});
