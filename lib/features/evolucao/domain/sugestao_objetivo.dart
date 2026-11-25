/// M8 — S3 Mudar objetivo nutricional (U2-11). Dart puro.
///
/// | Condição | Texto |
/// |---|---|
/// | (a) \|Patual − Pi\| ≤ 2% de Pi | "{nome} está perto do peso ideal. Converse com o veterinário sobre passar para manutenção." |
/// | (b) M5 = "não é alcançado" ou > 180 dias, com ≥ 14 dias de dados | "Com o ritmo atual, o objetivo está distante. Vale revisar o objetivo com o veterinário." |
///
/// A evolução acima de 100% (M7, passou do ideal) também dispara a S3, com o
/// texto (a).
library;

import '../../../core/sugestao.dart';
import 'calendario.dart';
import 'data_prevista.dart';
import 'parametros.dart';

String textoPertoDoIdeal(String nomePet) =>
    '$nomePet está perto do peso ideal. Converse com o veterinário sobre passar para manutenção.';

const textoObjetivoDistante = 'Com o ritmo atual, o objetivo está distante. Vale revisar o objetivo com o veterinário.';

/// [primeiraPesagem] é a data do peso inicial, que mede os "14 dias de
/// dados"; [passouDoIdeal] vem de M7.
Sugestao? sugestaoMudarObjetivo({
  required String nomePet,
  required double? pAtual,
  required double? pi,
  required DataPrevista previsao,
  required DateTime? primeiraPesagem,
  required DateTime hoje,
  bool passouDoIdeal = false,
}) {
  if (pAtual == null || pi == null || !pAtual.isFinite || !pi.isFinite || pi <= 0) return null;

  if ((pAtual - pi).abs() <= toleranciaPertoDoIdeal * pi || passouDoIdeal) {
    return Sugestao(tipo: TipoSugestao.mudarObjetivo, texto: textoPertoDoIdeal(nomePet));
  }

  final distante =
      previsao.situacao == SituacaoPrevisao.naoAlcancado ||
      (previsao.dias != null && previsao.dias! > diasObjetivoDistante);
  final dadosSuficientes = primeiraPesagem != null && diasEntre(primeiraPesagem, hoje) >= diasMinimosDeDadosS3;
  if (distante && dadosSuficientes) {
    return const Sugestao(tipo: TipoSugestao.mudarObjetivo, texto: textoObjetivoDistante);
  }
  return null;
}
