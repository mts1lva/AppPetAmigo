/// R03 e R04 — textos da meta diária (M1) no card "Referência alimentar" do
/// Início e na tela 18. Dart puro.
library;

import '../../../core/formato/numeros.dart';
import '../../../core/resultado.dart';
import '../../pets/domain/descricao_pet.dart';
import '../../pets/domain/entidades/pet.dart';
import 'meta_diaria.dart';

/// Por que o fator foi escolhido, no texto do card: `castrada`, `não castrado`,
/// `filhote`, `atividade alta`. O protótipo só mostra `(castrada)`; os outros
/// reaproveitam os termos de R11.
String rotuloFator(Pet pet, FatorAtividade fator) => switch (fator.origem) {
  OrigemFator.filhote => 'filhote',
  OrigemFator.atividadeAlta => 'atividade alta',
  OrigemFator.castrado || OrigemFator.adultoNaoCastrado => castracaoTexto(pet),
};

/// `≈ 110 g` (R04: arredondado ao grama, sempre com "≈"), ou `null` se a
/// densidade for inválida.
String? gramasAproximadas(double metaKcal, double densidadeKcalPor100g) =>
    switch (gramas(metaKcal, densidadeKcalPor100g)) {
      Disponivel(:final valor) => '≈ ${formatarNumero(valor, casas: 0)} g',
      Indisponivel() => null,
    };

/// Texto do card "Referência alimentar" (R03):
/// `Meta de hoje: 397 kcal (≈ 110 g de Ração habitual)` /
/// `RER × 1,6 (castrada). Estimativa educativa.`
///
/// Sem alimento (ou com densidade inválida), só as kcal (P-24). Sem pesagem,
/// o motivo de [Indisponivel] (`Registre uma pesagem para calcular a meta.`).
String textoReferenciaAlimentar(
  Resultado<MetaDiaria> meta,
  Pet pet, {
  String? alimentoNome,
  double? densidadeKcalPor100g,
}) {
  switch (meta) {
    case Indisponivel(:final motivo):
      return motivo;
    case Disponivel(valor: final m):
      final emGramas = (alimentoNome != null && densidadeKcalPor100g != null)
          ? gramasAproximadas(m.mer, densidadeKcalPor100g)
          : null;
      final complemento = emGramas == null ? '' : ' ($emGramas de $alimentoNome)';
      return 'Meta de hoje: ${formatarEnergia(m.mer)}$complemento\n'
          'RER × ${formatarNumero(m.fator.valor)} (${rotuloFator(pet, m.fator)}). Estimativa educativa.';
  }
}
