/// R02 — monta o [ResumoDia] a partir das refeições e dos extras do dia.
/// Dart puro.
library;

import 'entidades/extra.dart';
import 'entidades/refeicao.dart';
import 'entidades/resumo_dia.dart';
import 'periodo.dart';

/// Soma as energias do [dia] (00:00 a 23:59 no fuso do aparelho). Itens de
/// outros dias são ignorados. Sem nenhum registro, devolve [ResumoDia.vazio]
/// (R09: ausência não é consumo zero).
ResumoDia resumoDoDia({
  required DateTime dia,
  required Iterable<Refeicao> refeicoes,
  required Iterable<Extra> extras,
}) {
  final d = diaDe(dia);
  var racao = 0.0;
  var extrasKcal = 0.0;
  var registros = 0;
  for (final r in refeicoes) {
    if (!mesmoDia(r.dataHora, d)) continue;
    racao += r.energiaKcal;
    registros++;
  }
  for (final e in extras) {
    if (!mesmoDia(e.dataHora, d)) continue;
    extrasKcal += e.energiaKcal;
    registros++;
  }
  if (registros == 0) return ResumoDia.vazio(d);
  return ResumoDia(dia: d, racaoKcal: racao, extrasKcal: extrasKcal, registros: registros);
}
