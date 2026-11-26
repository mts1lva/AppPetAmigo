/// R06 — Pesagem suspeita (técnica, não clínica; P-10). Pega erro de
/// digitação, como 54 kg no lugar de 5,4 kg. Dart puro.
library;

import 'entidades/pesagem.dart';

/// `razao ≥ 1,5` é suspeita.
const double razaoSuspeitaAcima = 1.5;

/// `razao ≤ 0,67` é suspeita.
const double razaoSuspeitaAbaixo = 0.67;

/// Resultado da conferência de um peso novo contra a pesagem de referência.
final class ConferenciaPesagem {
  const ConferenciaPesagem({required this.suspeita, this.anteriorKg, this.sugestaoKg});

  /// Sem pesagem de referência: não há verificação.
  static const semVerificacao = ConferenciaPesagem(suspeita: false);

  /// Abre a tela 25 em vez de salvar direto.
  final bool suspeita;

  /// O peso usado na comparação ("Anterior: X kg" da tela 25).
  final double? anteriorKg;

  /// "Corrigir para {sugestaoKg} kg", quando a razão parece um erro de 10×.
  final double? sugestaoKg;

  @override
  bool operator ==(Object other) =>
      other is ConferenciaPesagem &&
      other.suspeita == suspeita &&
      other.anteriorKg == anteriorKg &&
      other.sugestaoKg == sugestaoKg;

  @override
  int get hashCode => Object.hash(suspeita, anteriorKg, sugestaoKg);

  @override
  String toString() => 'ConferenciaPesagem(suspeita: $suspeita)';
}

/// Compara [novoKg] com [anteriorKg]:
/// ```
/// razao = novo / anterior
/// suspeita  se razao ≥ 1,5  ou  razao ≤ 0,67
/// sugestão  se 8 ≤ razao ≤ 12        → novo / 10
///           se 0,08 ≤ razao ≤ 0,125  → novo × 10
/// ```
/// Sem anterior (ou com valores não positivos, que R05 já bloqueia), não há
/// verificação.
ConferenciaPesagem conferirPesagem(double novoKg, double? anteriorKg) {
  if (anteriorKg == null || !_positivo(anteriorKg) || !_positivo(novoKg)) {
    return ConferenciaPesagem.semVerificacao;
  }
  final razao = novoKg / anteriorKg;
  final suspeita = razao >= razaoSuspeitaAcima || razao <= razaoSuspeitaAbaixo;
  if (!suspeita) return ConferenciaPesagem(suspeita: false, anteriorKg: anteriorKg);

  double? sugestao;
  if (razao >= 8 && razao <= 12) {
    sugestao = _gramas(novoKg / 10);
  } else if (razao >= 0.08 && razao <= 0.125) {
    sugestao = _gramas(novoKg * 10);
  }
  return ConferenciaPesagem(suspeita: true, anteriorKg: anteriorKg, sugestaoKg: sugestao);
}

/// A pesagem com que um peso de [dataHora] é comparado: a anterior mais
/// próxima no tempo. Sem anterior (é o **peso inicial**, U2-06), a seguinte
/// mais próxima. [ignorarId] tira da busca a própria pesagem em edição.
Pesagem? pesagemDeReferencia(Iterable<Pesagem> pesagens, {required DateTime dataHora, String? ignorarId}) {
  Pesagem? anterior;
  Pesagem? seguinte;
  for (final p in pesagens) {
    if (p.id == ignorarId) continue;
    if (!p.dataHora.isAfter(dataHora)) {
      if (anterior == null || p.dataHora.isAfter(anterior.dataHora)) anterior = p;
    } else {
      if (seguinte == null || p.dataHora.isBefore(seguinte.dataHora)) seguinte = p;
    }
  }
  return anterior ?? seguinte;
}

bool _positivo(double v) => v.isFinite && v > 0;

/// Arredonda ao grama: `0,54 × 10` dá `5,4000000000000004` em ponto
/// flutuante, e a sugestão precisa ser exatamente `5,4`.
double _gramas(double kg) => (kg * 1000).round() / 1000;
