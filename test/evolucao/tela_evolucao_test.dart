// P4-1.5 — Tela 04 Evolução com o card Indicadores.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/evolucao/apresentacao/telas/tela_evolucao.dart';
import 'package:petamigo/features/evolucao/apresentacao/widgets/grafico_evolucao.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pet_atual_provider.dart';

import '../apoio/evolucao_falsa.dart';
import '../apoio/montar.dart';

final hoje = DateTime(2026, 9, 30, 9);

Pesagem pesagem(String id, double kg, DateTime data) => Pesagem(id: id, petId: 'p1', pesoKg: kg, dataHora: data);

final pesagensLuna = [
  pesagem('w1', 5.6, DateTime(2026, 9, 16, 8)),
  pesagem('w2', 5.5, DateTime(2026, 9, 23, 8)),
  pesagem('w3', 5.4, DateTime(2026, 9, 30, 8)),
];

final ecc7 = Referencia(id: 'r1', petId: 'p1', ecc: 7, origem: OrigemReferencia.veterinario, data: DateTime(2026, 9, 30));

Future<void> abrir(WidgetTester tester, EvolucaoFalsa dados) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...dados.overrides,
      petAtualIdProvider.overrideWith((ref) => Stream.value('p1')),
    ],
    child: appDeTeste(const Scaffold(body: TelaEvolucao())),
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

void main() {
  testWidgets('Luna com ECC 7: indicadores, gráfico, últimas pesagens e referências', (tester) async {
    await abrir(tester, EvolucaoFalsa(pesagens: pesagensLuna, referencia: ecc7, agora: hoje));

    expect(find.text('Evolução'), findsOneWidget);
    expect(find.text('Peso é uma parte do acompanhamento.'), findsOneWidget);
    expect(find.byType(GraficoEvolucao), findsOneWidget);
    expect(find.textContaining('16 set. 5,6 kg → 23 set. 5,5 kg → 30 set. 5,4 kg'), findsOneWidget);

    expect(
      find.text('Peso atual • 5,4 kg\n'
          'Peso ideal • 4,5 kg (estimado pelo ECC 7)\n'
          'Evolução • 18% do caminho\n'
          'Aderência ao plano • Sem registros nos últimos 14 dias.\n'
          'Previsão • 02 dez. 2026'),
      findsOneWidget,
    );
    expect(find.text('Estimativa educativa. Não substitui a avaliação do veterinário.'), findsOneWidget);

    expect(find.text('5,4 kg • 30 set. 2026\nAnterior: 5,5 kg • 23 set.'), findsOneWidget);
    expect(botao('Editar pesagem'), findsOneWidget);
    expect(find.text('Pesagens anteriores'), findsOneWidget);
    expect(find.text('5,6 kg • 16 set. 2026 • peso inicial'), findsOneWidget);

    expect(find.text('Uma mudança não define melhora.'), findsOneWidget);
    expect(find.text('ECC 7 de 9 • Objetivo não informado\nInformado por Veterinário / consulta em 30 set. 2026.'),
        findsOneWidget);
    expect(find.text('Você escolhe quando compartilhar.'), findsOneWidget);
  });

  testWidgets('sem pesagens: estado vazio, sem "Editar pesagem" e sem exceção (U2-07)', (tester) async {
    await abrir(tester, EvolucaoFalsa(agora: hoje));

    expect(find.byType(GraficoVazio), findsOneWidget);
    expect(find.text('Ainda não há pesagens de Luna. Registre a primeira para ver o gráfico.'), findsOneWidget);
    expect(find.text('Nenhuma pesagem registrada.'), findsOneWidget);
    expect(botao('Editar pesagem'), findsNothing);
    expect(find.text('Pesagens anteriores'), findsNothing);
    expect(find.textContaining('Peso atual • peso não informado'), findsOneWidget);
    expect(find.text('ECC não informado • Objetivo não informado'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('sem ECC nem objetivo: linha do peso ideal e previsões com os textos de M5/M7', (tester) async {
    await abrir(tester, EvolucaoFalsa(pesagens: pesagensLuna, agora: hoje));

    expect(find.textContaining('Peso ideal • Informe o ECC ou o objetivo'), findsOneWidget);
    expect(find.textContaining('Evolução • Defina o ECC ou o objetivo para estimar.'), findsOneWidget);
    expect(find.textContaining('Previsão • Defina o ECC ou o objetivo para estimar.'), findsOneWidget);
  });

  testWidgets('uma pesagem só: sem linha "Anterior" e sem pesagens anteriores', (tester) async {
    await abrir(tester, EvolucaoFalsa(pesagens: [pesagensLuna.last], agora: hoje));

    expect(find.text('5,4 kg • 30 set. 2026'), findsOneWidget);
    expect(find.text('Pesagens anteriores'), findsNothing);
    expect(find.byType(GraficoEvolucao), findsOneWidget);
  });

  testWidgets('"Registrar peso" abre o 11 e a pesagem salva aparece na hora', (tester) async {
    final dados = EvolucaoFalsa(pesagens: pesagensLuna, referencia: ecc7, agora: hoje);
    await abrir(tester, dados);

    await tocar(tester, botao('Registrar peso'));
    expect(find.text('Pesagem'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '5,35');
    await tocar(tester, botao('Salvar peso'));

    expect(find.textContaining('Evolução • 18% do caminho'), findsNothing);
    expect(find.textContaining('Evolução • 22% do caminho'), findsOneWidget);
  });

  testWidgets('"Editar pesagem" abre o 11 com a última; tocar numa anterior abre o peso inicial', (tester) async {
    await abrir(tester, EvolucaoFalsa(pesagens: pesagensLuna, agora: hoje));

    await tocar(tester, botao('Editar pesagem'));
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '5,4');
    await tocar(tester, botao('Voltar'));

    await tocar(tester, find.text('5,6 kg • 16 set. 2026 • peso inicial'));
    expect(find.text('Peso inicial'), findsOneWidget);
  });

  testWidgets('"Atualizar referências" abre o 12', (tester) async {
    await abrir(tester, EvolucaoFalsa(pesagens: pesagensLuna, agora: hoje));
    await tocar(tester, botao('Atualizar referências'));
    expect(find.text('Informações orientadas pelo veterinário.'), findsOneWidget);
  });

  testWidgets('pesagens anteriores: até 10 e "Ver mais" mostra as outras', (tester) async {
    final muitas = [
      for (var i = 0; i < 14; i++) pesagem('w$i', 6 - i * 0.05, DateTime(2026, 9, 1 + i * 2, 8)),
    ];
    await abrir(tester, EvolucaoFalsa(pesagens: muitas, agora: hoje));

    final linhas = find.descendant(of: find.widgetWithText(PaCard, 'Pesagens anteriores'), matching: find.byType(PaHistorico));
    expect(linhas, findsNWidgets(11), reason: '10 pesagens + Ver mais');
    await tocar(tester, find.text('Ver mais'));
    expect(linhas, findsNWidgets(12), reason: 'as 12 anteriores, sem Ver mais');
    expect(find.text('6,0 kg • 01 set. 2026 • peso inicial'), findsOneWidget);
  });
}
