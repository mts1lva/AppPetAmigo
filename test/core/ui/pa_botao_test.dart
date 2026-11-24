import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/tema/cores.dart';
import 'package:petamigo/core/ui/ui.dart';

import '../../apoio/montar.dart';

ShapeBorder _forma(WidgetTester tester) =>
    tester.widget<Material>(find.descendant(of: find.byType(PaBotao), matching: find.byType(Material))).shape!;

Color _fundo(WidgetTester tester) =>
    tester.widget<Material>(find.descendant(of: find.byType(PaBotao), matching: find.byType(Material))).color!;

Color _corBorda(WidgetTester tester) => ((_forma(tester) as RoundedRectangleBorder).side).color;

void main() {
  group('PaBotao', () {
    testWidgets('altura mínima 52, largura total e texto à esquerda com padding 12', (tester) async {
      await montarComponente(tester, PaBotao.secundario(texto: 'Editar pet', aoTocar: () {}));

      final caixa = tester.getRect(find.byType(PaBotao));
      expect(caixa.height, 52);
      expect(caixa.width, 350);
      expect(tester.getTopLeft(find.text('Editar pet')).dx - caixa.left, 12);
      expect(tester.getCenter(find.text('Editar pet')).dy, closeTo(caixa.center.dy, 0.5));
    });

    testWidgets('variantes: primário verde com texto branco; secundário e perigo brancos com bordas', (tester) async {
      await montarComponente(tester, PaBotao.primario(texto: 'Salvar pet', aoTocar: () {}));
      expect(_fundo(tester), PaCores.verde);
      expect(_corBorda(tester), PaCores.verde);
      expect(tester.widget<Text>(find.text('Salvar pet')).style!.color, PaCores.superficie);

      await montarComponente(tester, PaBotao.secundario(texto: 'Voltar', aoTocar: () {}));
      expect(_fundo(tester), PaCores.superficie);
      expect(_corBorda(tester), PaCores.borda);
      expect(tester.widget<Text>(find.text('Voltar')).style!.color, PaCores.texto);

      await montarComponente(tester, PaBotao.perigo(texto: 'Excluir registro', aoTocar: () {}));
      expect(_fundo(tester), PaCores.superficie);
      expect(_corBorda(tester), PaCores.erro);
    });

    testWidgets('toque chama o callback', (tester) async {
      var toques = 0;
      await montarComponente(tester, PaBotao.primario(texto: 'Salvar pet', aoTocar: () => toques++));
      await tester.tap(find.byType(PaBotao));
      expect(toques, 1);
    });

    testWidgets('desabilitado: 40% de opacidade e sem toque', (tester) async {
      await montarComponente(tester, const PaBotao.primario(texto: 'Salvar pet', aoTocar: null));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0.4);
      expect(
        tester.getSemantics(find.byType(PaBotao)),
        isSemantics(label: 'Salvar pet', isButton: true, hasEnabledState: true, isEnabled: false),
      );
    });

    testWidgets('carregando: mostra "Salvando…" e bloqueia novo toque', (tester) async {
      var toques = 0;
      await montarComponente(
        tester,
        PaBotao.primario(texto: 'Salvar pet', aoTocar: () => toques++, carregando: true),
      );
      expect(find.text('Salvando…'), findsOneWidget);
      expect(find.text('Salvar pet'), findsNothing);
      await tester.tap(find.byType(PaBotao));
      expect(toques, 0);
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
    });

    testWidgets('semântica: botão com o rótulo e ação de toque', (tester) async {
      await montarComponente(tester, PaBotao.secundario(texto: 'Editar pet', aoTocar: () {}));
      expect(
        tester.getSemantics(find.byType(PaBotao)),
        isSemantics(
          label: 'Editar pet',
          isButton: true,
          hasEnabledState: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('fonte a 200%: cresce em altura e quebra linha, sem cortar', (tester) async {
      await montarComponente(
        tester,
        PaBotao.secundario(texto: 'Privacidade e cópia remota do aparelho', aoTocar: () {}),
        escalaTexto: 2,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PaBotao)).height, greaterThan(52));
      final texto = tester.getRect(find.text('Privacidade e cópia remota do aparelho'));
      expect(tester.getRect(find.byType(PaBotao)).contains(texto.bottomRight - const Offset(1, 1)), isTrue);
    });
  });
}
