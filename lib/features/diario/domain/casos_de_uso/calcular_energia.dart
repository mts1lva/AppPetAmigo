import '../../../../core/resultado.dart';
import '../energia.dart';

/// Caso de uso de R01: energia da porção a partir da quantidade e da
/// densidade **da própria refeição** (não a atual do alimento).
final class CalcularEnergia {
  const CalcularEnergia();

  Resultado<double> call({required double quantidadeG, required double densidadeKcalPor100g}) =>
      energiaRefeicao(quantidadeG, densidadeKcalPor100g);
}
