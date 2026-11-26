// P4-1.4 — Gráfico interativo (U2-02): séries, balão sob o dedo, texto
// alternativo (R07), estado vazio (M10) e golden do componente.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/evolucao/apresentacao/widgets/grafico_evolucao.dart';
import 'package:petamigo/features/evolucao/domain/curva_ideal.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/grafico_dados.dart';
import 'package:petamigo/features/evolucao/domain/projecao.dart';

import '../apoio/montar.dart';

final hoje = DateTime(2026, 9, 30, 9);

final pesagensLuna = [
  Pesagem(id: 'w1', petId: 'p1', pesoKg: 5.6, dataHora: DateTime(2026, 9, 16, 8)),
  Pesagem(id: 'w2', petId: 'p1', pesoKg: 5.5, dataHora: DateTime(2026, 9, 23, 8)),
  Pesagem(id: 'w3', petId: 'p1', pesoKg: 5.4, dataHora: DateTime(2026, 9, 30, 8)),
];

/// Luna com ECC 7 (Pi 4,5) e projeção só pelas pesagens.
GraficoDados dadosLuna({List<Pesagem>? pesagens, bool comIdeal = true}) {
  final ps = pesagens ?? pesagensLuna;
  final proj = projecao(pesagens: ps, ingestaoPorDia: const {}, atividadeKcalPorDia: 0, mer: null, hoje: hoje);
  final r = montarGrafico(
    pesagens: ps,
    projecao: proj.valorOuNulo?.curva,
    curvaIdeal: comIdeal ? curvaIdeal(p0: ps.last.pesoKg, pi: 4.5).valorOuNulo : null,
    pesoIdealKg: comIdeal ? 4.5 : null,
    hoje: hoje,
    nomePet: 'Luna',
  );
  return (r as Disponivel<GraficoDados>).valor;
}

Future<void> montarWidget(WidgetTester tester, GraficoDados dados, {String alt = 'texto alternativo'}) =>
    montarComponente(tester, GraficoEvolucao(dados: dados, textoAlternativo: alt), largura: 326);

/// O `CustomPaint` do [PintorGrafico].
final areaDoGrafico = find.byWidgetPredicate((w) => w is CustomPaint && w.painter is PintorGrafico);

/// Ponto do gráfico na tela para o [dia].
Offset noDia(WidgetTester tester, GraficoDados dados, DateTime dia) {
  final area = tester.getRect(areaDoGrafico);
  return Offset(area.left + 2 + dados.fracaoX(dia) * (area.width - 2), area.center.dy);
}

void main() {
  group('texto alternativo (R07)', () {
    test('pesagens, peso ideal, projeção e previsão', () {
      expect(
        textoAlternativoGrafico(dadosLuna(), previsao: '28 nov. 2026'),
        '16 set. 5,6 kg → 23 set. 5,5 kg → 30 set. 5,4 kg\n'
        'Peso ideal 4,5 kg • Projeção para 29 dez.: 4,1 kg\n'
        'Previsão para o peso ideal: 28 nov. 2026',
      );
    });

    test('lacuna de mais de 14 dias ganha uma linha', () {
      final ps = [
        Pesagem(id: 'a', petId: 'p1', pesoKg: 5.6, dataHora: DateTime(2026, 9, 5)),
        Pesagem(id: 'b', petId: 'p1', pesoKg: 5.4, dataHora: DateTime(2026, 9, 30)),
      ];
      expect(textoAlternativoGrafico(dadosLuna(pesagens: ps, comIdeal: false)), endsWith('Sem pesagens entre 05 set. e 30 set.'));
    });
  });

  group('GraficoEvolucao', () {
    testWidgets('legenda e texto alternativo visíveis; o desenho fica fora da acessibilidade', (tester) async {
      await montarWidget(tester, dadosLuna(), alt: 'alt da Luna');

      expect(find.text(GraficoEvolucao.legenda), findsOneWidget);
      expect(find.text('── pesagens   - - projeção   ··· curva ideal'), findsOneWidget);
      expect(find.text('alt da Luna'), findsOneWidget);
      expect(tester.getSize(areaDoGrafico).height, GraficoEvolucao.altura);
      expect(find.bySemanticsLabel('alt da Luna'), findsOneWidget);
    });

    testWidgets('tocar no dia 30 set. mostra a pesagem; 27 set. a estimativa; futuro, projeção e ideal',
        (tester) async {
      final dados = dadosLuna();
      await montarWidget(tester, dados);

      await tester.tapAt(noDia(tester, dados, DateTime(2026, 9, 30)));
      await tester.pump();
      expect(find.text('30 set. • 5,4 kg (pesagem)'), findsOneWidget);

      await tester.tapAt(noDia(tester, dados, DateTime(2026, 9, 27)));
      await tester.pump();
      expect(find.text('27 set. • ≈ 5,44 kg (estimado)'), findsOneWidget);

      await tester.tapAt(noDia(tester, dados, DateTime(2026, 11, 15)));
      await tester.pump();
      expect(find.textContaining(RegExp(r'^15 nov\. • Projeção .* kg • Ideal .* kg$')), findsOneWidget);
      await tester.pump(GraficoEvolucao.tempoBalao);
    });

    testWidgets('arrastar acompanha o dedo; ao soltar, o balão some em 2 s e é anunciado', (tester) async {
      final anuncios = <String>[];
      tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        (mensagem) async {
          final dados = (mensagem as Map)['data'] as Map;
          anuncios.add(dados['message'] as String);
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockDecodedMessageHandler<dynamic>(SystemChannels.accessibility, null),
      );

      final dados = dadosLuna();
      await montarWidget(tester, dados);

      final gesto = await tester.startGesture(noDia(tester, dados, DateTime(2026, 9, 16)));
      await tester.pump();
      await gesto.moveTo(noDia(tester, dados, DateTime(2026, 9, 23)));
      await tester.pump();
      expect(find.text('23 set. • 5,5 kg (pesagem)'), findsOneWidget);
      await gesto.up();
      await tester.pump();

      expect(anuncios, ['23 set. • 5,5 kg (pesagem)']);
      expect(find.text('23 set. • 5,5 kg (pesagem)'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1900));
      expect(find.text('23 set. • 5,5 kg (pesagem)'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('23 set. • 5,5 kg (pesagem)'), findsNothing);
    });

    testWidgets('o balão perto da borda direita fica dentro da área', (tester) async {
      final dados = dadosLuna();
      await montarWidget(tester, dados);

      await tester.tapAt(noDia(tester, dados, DateTime(2026, 12, 26)));
      await tester.pump();
      final area = tester.getRect(areaDoGrafico);
      final balao = tester.getRect(find.ancestor(of: find.textContaining('Projeção'), matching: find.byType(Container)).first);
      expect(balao.right, lessThanOrEqualTo(area.right));
      expect(balao.left, greaterThanOrEqualTo(area.left));
      await tester.pump(GraficoEvolucao.tempoBalao);
    });

    testWidgets('uma pesagem só: desenha o ponto, sem exceção', (tester) async {
      await montarWidget(tester, dadosLuna(pesagens: [pesagensLuna.last], comIdeal: false));
      expect(tester.takeException(), isNull);
    });
  });

  group('estado vazio (M10)', () {
    test('sem pesagens: indisponível com o texto, nada é desenhado', () {
      final r = montarGrafico(pesagens: const [], projecao: null, curvaIdeal: null, pesoIdealKg: null, hoje: hoje, nomePet: 'Luna');
      expect(r, const Indisponivel<GraficoDados>('Ainda não há pesagens de Luna. Registre a primeira para ver o gráfico.'));
    });

    testWidgets('gato, texto e "Registrar peso"', (tester) async {
      var tocou = false;
      await montarComponente(tester, GraficoVazio(nomePet: 'Luna', aoRegistrarPeso: () => tocou = true));

      expect(find.byType(PaGatoSorrindo), findsOneWidget);
      expect(find.text('Ainda não há pesagens de Luna. Registre a primeira para ver o gráfico.'), findsOneWidget);
      await tester.tap(find.widgetWithText(PaBotao, 'Registrar peso'));
      expect(tocou, isTrue);
    });
  });
}
