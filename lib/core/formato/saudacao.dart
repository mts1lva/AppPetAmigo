/// R11 — saudação do título do Início, **sem o nome do tutor** (P-01).
///
/// `Bom dia` (05:00–11:59), `Boa tarde` (12:00–17:59), `Boa noite`
/// (18:00–04:59).
String saudacao(DateTime agora) {
  final h = agora.hour;
  if (h >= 5 && h < 12) return 'Bom dia';
  if (h >= 12 && h < 18) return 'Boa tarde';
  return 'Boa noite';
}
