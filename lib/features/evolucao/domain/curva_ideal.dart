/// M3 — Curva ideal de 90 dias (U2-03). Dart puro.
///
/// Ritmo recomendado: 1% do peso por semana (P-19).
/// ```
/// d = 0 (hoje) … 90;  P0 = última pesagem;  Pi = peso ideal (M2)
/// perda:      ideal(d) = max(Pi, P0 × 0,99^(d/7))
/// ganho:      ideal(d) = min(Pi, P0 × 1,01^(d/7))
/// manutenção (|P0 − Pi| ≤ 1% de Pi): ideal(d) = Pi
/// ```
library;

import 'dart:math' as math;

import '../../../core/resultado.dart';
import 'parametros.dart';
import 'peso_ideal.dart' show motivoSemReferencia;

/// Sem P0 ou Pi a curva não aparece; o motivo é o mesmo do M2.
const motivoCurvaIndisponivel = motivoSemReferencia;

/// Os 91 valores `ideal(0) … ideal(90)`, em kg. Indisponível sem P0 ou Pi.
Resultado<List<double>> curvaIdeal({required double? p0, required double? pi}) {
  if (p0 == null || pi == null || !_positivo(p0) || !_positivo(pi)) {
    return const Indisponivel(motivoCurvaIndisponivel);
  }
  final curva = List<double>.generate(horizonteDias + 1, (d) => _ideal(p0, pi, d));
  assert(curva.every((v) => v.isFinite), 'M3 produziu um valor não finito');
  return curva.every((v) => v.isFinite) ? Disponivel(curva) : const Indisponivel(motivoCurvaIndisponivel);
}

double _ideal(double p0, double pi, int d) {
  if ((p0 - pi).abs() <= toleranciaPesoIdeal * pi) return pi;
  final semanas = d / 7;
  if (p0 > pi) return math.max(pi, p0 * math.pow(1 - ritmoSemanalCurvaIdeal, semanas));
  return math.min(pi, p0 * math.pow(1 + ritmoSemanalCurvaIdeal, semanas));
}

bool _positivo(double v) => v.isFinite && v > 0;
