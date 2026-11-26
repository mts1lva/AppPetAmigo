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

/// Motivos de R05 para o petisco cadastrado (P-32).
const motivoEnergiaPorUnidadeInvalida = 'Informe a energia por unidade.';
const motivoUnidadesInvalidas = 'Informe um número inteiro de unidades.';

/// R01, petisco cadastrado (P-32): `energiaKcal = unidades × kcalPorUnidade`.
/// Unidades ≤ 0 ou energia por unidade ≤ 0 (ou não finita): [Indisponivel].
Resultado<double> energiaPetisco(int unidades, double kcalPorUnidade) {
  if (unidades <= 0) return const Indisponivel(motivoUnidadesInvalidas);
  if (!kcalPorUnidade.isFinite || kcalPorUnidade <= 0) {
    return const Indisponivel(motivoEnergiaPorUnidadeInvalida);
  }
  final kcal = unidades * kcalPorUnidade;
  return kcal.isFinite ? Disponivel(kcal) : const Indisponivel(motivoEnergiaPorUnidadeInvalida);
}
