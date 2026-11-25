/// R01 — energia da refeição (`comum/regras.md`). Dart puro.
///
/// ```
/// energiaKcal = quantidadeG × densidadeKcalPor100g / 100
/// ```
/// A densidade usada é a **copiada na refeição**. Ao editar a quantidade,
/// o recálculo usa essa cópia, não a densidade atual do alimento (RF04).
library;

import '../../../core/resultado.dart';

/// Motivo quando quantidade ou densidade não permitem calcular (R05).
const motivoQuantidadeInvalida = 'A quantidade precisa ser positiva.';
const motivoDensidadeInvalida = 'Confira a densidade.';

/// Energia da porção em kcal (R01). Quantidade ou densidade ≤ 0, ou valor
/// não finito: [Indisponivel].
Resultado<double> energiaRefeicao(double quantidadeG, double densidadeKcalPor100g) {
  if (!quantidadeG.isFinite || quantidadeG <= 0) {
    return const Indisponivel(motivoQuantidadeInvalida);
  }
  if (!densidadeKcalPor100g.isFinite || densidadeKcalPor100g <= 0) {
    return const Indisponivel(motivoDensidadeInvalida);
  }
  final kcal = quantidadeG * densidadeKcalPor100g / 100;
  assert(kcal.isFinite, 'R01 produziu um valor não finito');
  return kcal.isFinite ? Disponivel(kcal) : const Indisponivel(motivoQuantidadeInvalida);
}
