import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/tema/cores.dart';
import 'package:petamigo/core/ui/ui.dart';

import '../../apoio/montar.dart';

Future<void> _montar(WidgetTester tester, {int ativo = 0, ValueChanged<int>? aoSelecionar, double escala = 1}) {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  return tester.pumpWidget(
    appDeTeste(
      Scaffold(
        bottomNavigationBar: PaNavegacao(indiceAtual: ativo, aoSelecionar: aoSelecionar ?? (_) {}),
      ),
      escalaTexto: escala,
    ),
  );
}

void main() {
  group('PaNavegacao', () {
    testWidgets('4 destinos na ordem, barra de 72 e itens de 87 × 56 no frame de 390', (tester) async {
      await _montar(tester);

      for (final d in ['Início', 'Diário', 'Atividades', 'Evolução']) {
        expect(find.text(d), findsOneWidget);
      }
      expect(tester.getSize(find.byType(PaNavegacao)).height, 72);
      final itens = find.descendant(of: find.byType(PaNavegacao), matching: find.byType(Material));
      expect(itens, findsNWidgets(4));
      expect(tester.getSize(itens.first), const Size(87.5, 56));
      expect(tester.getTopLeft(itens.at(1)).dx - tester.getTopRight(itens.at(0)).dx, 8);
    });

    testWidgets('ativo com fundo suave; inativos com superfície; sem ícones', (tester) async {
      await _montar(tester, ativo: 2);

      final itens = find.descendant(of: find.byType(PaNavegacao), matching: find.byType(Material));
      final cores = [for (var i = 0; i < 4; i++) tester.widget<Material>(itens.at(i)).color];
      expect(cores, [PaCores.superficie, PaCores.superficie, PaCores.suave, PaCores.superficie]);
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('toque informa o índice', (tester) async {
      int? escolhido;
      await _montar(tester, aoSelecionar: (i) => escolhido = i);
      await tester.tap(find.text('Evolução'));
      expect(escolhido, 3);
    });

    testWidgets('TalkBack: os 4 destinos são botões e o ativo está "selecionado"', (tester) async {
      await _montar(tester, ativo: 1);

      expect(
        tester.getSemantics(find.text('Diário')),
        isSemantics(label: 'Diário', isButton: true, hasSelectedState: true, isSelected: true, hasTapAction: true),
      );
      for (final d in ['Início', 'Atividades', 'Evolução']) {
        expect(
          tester.getSemantics(find.text(d)),
          isSemantics(label: d, isButton: true, hasSelectedState: true, isSelected: false),
        );
      }
    });

    testWidgets('fonte a 200%: a barra cresce em altura em vez de cortar', (tester) async {
      await _montar(tester, escala: 2);
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(PaNavegacao)).height, greaterThan(72));
    });
  });
}
