import 'package:intl/intl.dart';

/// Locale do app. O `main` chama `initializeDateFormatting(localeApp)`.
const localeApp = 'pt_BR';

/// R10 — data curta: `30 set. 2026` (dia com dois dígitos, como em
/// `02 dez. 2026` no M5).
String formatarDataCurta(DateTime data) => DateFormat('dd MMM y', localeApp).format(data);

/// R10 — data no cabeçalho do Diário: `30 setembro 2026`.
String formatarDataExtenso(DateTime data) => DateFormat('dd MMMM y', localeApp).format(data);

/// Dia e mês abreviado, sem ano: `30 set.` (card do Início, gráfico, R07).
String formatarDiaMes(DateTime data) => DateFormat('dd MMM', localeApp).format(data);

/// R10 — título do card do Início: `Hoje · 30 set.`
String formatarHojeCard(DateTime hoje) => 'Hoje · ${formatarDiaMes(hoje)}';

/// R10 — hora: `08:00`.
String formatarHora(DateTime data) => DateFormat('HH:mm', localeApp).format(data);

/// Hora guardada em minutos desde 00:00 (tabela `lembretes`): `480` → `08:00`.
String formatarMinutosDoDia(int minutos) {
  if (minutos < 0 || minutos >= 24 * 60) {
    throw RangeError.range(minutos, 0, 24 * 60 - 1, 'minutos');
  }
  final h = (minutos ~/ 60).toString().padLeft(2, '0');
  final m = (minutos % 60).toString().padLeft(2, '0');
  return '$h:$m';
}
