import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/tema/cores.dart';
import 'package:petamigo/core/ui/ui.dart';

import '../../apoio/montar.dart';

Color _corBordaDaCaixa(WidgetTester tester, Finder campo) {
  final material = tester.widget<Material>(find.descendant(of: campo, matching: find.byType(Material)).first);
  return (material.shape! as RoundedRectangleBorder).side.color;
}

void main() {
  group('PaCampo (texto e número)', () {
    testWidgets('linha "Rótulo • valor", altura mínima 64 e borda padrão', (tester) async {
      final controle = TextEditingController(text: 'Luna');
      addTearDown(controle.dispose);
      await montarComponente(tester, PaCampo(rotulo: 'Nome', controller: controle));

      expect(find.text('Nome • '), findsOneWidget);
      expect(find.text('Luna'), findsOneWidget);
      expect(tester.getSize(find.byType(PaCampo)).height, 64);
      expect(_corBordaDaCaixa(tester, find.byType(PaCampo)), PaCores.borda);
    });

    testWidgets('digitar atualiza o controlador e chama aoMudar', (tester) async {
      final controle = TextEditingController();
      addTearDown(controle.dispose);
      String? mudou;
      await montarComponente(tester, PaCampo(rotulo: 'Nome', controller: controle, aoMudar: (v) => mudou = v));

      await tester.enterText(find.byType(TextField), 'Mia');
      expect(controle.text, 'Mia');
      expect(mudou, 'Mia');
    });

    testWidgets('tocar em qualquer parte da caixa foca o campo', (tester) async {
      final controle = TextEditingController();
      addTearDown(controle.dispose);
      await montarComponente(tester, PaCampo(rotulo: 'Nome', controller: controle));

      await tester.tapAt(tester.getRect(find.byType(PaCampo)).centerRight - const Offset(20, 0));
      await tester.pump();
      expect(tester.widget<TextField>(find.byType(TextField)).focusNode!.hasFocus, isTrue);
    });

    testWidgets('número aceita vírgula e ponto e recusa letras; sufixo depois do valor', (tester) async {
      final controle = TextEditingController();
      addTearDown(controle.dispose);
      await montarComponente(tester, PaCampo.numero(rotulo: 'Peso inicial', controller: controle, sufixo: 'kg'));

      await tester.enterText(find.byType(TextField), '5a,4');
      expect(controle.text, '5,4');
      await tester.enterText(find.byType(TextField), '5.4');
      expect(controle.text, '5.4');
      expect(find.text(' kg'), findsOneWidget);
      final esquerda = tester.getTopLeft(find.byType(PaCampo)).dx;
      expect(
        tester.getTopLeft(find.text(' kg')).dx - tester.getTopRight(find.byType(TextField)).dx,
        closeTo(0, 0.5),
        reason: 'sufixo logo depois do valor',
      );
      expect(tester.getTopLeft(find.text(' kg')).dx - esquerda, lessThan(200));
    });

    testWidgets('erro: borda e mensagem em cor de erro', (tester) async {
      final controle = TextEditingController();
      addTearDown(controle.dispose);
      await montarComponente(tester, PaCampo(rotulo: 'Nome', controller: controle, erro: 'Informe o nome.'));

      expect(_corBordaDaCaixa(tester, find.byType(PaCampo)), PaCores.erro);
      expect(tester.widget<Text>(find.text('Informe o nome.')).style!.color, PaCores.erro);
    });

    testWidgets('semântica: campo de texto com o rótulo', (tester) async {
      final controle = TextEditingController(text: 'Luna');
      addTearDown(controle.dispose);
      await montarComponente(tester, PaCampo(rotulo: 'Nome', controller: controle));

      expect(
        tester.getSemantics(find.byType(TextField)),
        isSemantics(label: 'Nome', value: 'Luna', isTextField: true),
      );
    });

    testWidgets('fonte a 200%: o rótulo não some e a caixa cresce', (tester) async {
      final controle = TextEditingController(text: 'Luna de Souza Albuquerque');
      addTearDown(controle.dispose);
      await montarComponente(tester, PaCampo(rotulo: 'Nome', controller: controle), escalaTexto: 2);

      expect(tester.takeException(), isNull);
      expect(find.text('Nome • '), findsOneWidget);
      expect(tester.getSize(find.byType(PaCampo)).height, greaterThan(64));
    });
  });

  group('PaCampoEscolha', () {
    const opcoes = [
      PaOpcao(valor: 'cao', rotulo: 'Cão'),
      PaOpcao(valor: 'gato', rotulo: 'Gato'),
    ];

    testWidgets('mostra o valor e abre um PaDialogo com a escolhida em primário', (tester) async {
      String? escolhido;
      await montarComponente(
        tester,
        PaCampoEscolha<String>(
          rotulo: 'Espécie',
          opcoes: opcoes,
          valor: 'gato',
          aoEscolher: (v) => escolhido = v,
        ),
      );
      expect(find.text('Espécie • Gato'), findsOneWidget);
      expect(tester.getSize(find.byType(PaCampoEscolha<String>)).height, 64);

      await tester.tap(find.byType(PaCampoEscolha<String>));
      await tester.pumpAndSettle();

      expect(find.byType(PaDialogo), findsOneWidget);
      PaBotao botao(String t) => tester.widget<PaBotao>(find.widgetWithText(PaBotao, t));
      expect(botao('Gato').variante, PaBotaoVariante.primario);
      expect(botao('Cão').variante, PaBotaoVariante.secundario);
      expect(botao('Voltar').variante, PaBotaoVariante.secundario);

      await tester.tap(find.widgetWithText(PaBotao, 'Cão'));
      await tester.pumpAndSettle();
      expect(escolhido, 'cao');
      expect(find.byType(PaDialogo), findsNothing);
    });

    testWidgets('"Voltar" fecha sem mudar nada', (tester) async {
      var chamadas = 0;
      await montarComponente(
        tester,
        PaCampoEscolha<String>(rotulo: 'Espécie', opcoes: opcoes, valor: null, aoEscolher: (_) => chamadas++),
      );
      await tester.tap(find.byType(PaCampoEscolha<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(PaBotao, 'Voltar'));
      await tester.pumpAndSettle();
      expect(chamadas, 0);
    });

    testWidgets('semântica: rótulo, valor e toque', (tester) async {
      await montarComponente(
        tester,
        PaCampoEscolha<String>(rotulo: 'Espécie', opcoes: opcoes, valor: 'gato', aoEscolher: (_) {}),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Espécie')),
        isSemantics(label: 'Espécie', value: 'Gato', isTextField: true, hasTapAction: true),
      );
    });
  });

  group('PaCampoData e PaCampoHora', () {
    testWidgets('data abre o seletor nativo e mostra a data curta', (tester) async {
      DateTime? escolhida;
      await montarComponente(
        tester,
        PaCampoData(
          rotulo: 'Data',
          valor: DateTime(2026, 9, 30),
          ultimaData: DateTime(2026, 9, 30),
          aoEscolher: (d) => escolhida = d,
        ),
      );
      expect(find.text('Data • 30 set. 2026'), findsOneWidget);

      await tester.tap(find.byType(PaCampoData));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('29'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(escolhida, DateTime(2026, 9, 29));
    });

    testWidgets('hora mostra HH:mm e abre o seletor nativo', (tester) async {
      await montarComponente(
        tester,
        PaCampoHora(rotulo: 'Horário', valor: const TimeOfDay(hour: 8, minute: 0), aoEscolher: (_) {}),
      );
      expect(find.text('Horário • 08:00'), findsOneWidget);

      await tester.tap(find.byType(PaCampoHora));
      await tester.pumpAndSettle();
      expect(find.byType(TimePickerDialog), findsOneWidget);
    });
  });
}
