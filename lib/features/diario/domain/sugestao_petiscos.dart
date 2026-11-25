/// S1 — reduzir petiscos (U2-11, M8). Dart puro.
///
/// Condição: em ≥ 3 dos últimos 7 **dias com registro**, os extras passam
/// de 10% do total (AAHA/WSAVA, `pesquisa.md`). Dias sem registro não
/// contam. Devolve `null` quando a regra não se aplica.
library;

import '../../../core/sugestao.dart';
import 'entidades/resumo_dia.dart';
import 'parametros.dart';
import 'periodo.dart';

/// Texto de M8, com [n] = quantos dias da janela passaram de 10%.
String textoSugestaoPetiscos(int n) =>
    'Os petiscos passaram de 10% das calorias em $n dias. '
    'Que tal trocar alguns por um momento de brincadeira?';

/// Avalia a S1 sobre os [dias] do pet até [hoje].
Sugestao? sugestaoPetiscos({required Iterable<ResumoDia> dias, required DateTime hoje}) {
  var acima = 0;
  for (final r in dias) {
    if (!r.temRegistros) continue;
    if (!naJanela(r.dia, hoje, janelaSugestaoPetiscosDias)) continue;
    if (r.totalKcal <= 0 || !r.totalKcal.isFinite) continue;
    if (r.extrasKcal / r.totalKcal > parcelaExtrasLimite) acima++;
  }
  if (acima < diasMinimosSugestaoPetiscos) return null;
  return Sugestao(tipo: TipoSugestao.reduzirPetiscos, texto: textoSugestaoPetiscos(acima));
}
