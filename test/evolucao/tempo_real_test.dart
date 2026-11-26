// P4-2.4 — U2-05: com a Evolução aberta, registrar uma refeição (07 do P2),
// editar um peso (11) e registrar uma atividade (10 do P3) muda a projeção e
// a previsão na hora, sem sair da tela e sem botão "atualizar".

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/atividades/apresentacao/telas/dialogo_atividade.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_refeicao.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';
import 'package:petamigo/features/evolucao/apresentacao/telas/tela_evolucao.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pet_atual_provider.dart';

import '../apoio/diario_falso.dart';
import '../apoio/evolucao_falsa.dart';
import '../apoio/montar.dart';

final hoje = DateTime(2026, 9, 30, 20);

Pesagem pesagem(String id, double kg, DateTime data) => Pesagem(id: id, petId: 'p1', pesoKg: kg, dataHora: data);

final pesagensLuna = [
  pesagem('w1', 5.6, DateTime(2026, 9, 16, 8)),
  pesagem('w2', 5.5, DateTime(2026, 9, 23, 8)),
  pesagem('w3', 5.4, DateTime(2026, 9, 30, 8)),
];

final ecc7 = Referencia(id: 'r1', petId: 'p1', ecc: 7, origem: OrigemReferencia.veterinario, data: DateTime(2026, 9, 30));

/// Perto da MER (≈ 397 kcal), para a projeção não bater no limite de 2% por
/// semana e cada registro mexer no ritmo.
Refeicao refeicao(String id, int dia) => Refeicao(
      id: id,
      petId: 'p1',
      alimentoId: 'a1',
      alimentoNome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      quantidadeG: 105,
      energiaKcal: 378,
      dataHora: DateTime(2026, 9, dia, 8),
    );

/// A tela 04 com os atalhos que os outros pacotes usam para abrir os
/// formulários (Diário e Atividades), por cima dela.
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
    child: appDeTeste(Scaffold(
      body: const TelaEvolucao(),
      bottomNavigationBar: Builder(
        builder: (context) => Row(
          children: [
            TextButton(onPressed: () => abrirRefeicao(context, petId: 'p1', alimentoId: 'a1'), child: const Text('refeição')),
            TextButton(onPressed: () => abrirAtividade(context, petId: 'p1'), child: const Text('atividade')),
          ],
        ),
      ),
    )),
  ));
  await tester.pumpAndSettle();
}

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

/// A linha "Previsão • …" do card Indicadores.
String previsao(WidgetTester tester) {
  final indicadores = tester
      .widgetList<Text>(find.byType(Text))
      .map((t) => t.data ?? '')
      .firstWhere((t) => t.startsWith('Peso atual • '));
  return indicadores.split('\n').firstWhere((l) => l.startsWith('Previsão • '));
}

/// Fecha o diálogo de confirmação que o formulário abrir depois de salvar
/// (tela 20 do P2), se houver.
Future<void> fecharConfirmacao(WidgetTester tester) async {
  final voltar = find.widgetWithText(PaBotao, 'Voltar');
  if (voltar.evaluate().isNotEmpty) await tocar(tester, voltar.last);
}

void main() {
  testWidgets('refeição, peso e atividade mudam a previsão com a Evolução aberta (U2-05)', (tester) async {
    final dados = EvolucaoFalsa(
      pesagens: pesagensLuna,
      referencia: ecc7,
      alimentos: [racaoHabitual()],
      refeicoes: [refeicao('m28', 28), refeicao('m29', 29)],
      agora: hoje,
    );
    await abrir(tester, dados);
    final inicial = previsao(tester);
    expect(inicial, 'Previsão • 02 dez. 2026', reason: 'só 2 dias com registro: só a tendência das pesagens');

    // 1. Refeição pelo formulário 07 do P2: o 3º dia com registro liga a parte
    //    energética de M4.
    await tocar(tester, find.text('refeição'));
    await tester.enterText(find.byType(TextField).first, '105');
    await tocar(tester, find.widgetWithText(PaBotao, 'Salvar refeição'));
    await fecharConfirmacao(tester);
    expect(dados.diario.refeicoes.salvas, hasLength(1));
    final depoisDaRefeicao = previsao(tester);
    expect(depoisDaRefeicao, isNot(inicial));

    // 2. Peso editado pelo 11 (uma queda mais lenta, ainda abaixo do limite
    //    de 2% por semana; perto do limite a projeção fica cortada e para de
    //    responder, como manda M4 d).
    await tocar(tester, find.widgetWithText(PaBotao, 'Editar pesagem'));
    await tester.enterText(find.byType(TextField), '5,45');
    await tocar(tester, find.widgetWithText(PaBotao, 'Salvar peso'));
    await fecharConfirmacao(tester);
    final depoisDoPeso = previsao(tester);
    expect(depoisDoPeso, isNot(depoisDaRefeicao));
    expect(dados.pesagens.salvas.single.pesoKg, 5.45);

    // 3. Atividade pelo formulário 10 do P3.
    await tocar(tester, find.text('atividade'));
    await tester.enterText(find.byType(TextField), '120');
    await tocar(tester, find.widgetWithText(PaBotao, 'Salvar atividade'));
    expect(previsao(tester), isNot(depoisDoPeso));

    expect(find.byType(TelaEvolucao), findsOneWidget, reason: 'nunca saiu da tela');
    expect(find.text('Atualizar'), findsNothing);
  });
}
