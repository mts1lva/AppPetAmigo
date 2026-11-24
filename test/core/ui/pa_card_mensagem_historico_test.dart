import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/tema/cores.dart';
import 'package:petamigo/app/tema/tipografia.dart';
import 'package:petamigo/core/ui/ui.dart';

import '../../apoio/montar.dart';

Color _fundoDoCard(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(of: find.byType(PaCard), matching: find.byType(Container)).first,
  );
  return (container.decoration! as BoxDecoration).color!;
}

void main() {
  group('PaCard', () {
    testWidgets('padrão: superfície, título "secao", texto a partir de y 49, botão depois + 12', (tester) async {
      await montarComponente(
        tester,
        PaCard(
          titulo: 'Seu controle',
          texto: 'Dados salvos neste aparelho.',
          filhos: [PaBotao.secundario(texto: 'Privacidade e cópia remota', aoTocar: () {})],
        ),
      );

      expect(_fundoDoCard(tester), PaCores.superficie);
      expect(tester.widget<Text>(find.text('Seu controle')).style, PaTexto.secao);
      final topo = tester.getTopLeft(find.byType(PaCard)).dy;
      expect(tester.getTopLeft(find.text('Dados salvos neste aparelho.')).dy - topo, 49);
      expect(tester.getTopLeft(find.byType(PaBotao)).dy - topo, 83);
      // Figma: card "Seu controle" com 147 de altura.
      expect(tester.getSize(find.byType(PaCard)).height, 147);
    });

    testWidgets('destaque: fundo suave', (tester) async {
      await montarComponente(tester, const PaCard(titulo: 'Hoje · 30 set.', variante: PaCardVariante.destaque));
      expect(_fundoDoCard(tester), PaCores.suave);
    });

    testWidgets('título é cabeçalho para o leitor de tela', (tester) async {
      await montarComponente(tester, const PaCard(titulo: 'Referência alimentar'));
      expect(tester.getSemantics(find.text('Referência alimentar')), isSemantics(isHeader: true));
    });

    testWidgets('fonte a 200%: cresce sem cortar', (tester) async {
      await montarComponente(
        tester,
        PaCard(
          titulo: 'Referência alimentar',
          texto: 'Meta de hoje: 397 kcal (≈ 110 g de Ração habitual)',
          filhos: [PaBotao.secundario(texto: 'Entender a referência', aoTocar: () {})],
        ),
        escalaTexto: 2,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('PaMensagem', () {
    testWidgets('as três variantes têm a mesma caixa (altura mínima 62) e só mudam o texto', (tester) async {
      for (final estado in PaMensagemEstado.values) {
        await montarComponente(tester, PaMensagem(estado: estado));
        expect(find.text(estado.texto), findsOneWidget);
        expect(tester.getSize(find.byType(PaMensagem)).height, 62);
        final decoracao = tester.widget<Container>(find.byType(Container)).decoration! as BoxDecoration;
        expect(decoracao.color, PaCores.superficie);
        expect((decoracao.border! as Border).top.color, PaCores.borda);
      }
      expect(PaMensagemEstado.values.map((e) => e.texto), ['pendente', 'sincronizado', 'falha']);
    });

    testWidgets('fonte a 200%: cresce', (tester) async {
      await montarComponente(tester, const PaMensagem(estado: PaMensagemEstado.sincronizado), escalaTexto: 2);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PaMensagem)).height, greaterThanOrEqualTo(62));
    });
  });

  group('PaHistorico', () {
    testWidgets('altura mínima 48, toque na largura toda e linhas sem espaço extra', (tester) async {
      final tocadas = <String>[];
      await montarComponente(
        tester,
        Column(
          children: [
            PaHistorico(texto: '08:00 • Ração habitual • 30 g • 108 kcal', aoTocar: () => tocadas.add('a')),
            PaHistorico(texto: '20:00 • Ração habitual • 30 g • 108 kcal', aoTocar: () => tocadas.add('b')),
          ],
        ),
      );

      final primeira = tester.getRect(find.byType(PaHistorico).first);
      final segunda = tester.getRect(find.byType(PaHistorico).last);
      expect(primeira.height, 48);
      expect(primeira.width, 350);
      expect(segunda.top, primeira.bottom);

      await tester.tapAt(primeira.centerRight - const Offset(4, 0));
      expect(tocadas, ['a']);
    });

    testWidgets('semântica: botão com o rótulo por extenso', (tester) async {
      await montarComponente(
        tester,
        PaHistorico(
          texto: '08:00 • Ração habitual • 30 g • 108 kcal',
          rotuloSemantico: 'Editar registro: 08:00, Ração habitual, 30 gramas, 108 quilocalorias',
          aoTocar: () {},
        ),
      );
      expect(
        tester.getSemantics(find.byType(PaHistorico)),
        isSemantics(
          label: 'Editar registro: 08:00, Ração habitual, 30 gramas, 108 quilocalorias',
          isButton: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('fonte a 200%: cresce e quebra linha', (tester) async {
      await montarComponente(
        tester,
        PaHistorico(texto: '08:00 • Ração habitual • 30 g • 108 kcal', aoTocar: () {}),
        escalaTexto: 2,
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PaHistorico)).height, greaterThan(48));
    });
  });
}
