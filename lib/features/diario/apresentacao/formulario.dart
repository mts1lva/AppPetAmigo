import 'package:material_ui/material_ui.dart';

import '../../../core/formato/numeros.dart';

/// Número para um `PaCampo.numero`: vírgula decimal, sem zeros à direita.
String textoNumeroCampo(double valor) {
  final texto = formatarNumero(valor, casas: 2).replaceAll('.', '');
  return texto.contains(',') ? texto.replaceFirst(RegExp(r',?0+$'), '') : texto;
}

DateTime juntarDataHora(DateTime data, TimeOfDay hora) =>
    DateTime(data.year, data.month, data.day, hora.hour, hora.minute);

bool dataHoraFutura(DateTime valor, DateTime agora) => valor.isAfter(agora);
