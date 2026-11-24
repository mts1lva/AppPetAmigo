import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/tema/cores.dart';
import 'package:petamigo/core/ui/ui.dart';

import '../../apoio/montar.dart';

/// Tela com um botão que abre o diálogo e guarda o resultado.
class _Abridor<T> extends StatefulWidget {
  const _Abridor({required this.abrir});

  final Future<T?> Function(BuildContext) abrir;

  @override
  State<_Abridor<T>> createState() => _AbridorState<T>();
}

class _AbridorState<T> extends State<_Abridor<T>> {
  T? resultado;
  var fechou = false;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async {
              final r = await widget.abrir(context);
              setState(() {
                resultado = r;
                fechou = true;
              });
            },
            child: const Text('abrir'),
          ),
        ),
      );
}

/// A caixa branca do diálogo (o `Dialog` em si inclui as margens externas).
final _caixaDoDialogo = find.descendant(of: find.byType(PaDialogo), matching: find.byType(Material)).first;

Future<_AbridorState<T>> _abrir<T>(WidgetTester tester, Future<T?> Function(BuildContext) abrir) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(appDeTeste(_Abridor<T>(abrir: abrir)));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
  return tester.state<_AbridorState<T>>(find.byType(_Abridor<T>));
}

void main() {
  group('PaDialogo', () {
    testWidgets('véu de 18%, largura 350, padding 16 e ordem título → subtítulo → texto → botões', (tester) async {
      await _abrir<void>(
        tester,
        (c) => mostrarPaDialogo<void>(
          c,
          builder: (_) => PaDialogo(
            titulo: 'Confirmar exclusão',
            subtitulo: 'Ação sobre o item selecionado.',
            texto: 'Exclui apenas o item escolhido e atualiza os totais.',
            botoes: [PaBotao.primario(texto: 'Confirmar exclusão', aoTocar: () {})],
          ),
        ),
      );

      expect(tester.widget<ModalBarrier>(find.byType(ModalBarrier).last).color, PaCores.veu);
      final caixa = tester.getRect(_caixaDoDialogo);
      expect(caixa.width, 350);
      expect(caixa.left, 20);
      // Figma, tela 23: título em 16, subtítulo em 64, texto em 96.
      expect(tester.getTopLeft(find.text('Confirmar exclusão').first) - caixa.topLeft, const Offset(16, 16));
      expect(tester.getTopLeft(find.text('Ação sobre o item selecionado.')).dy - caixa.top, 64);
      expect(tester.getTopLeft(find.text('Exclui apenas o item escolhido e atualiza os totais.')).dy - caixa.top, 96);
      expect(tester.getSemantics(find.text('Confirmar exclusão').first), isSemantics(isHeader: true));
    });

    testWidgets('conteúdo maior que a tela rola dentro do diálogo', (tester) async {
      await _abrir<void>(
        tester,
        (c) => mostrarPaDialogo<void>(
          c,
          builder: (_) => PaDialogo(
            titulo: 'Dados de Luna',
            botoes: [for (var i = 0; i < 20; i++) PaBotao.secundario(texto: 'Botão $i', aoTocar: () {})],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      expect(tester.getRect(_caixaDoDialogo).height, lessThanOrEqualTo(844 - 2 * 24));
    });

    testWidgets('botão voltar do Android fecha sem resultado', (tester) async {
      final estado = await _abrir<bool>(
        tester,
        (c) => mostrarPaDialogo<bool>(c, builder: (_) => const PaDialogo(titulo: 'Seus pets')),
      );
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(PaDialogo), findsNothing);
      expect(estado.fechou, isTrue);
      expect(estado.resultado, isNull);
    });
  });

  group('confirmarExclusao (tela 23)', () {
    testWidgets('modo item: textos e "Confirmar exclusão" devolve true', (tester) async {
      final estado = await _abrir<bool>(tester, (c) => confirmarExclusao(c));

      expect(find.text('Ação sobre o item selecionado.'), findsOneWidget);
      expect(find.text('Exclui apenas o item escolhido e atualiza os totais.'), findsOneWidget);
      expect(
        tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Confirmar exclusão')).variante,
        PaBotaoVariante.primario,
      );
      expect(tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Cancelar')).variante, PaBotaoVariante.secundario,
          reason: 'P-06: Cancelar é secundário');

      await tester.tap(find.widgetWithText(PaBotao, 'Confirmar exclusão'));
      await tester.pumpAndSettle();
      expect(estado.resultado, isTrue);
    });

    testWidgets('modo integral: textos próprios', (tester) async {
      await _abrir<bool>(tester, (c) => confirmarExclusao(c, integral: true));

      expect(find.text('Ação sobre todos os dados.'), findsOneWidget);
      expect(
        find.text(
          'Remove pet, foto, metas e todos os registros deste aparelho. '
          'A remoção da cópia remota pode ficar pendente até o próximo Wi-Fi.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('"Cancelar", o véu e o botão voltar devolvem false', (tester) async {
      var estado = await _abrir<bool>(tester, (c) => confirmarExclusao(c));
      await tester.tap(find.widgetWithText(PaBotao, 'Cancelar'));
      await tester.pumpAndSettle();
      expect(estado.resultado, isFalse);

      estado = await _abrir<bool>(tester, (c) => confirmarExclusao(c));
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(estado.resultado, isFalse);

      estado = await _abrir<bool>(tester, (c) => confirmarExclusao(c));
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(estado.resultado, isFalse);
    });
  });
}
