import 'dart:math' as math;

import 'package:intl/intl.dart';

import 'datas.dart' show localeApp;

/// Número com [casas] decimais, vírgula decimal e ponto de milhar (pt-BR).
/// Arredonda "metade para longe do zero": `110,5` → `111`.
String formatarNumero(double valor, {int casas = 1}) {
  if (!valor.isFinite) throw ArgumentError.value(valor, 'valor', 'precisa ser finito');
  final fator = math.pow(10, casas);
  var arredondado = (valor * fator).round() / fator;
  if (arredondado == 0) arredondado = 0; // evita "-0,0"
  final padrao = casas == 0 ? '#,##0' : '#,##0.${'0' * casas}';
  return NumberFormat(padrao, localeApp).format(arredondado);
}

/// R10 — peso com 1 casa (`5,4 kg`); use `casas: 2` no gráfico interativo.
String formatarPeso(double kg, {int casas = 1}) => '${formatarNumero(kg, casas: casas)} kg';

/// R10 — energia em inteiro: `108 kcal`.
String formatarEnergia(double kcal) => '${formatarNumero(kcal, casas: 0)} kcal';

/// R10 — percentual em inteiro: `18%`.
String formatarPercentual(double percentual) => '${formatarNumero(percentual, casas: 0)}%';

/// R10 — entrada numérica: aceita `5,4` e `5.4`. Devolve `null` se o texto
/// não for um número positivo ou zero bem formado (ex.: `5,4,1`, `abc`, ``).
double? lerNumero(String texto) {
  final normal = texto.trim().replaceAll(',', '.');
  if (!RegExp(r'^(\d+(\.\d*)?|\.\d+)$').hasMatch(normal)) return null;
  return double.parse(normal);
}
