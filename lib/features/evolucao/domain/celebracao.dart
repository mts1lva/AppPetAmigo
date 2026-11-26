/// M8 — Celebração ao salvar uma pesagem (briefing B-a, R08). Dart puro.
///
/// Se Pi existe e a distância até Pi **diminuiu pelo menos 100 g** em relação
/// à pesagem anterior: "{nome} chegou {diferença arredondada a 10 g} g mais
/// perto do peso ideal!". Nunca celebra sem Pi nem quando se afasta do ideal,
/// e nunca usa culpa.
library;

import '../../../core/formato/numeros.dart';
import 'parametros.dart';

/// Segunda linha do diálogo N3.
const textoContinueNoSeuRitmo = 'Continue no seu ritmo.';

/// Texto da celebração, ou `null` quando não há o que celebrar.
String? celebracao({
  required String nomePet,
  required double? anteriorKg,
  required double novoKg,
  required double? pi,
}) {
  if (anteriorKg == null || pi == null) return null;
  if (![anteriorKg, novoKg, pi].every((v) => v.isFinite && v > 0)) return null;

  // Em gramas inteiros: |5,5 − 4,5| − |5,4 − 4,5| dá 0,0999999… em ponto
  // flutuante, e a comparação direta com 0,1 negaria a celebração do exemplo.
  final aproximouGramas = (((anteriorKg - pi).abs() - (novoKg - pi).abs()) * 1000).round();
  if (aproximouGramas < gramasMinimosCelebracao) return null;

  final arredondado = (aproximouGramas / 10).round() * 10;
  return '$nomePet chegou ${formatarNumero(arredondado.toDouble(), casas: 0)} g mais perto do peso ideal!';
}
