/// M2 — Peso ideal (U2-12). Dart puro.
///
/// Prioridade:
/// 1. Objetivo informado → usa direto. Rótulo `(objetivo informado)`.
/// 2. ECC informado → estimativa pela escala de 9 pontos (WSAVA), cerca de
///    10% de peso por ponto (P-18), com P = a pesagem mais próxima da data do
///    ECC. Rótulo `(estimado pelo ECC {n})`.
/// 3. Nenhum dos dois → [motivoSemReferencia].
library;

import '../../../core/resultado.dart';
import 'calendario.dart';
import 'entidades/pesagem.dart';
import 'entidades/referencia.dart';
import 'parametros.dart';

const motivoSemReferencia = 'Informe o ECC ou o objetivo em Evolução.';

/// ECC informado, mas nenhuma pesagem para estimar a partir dele.
const motivoSemPesagemParaEcc = 'Registre uma pesagem para estimar o peso ideal.';

/// De onde veio o peso ideal.
enum OrigemPesoIdeal { objetivoInformado, estimadoPeloEcc }

final class PesoIdeal {
  const PesoIdeal({required this.kg, required this.origem, this.ecc});

  final double kg;
  final OrigemPesoIdeal origem;

  /// O ECC usado, quando [origem] é [OrigemPesoIdeal.estimadoPeloEcc].
  final int? ecc;

  /// `(objetivo informado)` ou `(estimado pelo ECC 7)`.
  String get rotulo => switch (origem) {
    OrigemPesoIdeal.objetivoInformado => '(objetivo informado)',
    OrigemPesoIdeal.estimadoPeloEcc => '(estimado pelo ECC $ecc)',
  };

  @override
  bool operator ==(Object other) => other is PesoIdeal && other.kg == kg && other.origem == origem && other.ecc == ecc;

  @override
  int get hashCode => Object.hash(kg, origem, ecc);

  @override
  String toString() => 'PesoIdeal(${origem.name})';
}

/// M2 a partir da referência vigente e das pesagens do pet.
Resultado<PesoIdeal> pesoIdeal(Referencia? referencia, Iterable<Pesagem> pesagens) {
  if (referencia == null) return const Indisponivel(motivoSemReferencia);

  final objetivo = referencia.objetivoKg;
  if (objetivo != null && objetivo.isFinite && objetivo > 0) {
    return Disponivel(PesoIdeal(kg: objetivo, origem: OrigemPesoIdeal.objetivoInformado));
  }

  final ecc = referencia.ecc;
  if (ecc == null) return const Indisponivel(motivoSemReferencia);
  final base = _pesagemMaisProxima(pesagens, referencia.data);
  if (base == null) return const Indisponivel(motivoSemPesagemParaEcc);

  return switch (pesoIdealPeloEcc(base.pesoKg, ecc)) {
    Disponivel(:final valor) => Disponivel(PesoIdeal(kg: valor, origem: OrigemPesoIdeal.estimadoPeloEcc, ecc: ecc)),
    Indisponivel(:final motivo) => Indisponivel(motivo),
  };
}

/// ```
/// ECC 4 ou 5  → ideal = P
/// ECC ≥ 6     → ideal = P ÷ (1 + 0,10 × (ECC − 5))
/// ECC ≤ 3     → ideal = P ÷ (1 − 0,10 × (4 − ECC))
/// ```
Resultado<double> pesoIdealPeloEcc(double pesoKg, int ecc) {
  if (!pesoKg.isFinite || pesoKg <= 0 || ecc < eccMinimo || ecc > eccMaximo) {
    return const Indisponivel(motivoSemReferencia);
  }
  final double ideal;
  if (ecc >= 6) {
    ideal = pesoKg / (1 + variacaoPorPontoEcc * (ecc - 5));
  } else if (ecc <= 3) {
    ideal = pesoKg / (1 - variacaoPorPontoEcc * (4 - ecc));
  } else {
    ideal = pesoKg;
  }
  assert(ideal.isFinite, 'M2 produziu um valor não finito');
  return ideal.isFinite && ideal > 0 ? Disponivel(ideal) : const Indisponivel(motivoSemReferencia);
}

/// A pesagem mais próxima (em dias) da data do ECC. Empate: a mais recente.
Pesagem? _pesagemMaisProxima(Iterable<Pesagem> pesagens, DateTime data) {
  Pesagem? melhor;
  int? melhorDistancia;
  for (final p in pesagens) {
    final distancia = diasEntre(data, p.dataHora).abs();
    if (melhor == null ||
        distancia < melhorDistancia! ||
        (distancia == melhorDistancia && p.dataHora.isAfter(melhor.dataHora))) {
      melhor = p;
      melhorDistancia = distancia;
    }
  }
  return melhor;
}
