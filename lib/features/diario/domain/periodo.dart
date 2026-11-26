/// Datas sem hora, no fuso do aparelho, para o resumo do dia e as janelas
/// de M7/S1. Dart puro: recebe `hoje` como parâmetro.
library;

/// 00:00 do dia de [data] (ano, mês, dia).
DateTime diaDe(DateTime data) => DateTime(data.year, data.month, data.day);

/// Mesmo dia civil, ignorando a hora.
bool mesmoDia(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// [dia] está na janela dos últimos [dias] dias, incluindo [hoje].
/// Ex.: 14 dias → de `hoje − 13` até `hoje`.
bool naJanela(DateTime dia, DateTime hoje, int dias) {
  final d = diaDe(dia);
  final h = diaDe(hoje);
  final inicio = h.subtract(Duration(days: dias - 1));
  return !d.isBefore(inicio) && !d.isAfter(h);
}
