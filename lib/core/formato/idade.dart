/// R11 — idade exibida a partir dos meses: `6 meses` abaixo de 1 ano;
/// `1 ano` / `6 anos` a partir daí (os meses que sobram não aparecem).
String formatarIdade(int meses) {
  if (meses < 0) throw RangeError.value(meses, 'meses', 'não pode ser negativo');
  if (meses < 12) return meses == 1 ? '1 mês' : '$meses meses';
  final anos = meses ~/ 12;
  return anos == 1 ? '1 ano' : '$anos anos';
}
