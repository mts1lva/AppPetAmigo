/// M5 — Data prevista para o peso ideal (U2-08). Dart puro.
///
/// | Condição (nesta ordem) | Resultado |
/// |---|---|
/// | Pi indisponível | "Defina o ECC ou o objetivo para estimar." |
/// | \|P0 − Pi\| ≤ 1% de Pi | "Peso ideal alcançado." |
/// | kgDia indisponível | "Registre pesagens ou refeições para estimar." |
/// | \|kgDia\| < 0,000001 ou sinal contrário a (Pi − P0) | "Com o ritmo atual, o peso ideal não é alcançado." |
/// | dias > 365 | "Mais de 1 ano com o ritmo atual." |
/// | senão | `hoje + dias`, com `dias = ceil(round((Pi − P0) ÷ kgDia, 6))` |
library;

import '../../../core/formato/datas.dart';
import 'calendario.dart';
import 'parametros.dart';

enum SituacaoPrevisao { semPesoIdeal, alcancado, semRitmo, naoAlcancado, maisDeUmAno, prevista }

final class DataPrevista {
  const DataPrevista._(this.situacao, {this.dias, this.data});

  final SituacaoPrevisao situacao;

  /// Dias até o peso ideal, quando calculados (`prevista` e `maisDeUmAno`).
  final int? dias;

  /// `hoje + dias`, só em `prevista`.
  final DateTime? data;

  /// O texto exato de M5: `28 nov. 2026` ou a frase da situação.
  String get texto => situacao == SituacaoPrevisao.prevista ? formatarDataCurta(data!) : textoDe(situacao);

  /// A frase de M5 de cada situação sem data.
  static String textoDe(SituacaoPrevisao situacao) => switch (situacao) {
    SituacaoPrevisao.semPesoIdeal => 'Defina o ECC ou o objetivo para estimar.',
    SituacaoPrevisao.alcancado => 'Peso ideal alcançado.',
    SituacaoPrevisao.semRitmo => 'Registre pesagens ou refeições para estimar.',
    SituacaoPrevisao.naoAlcancado => 'Com o ritmo atual, o peso ideal não é alcançado.',
    SituacaoPrevisao.maisDeUmAno => 'Mais de 1 ano com o ritmo atual.',
    SituacaoPrevisao.prevista => throw ArgumentError.value(situacao, 'situacao', 'tem data, use texto'),
  };

  @override
  bool operator ==(Object other) =>
      other is DataPrevista && other.situacao == situacao && other.dias == dias && other.data == data;

  @override
  int get hashCode => Object.hash(situacao, dias, data);

  @override
  String toString() => 'DataPrevista(${situacao.name}, dias: $dias)';
}

/// [kgDia] é o ritmo da projeção (M4), já limitado; [p0] a última pesagem;
/// [pi] o peso ideal (M2).
DataPrevista dataPrevista({required double? p0, required double? pi, required double? kgDia, required DateTime hoje}) {
  if (pi == null || !pi.isFinite || pi <= 0) return const DataPrevista._(SituacaoPrevisao.semPesoIdeal);
  if (p0 == null || !p0.isFinite || p0 <= 0 || kgDia == null || !kgDia.isFinite) {
    return const DataPrevista._(SituacaoPrevisao.semRitmo);
  }
  if ((p0 - pi).abs() <= toleranciaPesoIdeal * pi) return const DataPrevista._(SituacaoPrevisao.alcancado);

  final falta = pi - p0;
  if (kgDia.abs() < ritmoMinimo || kgDia.sign != falta.sign) {
    return const DataPrevista._(SituacaoPrevisao.naoAlcancado);
  }

  // O round(…, 6) é obrigatório: (4,5 − 5,4) ÷ −0,014286 dá
  // 63,00000000000002, e o ceil sozinho daria 64 dias.
  final dias = _arredondar(falta / kgDia, 6).ceil();
  if (dias > diasMaximoPrevisao) return DataPrevista._(SituacaoPrevisao.maisDeUmAno, dias: dias);
  return DataPrevista._(SituacaoPrevisao.prevista, dias: dias, data: somarDias(hoje, dias));
}

double _arredondar(double valor, int casas) {
  var fator = 1.0;
  for (var i = 0; i < casas; i++) {
    fator *= 10;
  }
  return (valor * fator).round() / fator;
}
