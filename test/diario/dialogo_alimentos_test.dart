import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_alimentos.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_confira_densidade.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';

import '../apoio/diario_falso.dart';
import '../apoio/montar.dart';

Future<void> abrir(WidgetTester tester, DiarioFalsos diario, {bool paraAtalho = false}) async {
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
            onPressed: () => abrirAlimentos(context, petId: 'p1', paraAtalho: paraAtalho),
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
  group('09 Alimentos e porções', () {
    testWidgets('título, subtítulo, campos e botões do cadastro, sem excluir', (tester) async {
      await abrir(tester, DiarioFalsos());

      expect(find.text(tituloAlimentos), findsOneWidget);
      expect(find.text(subtituloAlimentos), findsOneWidget);
      expect(find.text(textoAlimentosFormulario), findsOneWidget);
      expect(find.textContaining('$rotuloAlimento • '), findsWidgets);
      expect(find.textContaining('$rotuloDensidade • '), findsOneWidget);
      expect(find.textContaining('$rotuloPorcaoReutilizavel • '), findsOneWidget);
      expect(botao(botaoSalvarAlimento), findsOneWidget);
      expect(botao(botaoExcluirAlimento), findsNothing);
      expect(botao('Voltar'), findsOneWidget);
    });

    testWidgets('atalho sem alimento usa o subtítulo de cadastro para o atalho', (tester) async {
      await abrir(tester, DiarioFalsos(), paraAtalho: true);
      expect(find.text(subtituloAlimentosAtalho), findsOneWidget);
    });

    testWidgets('salvar vazio pede o nome e a quantidade, não grava e não fecha', (tester) async {
      final diario = DiarioFalsos();
      await abrir(tester, diario);

      await tocar(tester, botao(botaoSalvarAlimento));

      expect(diario.alimentos.salvos, isEmpty);
      expect(find.byType(DialogoAlimentos), findsOneWidget);
      expect(find.text(mensagemInformeNome), findsOneWidget);
      expect(find.text(mensagemQuantidadePositiva), findsOneWidget);
    });

    testWidgets('densidade 0 abre o 22 sem gravar; Corrigir valor volta ao 09', (tester) async {
      final diario = DiarioFalsos();
      await abrir(tester, diario);

      await tester.enterText(find.byType(TextField).at(0), 'Ração habitual');
      await tester.enterText(find.byType(TextField).at(1), '0');
      await tester.enterText(find.byType(TextField).at(2), '30');
      await tocar(tester, botao(botaoSalvarAlimento));

      expect(diario.alimentos.salvos, isEmpty);
      expect(find.byType(DialogoConfiraDensidade), findsOneWidget);
      expect(find.text(tituloConfiraDensidade), findsOneWidget);
      expect(find.text(subtituloConfiraDensidade), findsOneWidget);
      expect(find.text(textoConfiraDensidade), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      await tocar(tester, botao(botaoCorrigirValor));

      expect(find.byType(DialogoAlimentos), findsOneWidget);
      expect(find.text('Ração habitual'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField).at(1)).focusNode!.hasFocus,
        isTrue,
        reason: 'o foco volta para a densidade',
      );
    });

    testWidgets('preencher e salvar grava o alimento e fecha', (tester) async {
      final diario = DiarioFalsos();
      await abrir(tester, diario);

      await tester.enterText(find.byType(TextField).at(0), 'Ração habitual');
      await tester.enterText(find.byType(TextField).at(1), '360');
      await tester.enterText(find.byType(TextField).at(2), '30');
      await tocar(tester, botao(botaoSalvarAlimento));

      expect(diario.alimentos.salvos, hasLength(1));
      final a = diario.alimentos.salvos.single;
      expect((a.petId, a.nome, a.densidadeKcalPor100g, a.porcaoPadraoG), ('p1', 'Ração habitual', 360, 30));
      expect(find.byType(DialogoAlimentos), findsNothing);
    });

    testWidgets('editar: preenche, excluir abre o 23 e arquiva', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()]);
      await abrir(tester, diario);

      await tocar(tester, find.text('Alimento • $rotuloNovoAlimento'));
      await tocar(tester, botao('Ração habitual'));

      expect(find.text('360'), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
      expect(botao(botaoExcluirAlimento), findsOneWidget);

      await tocar(tester, botao(botaoExcluirAlimento));
      expect(find.text('Confirmar exclusão'), findsWidgets);
      await tocar(tester, botao('Confirmar exclusão'));

      expect(diario.alimentos.arquivados, ['a1']);
      expect(find.byType(DialogoAlimentos), findsNothing);
    });
  });
}
