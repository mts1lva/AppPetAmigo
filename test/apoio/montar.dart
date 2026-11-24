import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/tema/tema.dart';

/// `MaterialApp` com o tema e o locale do app, para widget tests.
Widget appDeTeste(Widget home, {double escalaTexto = 1}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: PaTema.claro,
    locale: const Locale('pt', 'BR'),
    supportedLocales: const [Locale('pt', 'BR')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    builder: (context, filho) => MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(escalaTexto)),
      child: filho!,
    ),
    home: home,
  );
}

/// Monta um componente com a largura de conteúdo do Figma (350 dp), rolável.
Future<void> montarComponente(
  WidgetTester tester,
  Widget componente, {
  double escalaTexto = 1,
  double largura = 350,
}) {
  return tester.pumpWidget(
    appDeTeste(
      Scaffold(
        body: SingleChildScrollView(
          child: Center(child: SizedBox(width: largura, child: componente)),
        ),
      ),
      escalaTexto: escalaTexto,
    ),
  );
}
