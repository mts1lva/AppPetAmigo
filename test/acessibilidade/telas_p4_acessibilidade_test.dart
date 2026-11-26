// P4-4.6 — acessibilidade das telas do P4 (04, 11, 12, 25 e N3;
// `pacote-4` → Critérios e `design-system.md` → Gráfico interativo):
// - com a fonte do sistema em 200%, nada corta (o Flutter acusa qualquer
//   "overflow" como erro do teste), inclusive o balão do gráfico;
// - o leitor de tela (TalkBack) lê o texto alternativo do gráfico e não o
//   desenho, os títulos dos cards como cabeçalhos e os rótulos dos campos.
// A conferência com o TalkBack de verdade, no aparelho, continua manual.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/tema/cores.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/evolucao/apresentacao/telas/dialogo_pesagem_salva.dart';
import 'package:petamigo/features/evolucao/apresentacao/telas/tela_evolucao.dart';
import 'package:petamigo/features/evolucao/apresentacao/widgets/grafico_evolucao.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pet_atual_provider.dart';

import '../apoio/evolucao_falsa.dart';
import '../apoio/golden.dart';
import '../apoio/montar.dart';

final hoje = DateTime(2026, 9, 30, 9);

Pesagem pesagem(String id, double kg, DateTime data) => Pesagem(id: id, petId: 'p1', pesoKg: kg, dataHora: data);

final pesagensLuna = [
  pesagem('w1', 5.6, DateTime(2026, 9, 16, 8)),
  pesagem('w2', 5.5, DateTime(2026, 9, 23, 8)),
  pesagem('w3', 5.4, DateTime(2026, 9, 30, 8)),
];

final ecc7 = Referencia(id: 'r1', petId: 'p1', ecc: 7, origem: OrigemReferencia.veterinario, data: DateTime(2026, 9, 30));

/// A aba Evolução em 390 × 844 dp, com a fonte do sistema em [escala].
Future<void> montarEvolucao(WidgetTester tester, {double escala = 2, List<Pesagem>? pesagens}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...EvolucaoFalsa(pesagens: pesagens ?? pesagensLuna, referencia: ecc7, agora: hoje).overrides,
      petAtualIdProvider.overrideWith((ref) => Stream.value('p1')),
    ],
    child: appDeTeste(
      Scaffold(
        backgroundColor: PaCores.fundo,
        body: const TelaEvolucao(),
        bottomNavigationBar: PaNavegacao(indiceAtual: 3, aoSelecionar: (_) {}),
      ),
      escalaTexto: escala,
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

Finder botao(String texto) => find.widgetWithText(PaBotao, texto);

/// Rola a tela inteira até o fim, conferindo que nada corta no caminho.
Future<void> rolarAteOFim(WidgetTester tester) async {
  await tester.dragUntilVisible(find.text('Você escolhe quando compartilhar.'), find.byType(SingleChildScrollView).first, const Offset(0, -200));
  await tester.pumpAndSettle();
}

void main() {
  group('fonte em 200%: nada corta', () {
    testWidgets('04 Evolução com 3 pesagens, rolando até o fim', (tester) async {
      await montarEvolucao(tester);
      await rolarAteOFim(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('04 Evolução sem pesagens (estado vazio)', (tester) async {
      await montarEvolucao(tester, pesagens: const []);
      await rolarAteOFim(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('balão do gráfico perto das duas bordas', (tester) async {
      await montarEvolucao(tester);
      final area = tester.getRect(find.byType(GraficoEvolucao));
      for (final x in [area.left + 4, area.right - 4]) {
        await tester.tapAt(Offset(x, area.top + 60));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }
      await tester.pump(GraficoEvolucao.tempoBalao);
    });

    testWidgets('11 Pesagem, 25 Conferir pesagem e 23', (tester) async {
      await montarEvolucao(tester);
      await tocar(tester, botao('Registrar peso').last);
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextField), '54');
      await tocar(tester, botao('Salvar peso'));
      expect(find.text('Conferir pesagem'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tocar(tester, botao('Voltar').last);

      await tocar(tester, botao('Voltar').last);
      await tocar(tester, botao('Editar pesagem'));
      await tocar(tester, botao('Excluir registro'));
      expect(find.text('Confirmar exclusão'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('12 ECC e objetivo', (tester) async {
      await montarEvolucao(tester);
      await tocar(tester, botao('Atualizar referências'));
      expect(find.text('ECC e objetivo'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('N3 Pesagem salva', (tester) async {
      await tester.binding.setSurfaceSize(const Size(390, 844));
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(appDeTeste(Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => abrirPesagemSalva(context, celebracao: 'Luna chegou 100 g mais perto do peso ideal!'),
            child: const Text('abrir'),
          ),
        ),
      ), escalaTexto: 2));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      expect(find.text('Pesagem salva'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('evidência: 04 Evolução com a fonte em 200% (390 × 844 a 2x)', (tester) async {
    await montarEvolucao(tester);
    prepararTelaGolden(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(telaInteira, matchesGoldenFile('../goldens/arquivos/04-evolucao-fonte-200.png'));
  });

  group('leitor de tela', () {
    testWidgets('lê o texto alternativo do gráfico; o desenho e a legenda ficam de fora', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarEvolucao(tester, escala: 1);

      expect(find.bySemanticsLabel(RegExp(r'^16 set\. 5,6 kg → 23 set\. 5,5 kg → 30 set\. 5,4 kg')), findsOneWidget);
      expect(find.bySemanticsLabel('pesagens'), findsNothing, reason: 'legenda é desenho + palavra, já dita no texto');
      expect(find.bySemanticsLabel('hoje'), findsNothing, reason: 'rótulos do desenho não são lidos');
      semantica.dispose();
    });

    testWidgets('títulos dos cards são cabeçalhos', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarEvolucao(tester, escala: 1);

      for (final titulo in ['Evolução', 'Indicadores', 'Última pesagem']) {
        expect(tester.getSemantics(find.text(titulo).first), isSemantics(label: titulo, isHeader: true), reason: titulo);
      }
      semantica.dispose();
    });

    testWidgets('lê os rótulos dos campos do 11, do 25 e do 12', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarEvolucao(tester, escala: 1);

      await tocar(tester, botao('Registrar peso').last);
      for (final rotulo in ['Peso (kg)', 'Data', 'Horário']) {
        expect(find.bySemanticsLabel(rotulo), findsOneWidget, reason: rotulo);
      }
      await tester.enterText(find.byType(TextField), '54');
      await tocar(tester, botao('Salvar peso'));
      expect(find.bySemanticsLabel('Peso informado'), findsOneWidget);
      await tocar(tester, botao('Voltar').last);
      await tocar(tester, botao('Voltar').last);

      await tocar(tester, botao('Atualizar referências'));
      for (final rotulo in ['ECC informado', 'Objetivo (kg)', 'Origem', 'Data']) {
        expect(find.bySemanticsLabel(rotulo), findsOneWidget, reason: rotulo);
      }
      semantica.dispose();
    });

    testWidgets('alvos de toque com o tamanho mínimo do Android', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarEvolucao(tester, escala: 1);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      semantica.dispose();
    });
  });
}
