import 'package:material_ui/material_ui.dart';

import 'cores.dart';
import 'tipografia.dart';

/// `ThemeData` do PetAmigo. O protótipo não tem ondulação: o splash fica
/// desligado e o realce de toque é discreto.
abstract final class PaTema {
  static ThemeData get claro {
    const esquema = ColorScheme.light(
      primary: PaCores.verde,
      onPrimary: PaCores.superficie,
      secondary: PaCores.verde,
      onSecondary: PaCores.superficie,
      surface: PaCores.superficie,
      onSurface: PaCores.texto,
      error: PaCores.erro,
      onError: PaCores.superficie,
      outline: PaCores.borda,
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',
      colorScheme: esquema,
      scaffoldBackgroundColor: PaCores.fundo,
      splashFactory: NoSplash.splashFactory,
      splashColor: Colors.transparent,
      highlightColor: PaCores.texto.withValues(alpha: 0.06),
      textTheme: const TextTheme(
        headlineSmall: PaTexto.titulo,
        titleMedium: PaTexto.secao,
        bodyLarge: PaTexto.corpo,
        bodyMedium: PaTexto.corpo,
        bodySmall: PaTexto.legenda,
        labelSmall: PaTexto.navegacao,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: PaCores.verde,
        selectionHandleColor: PaCores.verde,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: PaCores.superficie,
        surfaceTintColor: Colors.transparent,
      ),
    );
  }
}
