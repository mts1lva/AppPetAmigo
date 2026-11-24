import '../../../../core/resultado.dart';
import '../../../pets/domain/entidades/pet.dart';
import '../meta_diaria.dart';

/// Caso de uso da meta diária (M1), usado pelo Início e pela tela 18 (P1),
/// pelo diário (P2) e pela projeção (P4).
final class CalcularMetaDiaria {
  const CalcularMetaDiaria();

  Resultado<MetaDiaria> call({
    required Pet pet,
    required double? ultimaPesagemKg,
    required DateTime hoje,
  }) =>
      metaDiaria(pet, ultimaPesagemKg, hoje);
}
