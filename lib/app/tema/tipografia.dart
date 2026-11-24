import 'package:flutter/painting.dart';

import 'cores.dart';

/// Estilos de texto (Inter, empacotada em `assets/fonts`).
///
/// `letterSpacing: 0` vem do `tokens.json` (`espacamentoLetras: 0`). Sem ele,
/// o texto herdaria o espaçamento do Material 3 (0,25 a 0,5) e ficaria mais
/// largo que no Figma.
abstract final class PaTexto {
  static const _f = 'Inter';

  static const titulo = TextStyle(fontFamily: _f, fontSize: 26, height: 36 / 26, fontWeight: FontWeight.w700, letterSpacing: 0, color: PaCores.texto);
  static const secao = TextStyle(fontFamily: _f, fontSize: 18, height: 25 / 18, fontWeight: FontWeight.w700, letterSpacing: 0, color: PaCores.texto);
  static const corpo = TextStyle(fontFamily: _f, fontSize: 16, height: 1.4, fontWeight: FontWeight.w400, letterSpacing: 0, color: PaCores.texto);
  static const legenda = TextStyle(fontFamily: _f, fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w400, letterSpacing: 0, color: PaCores.texto);
  static const navegacao = TextStyle(fontFamily: _f, fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, letterSpacing: 0, color: PaCores.texto);
}
