import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_refeicao.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';

import '../apoio/diario_falso.dart';
import '../apoio/montar.dart';

Future<void> abrir(
  WidgetTester tester,
  DiarioFalsos diario, {
  String? refeicaoId,
  String? alimentoId,
  double? quantidadeG,
  bool focarQuantidade = false,
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...diario.overrides,
      agoraProvider.overrideWithValue(() => DateTime(2026, 9, 30, 9)),
    ],
    child: appDeTeste(Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => abrirRefeicao(
              context,
              petId: 'p1',
              refeicaoId: refeicaoId,
              alimentoId: alimentoId,
              quantidadeG: quantidadeG,
              focarQuantidade: focarQuantidade,
            ),
            child: const Text('abrir'),
          ),
        ),
      ),
    )),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

Finder botao(String texto) => find.widgetWithText(PaBotao, texto);

void main() {
  group('07 Refeição', () {
    testWidgets('título, campos na ordem e sem excluir no cadastro', (tester) async {
      await abrir(tester, DiarioFalsos(alimentos: [racaoHabitual()]));

      expect(find.text(tituloRefeicao), findsOneWidget);
      expect(find.text(subtituloRefeicao), findsOneWidget);
      final rotulos = [
        '$rotuloAlimento • ',
        '$rotuloQuantidade • ',
        '$rotuloEnergia • ',
        '$rotuloData • ',
        '$rotuloHorario • ',
      ];
      final ys = [for (final r in rotulos) tester.getTopLeft(find.textContaining(r).first).dy];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(botao(botaoSalvarRefeicao), findsOneWidget);
      expect(botao(botaoExcluirRegistro), findsNothing);
      expect(botao('Voltar'), findsOneWidget);
    });

    testWidgets('R01 recalcula a energia enquanto digita (30 g → 108 kcal)', (tester) async {
      await abrir(tester, DiarioFalsos(alimentos: [racaoHabitual()]), alimentoId: 'a1');

      await tester.enterText(find.byType(TextField).first, '30');
      await tester.pump();
      expect(find.textContaining('108 kcal $textoEnergiaRotuloSufixo'), findsOneWidget);
    });

    testWidgets('salvar sem quantidade mostra o erro e não grava', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()]);
      await abrir(tester, diario, alimentoId: 'a1');

      await tocar(tester, botao(botaoSalvarRefeicao));
      expect(diario.refeicoes.salvas, isEmpty);
      expect(find.text(mensagemQuantidadePositiva), findsOneWidget);
      expect(find.byType(DialogoRefeicao), findsOneWidget);
    });

    testWidgets('preencher e salvar grava 30 g / 108 kcal e fecha', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()]);
      await abrir(tester, diario, alimentoId: 'a1');

      await tester.enterText(find.byType(TextField).first, '30');
      await tocar(tester, botao(botaoSalvarRefeicao));

      expect(diario.refeicoes.salvas, hasLength(1));
      final r = diario.refeicoes.salvas.single;
      expect((r.alimentoNome, r.quantidadeG, r.energiaKcal, r.densidadeKcalPor100g), ('Ração habitual', 30, 108, 360));
      expect(find.byType(DialogoRefeicao), findsNothing);
    });

    testWidgets('editar preenche, excluir confirma e remove', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()], refeicoes: [refeicaoHabitual()]);
      await abrir(tester, diario, refeicaoId: 'r1');

      expect(find.text('30'), findsOneWidget);
      expect(find.textContaining('108 kcal'), findsOneWidget);
      expect(botao(botaoExcluirRegistro), findsOneWidget);

      await tocar(tester, botao(botaoExcluirRegistro));
      expect(find.text('Confirmar exclusão'), findsWidgets);
      await tocar(tester, botao('Confirmar exclusão'));
      expect(diario.refeicoes.excluidas, ['r1']);
      expect(find.byType(DialogoRefeicao), findsNothing);
    });

    testWidgets('Outra quantidade: foco no campo Quantidade', (tester) async {
      await abrir(
        tester,
        DiarioFalsos(alimentos: [racaoHabitual()]),
        alimentoId: 'a1',
        quantidadeG: 30,
        focarQuantidade: true,
      );
      expect(tester.widget<TextField>(find.byType(TextField).first).focusNode!.hasFocus, isTrue);
    });
  });
}
