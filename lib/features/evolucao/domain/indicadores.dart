/// M7 — Percentual de evolução (U2-12). A aderência ao plano alimentar é do
/// P2. Dart puro.
///
/// ```
/// Pinicial = primeira pesagem do pet ("peso inicial", editável)
/// evolucao = (Pinicial − Patual) ÷ (Pinicial − Pi) × 100, limitado a [0, 100]
/// ```
library;

import '../../../core/formato/numeros.dart';
import 'data_prevista.dart' show DataPrevista, SituacaoPrevisao;

/// `|Pinicial − Pi| < 0,01`: a evolução mostra "—".
const textoPesoInicialJaIdeal = 'O peso inicial já era o ideal.';

enum SituacaoEvolucao {
  /// Há percentual.
  calculada,

  /// `|Pinicial − Pi| < 0,01` → "—".
  inicialJaIdeal,

  /// Sem pesagem ou sem peso ideal.
  indisponivel,
}

final class Evolucao {
  const Evolucao._(this.situacao, {this.percentual, this.passouDoIdeal = false});

  final SituacaoEvolucao situacao;

  /// 0 a 100, já limitado.
  final double? percentual;

  /// O resultado bruto passou de 100: mostra 100% e dispara a S3 (M8).
  final bool passouDoIdeal;

  /// Linha do card Indicadores depois de `Evolução • `: `18% do caminho`,
  /// `—` ou, sem peso ideal, o texto de M5.
  String get texto => switch (situacao) {
    SituacaoEvolucao.calculada => '${formatarPercentual(percentual!)} do caminho',
    SituacaoEvolucao.inicialJaIdeal => '—',
    SituacaoEvolucao.indisponivel => DataPrevista.textoDe(SituacaoPrevisao.semPesoIdeal),
  };

  @override
  bool operator ==(Object other) =>
      other is Evolucao &&
      other.situacao == situacao &&
      other.percentual == percentual &&
      other.passouDoIdeal == passouDoIdeal;

  @override
  int get hashCode => Object.hash(situacao, percentual, passouDoIdeal);

  @override
  String toString() => 'Evolucao(${situacao.name})';
}

/// [pInicial] é a primeira pesagem do pet; [pAtual], a última; [pi], o M2.
Evolucao evolucao({required double? pInicial, required double? pAtual, required double? pi}) {
  if (!_valido(pInicial) || !_valido(pAtual) || !_valido(pi)) {
    return const Evolucao._(SituacaoEvolucao.indisponivel);
  }
  final caminho = pInicial! - pi!;
  if (caminho.abs() < 0.01) return const Evolucao._(SituacaoEvolucao.inicialJaIdeal);

  final bruto = (pInicial - pAtual!) / caminho * 100;
  if (!bruto.isFinite) return const Evolucao._(SituacaoEvolucao.indisponivel);
  return Evolucao._(SituacaoEvolucao.calculada, percentual: bruto.clamp(0.0, 100.0), passouDoIdeal: bruto > 100);
}

bool _valido(double? v) => v != null && v.isFinite && v > 0;
