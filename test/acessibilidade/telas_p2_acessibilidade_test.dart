// P2-4.6 — acessibilidade das telas do P2: fonte em 200% sem overflow e
// o leitor de tela lê o Diário, as linhas do histórico e os campos dos
// diálogos 07, 08, 09, 19, 20 e 22.
// A conferência com o TalkBack de verdade, no aparelho, continua manual.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/app.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_alimentos.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_atalho.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_confira_densidade.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_outra_data.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_petisco.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_refeicao.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_refeicao_salva.dart';
import 'package:petamigo/features/diario/apresentacao/telas/tela_diario.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/inicio/apresentacao/providers/sugestoes_provider.dart';
import 'package:petamigo/features/inicio/apresentacao/telas/tela_inicio.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/lembretes_provider.dart';

import '../apoio/diario_falso.dart';
import '../apoio/golden.dart';
import '../apoio/inicio_falso.dart';
import '../apoio/pets_falsos.dart';

Future<void> montarApp(WidgetTester tester, {double escala = 2, DiarioFalsos? diario}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...PetsFalsos(iniciais: [(luna(), 5.4)]).overrides,
      ...(diario ?? DiarioFalsos(alimentos: [racaoHabitual()], refeicoes: [refeicaoHabitual()], extras: [extraHabitual()]))
          .overrides,
      lembretesProvider.overrideWith((ref, petId) => Stream.value([])),
      agoraProvider.overrideWithValue(() => DateTime(2026, 9, 30, 9)),
      ultimaPesagemProvider.overrideWith(
        (ref, petId) => Stream.value(Pesagem(id: 'pes-$petId', petId: petId, pesoKg: 5.4, dataHora: DateTime(2026, 9, 1))),
      ),
      sugestoesAdiadasRepositorioProvider.overrideWithValue(AdiadasFalsas()),
    ],
    child: const PetAmigoApp(),
  ));
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => usarComparadorComTolerancia(tolerancia: 0.03));

  group('fonte em 200%: nada corta', () {
    testWidgets('02 Diário', (tester) async {
      await montarApp(tester);
      await tocar(tester, find.descendant(of: find.byType(PaNavegacao), matching: find.text('Diário')));
      expect(find.byType(TelaDiario), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('06 Registrar refeição', (tester) async {
      await montarApp(tester);
      abrirAtalho(tester.element(find.byType(TelaInicio)), petId: 'p1');
      await tester.pumpAndSettle();
      expect(find.byType(DialogoAtalho), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('07 Refeição', (tester) async {
      await montarApp(tester);
      await tocar(tester, find.descendant(of: find.byType(PaNavegacao), matching: find.text('Diário')));
      await tocar(tester, find.widgetWithText(PaBotao, botaoEditarRefeicao));
      expect(find.byType(DialogoRefeicao), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('08 Petisco ou extra', (tester) async {
      await montarApp(tester);
      abrirPetisco(tester.element(find.byType(TelaInicio)), petId: 'p1');
      await tester.pumpAndSettle();
      expect(find.byType(DialogoPetisco), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('09 Alimentos e porções', (tester) async {
      await montarApp(tester);
      abrirAlimentos(tester.element(find.byType(TelaInicio)), petId: 'p1');
      await tester.pumpAndSettle();
      expect(find.byType(DialogoAlimentos), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('19 Consultar outra data', (tester) async {
      await montarApp(tester);
      abrirOutraData(tester.element(find.byType(TelaInicio)), data: DateTime(2026, 9, 29));
      await tester.pumpAndSettle();
      expect(find.byType(DialogoOutraData), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('20 Refeição salva', (tester) async {
      await montarApp(tester);
      abrirAtalho(tester.element(find.byType(TelaInicio)), petId: 'p1');
      await tester.pumpAndSettle();
      await tocar(tester, find.widgetWithText(PaBotao, botaoConfirmarRefeicao));
      expect(find.byType(DialogoRefeicaoSalva), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('22 Confira a densidade', (tester) async {
      await montarApp(tester);
      abrirAlimentos(tester.element(find.byType(TelaInicio)), petId: 'p1');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Ração nova');
      await tester.enterText(find.byType(TextField).at(1), '0');
      await tester.enterText(find.byType(TextField).at(2), '30');
      await tocar(tester, find.widgetWithText(PaBotao, botaoSalvarAlimento));
      expect(find.byType(DialogoConfiraDensidade), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('evidência: Diário com a fonte em 200% (390 × 844 a 2x)', (tester) async {
    await montarApp(tester);
    await tocar(tester, find.descendant(of: find.byType(PaNavegacao), matching: find.text('Diário')));
    prepararTelaGolden(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(telaInteira, matchesGoldenFile('../goldens/arquivos/02-diario-fonte-200.png'));
  });

  group('leitor de tela', () {
    testWidgets('lê as linhas do histórico por extenso', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, escala: 1);
      await tocar(tester, find.descendant(of: find.byType(PaNavegacao), matching: find.text('Diário')));

      expect(
        find.bySemanticsLabel(rotuloSemanticoRefeicao(refeicaoHabitual())),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel(rotuloSemanticoExtra(extraHabitual())),
        findsOneWidget,
      );
      semantica.dispose();
    });

    testWidgets('lê os rótulos dos campos do 07', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, escala: 1);
      await tocar(tester, find.descendant(of: find.byType(PaNavegacao), matching: find.text('Diário')));
      await tocar(tester, find.widgetWithText(PaBotao, botaoEditarRefeicao));

      for (final rotulo in [
        rotuloAlimento,
        '$rotuloQuantidade ($sufixoGramas)',
        rotuloEnergia,
        rotuloData,
        rotuloHorario,
      ]) {
        expect(find.bySemanticsLabel(rotulo), findsWidgets, reason: rotulo);
      }
      semantica.dispose();
    });

    testWidgets('lê os rótulos dos campos do 08', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, escala: 1);
      abrirPetisco(tester.element(find.byType(TelaInicio)), petId: 'p1');
      await tester.pumpAndSettle();

      for (final rotulo in [
        rotuloDescricao,
        '$rotuloQuantidade ($sufixoGramas)',
        '$rotuloEnergiaInformada ($sufixoKcal)',
        rotuloData,
        rotuloHorario,
      ]) {
        expect(find.bySemanticsLabel(rotulo), findsWidgets, reason: rotulo);
      }
      semantica.dispose();
    });

    testWidgets('lê os rótulos dos campos do 09', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, escala: 1);
      abrirAlimentos(tester.element(find.byType(TelaInicio)), petId: 'p1');
      await tester.pumpAndSettle();

      for (final rotulo in [
        rotuloAlimento,
        '$rotuloDensidade ($sufixoKcalPor100g)',
        '$rotuloPorcaoReutilizavel ($sufixoGramas)',
      ]) {
        expect(find.bySemanticsLabel(rotulo), findsWidgets, reason: rotulo);
      }
      semantica.dispose();
    });

    testWidgets('lê o 19 Consultar outra data', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, escala: 1);
      abrirOutraData(tester.element(find.byType(TelaInicio)), data: DateTime(2026, 9, 29));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel(tituloOutraData), findsWidgets);
      expect(tester.getSemantics(find.text(textoSemRegistros)), isNotNull);
      expect(find.bySemanticsLabel(botaoRetomarHoje), findsWidgets);
      semantica.dispose();
    });

    testWidgets('lê o 20 Refeição salva', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, escala: 1);
      abrirAtalho(tester.element(find.byType(TelaInicio)), petId: 'p1');
      await tester.pumpAndSettle();
      await tocar(tester, find.widgetWithText(PaBotao, botaoConfirmarRefeicao));

      expect(find.bySemanticsLabel(tituloRefeicaoSalva), findsWidgets);
      expect(find.bySemanticsLabel(botaoConsultarDiarioAtualizado), findsWidgets);
      semantica.dispose();
    });

    testWidgets('lê o 22 Confira a densidade', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, escala: 1);
      abrirAlimentos(tester.element(find.byType(TelaInicio)), petId: 'p1');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).at(0), 'Ração nova');
      await tester.enterText(find.byType(TextField).at(1), '0');
      await tester.enterText(find.byType(TextField).at(2), '30');
      await tocar(tester, find.widgetWithText(PaBotao, botaoSalvarAlimento));

      expect(find.bySemanticsLabel(tituloConfiraDensidade), findsWidgets);
      expect(find.bySemanticsLabel('$rotuloDensidade ($sufixoKcalPor100g)'), findsWidgets);
      expect(find.bySemanticsLabel(botaoCorrigirValor), findsWidgets);
      semantica.dispose();
    });
  });
}
