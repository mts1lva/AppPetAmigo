import 'dart:math' as math;

import '../../../core/resultado.dart';
import '../../pets/domain/entidades/pet.dart';
import 'parametros.dart';

/// M1 — Meta diária de energia (U2-01). Dart puro.
///
/// ```
/// RER = 70 × P^0,75           P = peso atual em kg (última pesagem)
/// MER = RER × fator           (meta diária, kcal/dia)
/// gramas = MER ÷ densidade × 100
/// ```
/// Recebe `hoje` como parâmetro (nunca chama `DateTime.now()`), devolve
/// [Resultado] em vez de lançar exceção e confere `isFinite`.

/// Motivo mostrado ao tutor quando não há pesagem (R03).
const motivoSemPesagem = 'Registre uma pesagem para calcular a meta.';

/// Peso ≤ 0 ou não finito (R05 bloqueia na entrada; aqui é a defesa do
/// modelo).
const motivoPesoInvalido = 'O valor precisa ser positivo.';

/// Densidade ≤ 0: as gramas ficam indisponíveis (tela 22).
const motivoDensidadeInvalida = 'Confira a densidade.';

/// Por que o fator foi escolhido (primeira condição que se aplica, em ordem).
enum OrigemFator {
  /// `idadeMeses < 12` → 3,0.
  filhote,

  /// `nivelAtividade == alta` → 2,0.
  atividadeAlta,

  /// `castrado == true` → 1,6.
  castrado,

  /// Adulto não castrado, atividade baixa ou moderada → 1,8 (P-17).
  adultoNaoCastrado,
}

final class FatorAtividade {
  const FatorAtividade(this.valor, this.origem);

  final double valor;
  final OrigemFator origem;

  @override
  bool operator ==(Object other) =>
      other is FatorAtividade && other.valor == valor && other.origem == origem;

  @override
  int get hashCode => Object.hash(valor, origem);

  @override
  String toString() => 'FatorAtividade($valor, ${origem.name})';
}

/// Resultado do M1 com os passos, para a tela 18 e o card do Início.
final class MetaDiaria {
  const MetaDiaria({
    required this.pesoKg,
    required this.rer,
    required this.fator,
    required this.mer,
  });

  final double pesoKg;
  final double rer;
  final FatorAtividade fator;

  /// Meta diária em kcal/dia.
  final double mer;

  @override
  bool operator ==(Object other) =>
      other is MetaDiaria &&
      other.pesoKg == pesoKg &&
      other.rer == rer &&
      other.fator == fator &&
      other.mer == mer;

  @override
  int get hashCode => Object.hash(pesoKg, rer, fator, mer);

  @override
  String toString() => 'MetaDiaria(rer: $rer, fator: ${fator.valor}, mer: $mer)';
}

/// RER = 70 × peso^0,75.
Resultado<double> rer(double pesoKg) {
  if (!pesoKg.isFinite || pesoKg <= 0) return const Indisponivel(motivoPesoInvalido);
  return _finito(coeficienteRer * math.pow(pesoKg, expoenteRer), motivoPesoInvalido);
}

/// Fator de atividade, avaliado **nesta ordem** (o primeiro que se aplica
/// vale): filhote 3,0 → atividade alta 2,0 → castrado 1,6 → adulto não
/// castrado 1,8 (P-17).
FatorAtividade fatorAtividade(Pet pet, DateTime hoje) {
  if (pet.ehFilhoteEm(hoje)) return const FatorAtividade(fatorFilhote, OrigemFator.filhote);
  if (pet.nivelAtividade == NivelAtividade.alta) {
    return const FatorAtividade(fatorAtivo, OrigemFator.atividadeAlta);
  }
  if (pet.castrado) return const FatorAtividade(fatorCastrado, OrigemFator.castrado);
  return const FatorAtividade(fatorAdultoNaoCastrado, OrigemFator.adultoNaoCastrado);
}

/// MER = RER(última pesagem) × fator. Sem pesagem: [motivoSemPesagem].
Resultado<MetaDiaria> metaDiaria(Pet pet, double? ultimaPesagemKg, DateTime hoje) {
  if (ultimaPesagemKg == null) return const Indisponivel(motivoSemPesagem);
  switch (rer(ultimaPesagemKg)) {
    case Indisponivel(:final motivo):
      return Indisponivel(motivo);
    case Disponivel(valor: final valorRer):
      final fator = fatorAtividade(pet, hoje);
      final mer = valorRer * fator.valor;
      if (!mer.isFinite) return const Indisponivel(motivoPesoInvalido);
      return Disponivel(MetaDiaria(pesoKg: ultimaPesagemKg, rer: valorRer, fator: fator, mer: mer));
  }
}

/// Gramas por dia = meta ÷ densidade × 100 (R04). Densidade ≤ 0:
/// [motivoDensidadeInvalida].
Resultado<double> gramas(double metaKcal, double densidadeKcalPor100g) {
  if (!densidadeKcalPor100g.isFinite || densidadeKcalPor100g <= 0) {
    return const Indisponivel(motivoDensidadeInvalida);
  }
  return _finito(metaKcal / densidadeKcalPor100g * 100, motivoDensidadeInvalida);
}

Resultado<double> _finito(num valor, String motivo) {
  final v = valor.toDouble();
  assert(v.isFinite, 'M1 produziu um valor não finito');
  return v.isFinite ? Disponivel(v) : Indisponivel(motivo);
}
