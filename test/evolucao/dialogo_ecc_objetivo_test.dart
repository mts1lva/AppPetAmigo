// P4-1.6 — Tela 12 ECC e objetivo.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/evolucao/apresentacao/telas/dialogo_ecc_objetivo.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';

import '../apoio/evolucao_falsa.dart';
import '../apoio/montar.dart';

final pesagensLuna = [
  Pesagem(id: 'w1', petId: 'p1', pesoKg: 5.6, dataHora: DateTime(2026, 9, 16, 8)),
  Pesagem(id: 'w2', petId: 'p1', pesoKg: 5.4, dataHora: DateTime(2026, 9, 30, 8)),
];

Future<void> abrir(WidgetTester tester, EvolucaoFalsa dados) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: dados.overrides,
      child: appDeTeste(
        Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => abrirEccObjetivo(context, petId: 'p1'),
                child: const Text('abrir'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
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

const explicacao =
    'ECC é o escore de condição corporal. Precisa de avaliação profissional; peso isolado não diagnostica.';

void main() {
  testWidgets('sem referência: campos como no protótipo, texto e botões', (tester) async {
    await abrir(tester, EvolucaoFalsa(pesagens: pesagensLuna));

    expect(find.text('ECC e objetivo'), findsOneWidget);
    expect(find.text('Informações orientadas pelo veterinário.'), findsOneWidget);
    expect(find.text('ECC informado • Não informado'), findsOneWidget);
    expect(find.text('Objetivo (kg) • '), findsOneWidget);
    expect(find.text('Não informado'), findsOneWidget, reason: 'dica do campo vazio');
    expect(find.text('Origem • Veterinário / consulta'), findsOneWidget);
    expect(find.text('Data • 30 set. 2026'), findsOneWidget);
    expect(find.text(explicacao), findsOneWidget);
    for (final b in ['Salvar referências', 'Remover referências', 'Voltar']) {
      expect(botao(b), findsOneWidget);
    }
  });

  testWidgets('ECC 7 sem objetivo: mostra o peso ideal estimado e salva', (tester) async {
    final dados = EvolucaoFalsa(pesagens: pesagensLuna);
    await abrir(tester, dados);

    await tocar(tester, find.text('ECC informado • Não informado'));
    await tocar(tester, botao('7 de 9'));

    expect(find.text('ECC informado • 7 de 9'), findsOneWidget);
    expect(find.text('$explicacao\nPeso ideal estimado pelo ECC: 4,5 kg.'), findsOneWidget);

    await tocar(tester, botao('Salvar referências'));
    expect(
      dados.referencias.salvas.single,
      Referencia(id: 'nova-1', petId: 'p1', ecc: 7, origem: OrigemReferencia.veterinario, data: DateTime(2026, 9, 30)),
    );
    expect(find.text('ECC e objetivo'), findsNothing);
  });

  testWidgets('com objetivo, a linha do peso estimado some', (tester) async {
    final dados = EvolucaoFalsa(pesagens: pesagensLuna);
    await abrir(tester, dados);

    await tocar(tester, find.text('ECC informado • Não informado'));
    await tocar(tester, botao('7 de 9'));
    await tester.enterText(find.byType(TextField), '4,8');
    await tester.pumpAndSettle();

    expect(find.text(explicacao), findsOneWidget);
    await tocar(tester, find.textContaining('Origem • '));
    await tocar(tester, botao('Tutor'));
    await tocar(tester, botao('Salvar referências'));

    final salva = dados.referencias.salvas.single;
    expect((salva.ecc, salva.objetivoKg, salva.origem), (7, 4.8, OrigemReferencia.tutor));
  });

  testWidgets('objetivo inválido (0 ou acima de 150) mostra o erro de R05', (tester) async {
    final dados = EvolucaoFalsa(pesagens: pesagensLuna);
    await abrir(tester, dados);

    await tester.enterText(find.byType(TextField), '0');
    await tocar(tester, botao('Salvar referências'));
    expect(find.text('O valor precisa ser positivo.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '200');
    await tocar(tester, botao('Salvar referências'));
    expect(find.text('O valor precisa ser positivo.'), findsOneWidget);
    expect(dados.referencias.salvas, isEmpty);
  });

  testWidgets('com referência: preenche e edita a mesma linha (mesmo id)', (tester) async {
    final atual = Referencia(
      id: 'r1',
      petId: 'p1',
      ecc: 6,
      objetivoKg: 5,
      origem: OrigemReferencia.outroProfissional,
      data: DateTime(2026, 9, 10),
    );
    final dados = EvolucaoFalsa(pesagens: pesagensLuna, referencia: atual);
    await abrir(tester, dados);

    expect(find.text('ECC informado • 6 de 9'), findsOneWidget);
    expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '5');
    expect(find.text('Origem • Outro profissional'), findsOneWidget);
    expect(find.text('Data • 10 set. 2026'), findsOneWidget);

    await tocar(tester, botao('Salvar referências'));
    expect(dados.referencias.salvas.single, atual);
  });

  testWidgets('Remover referências → 23 → confirmar remove só a referência', (tester) async {
    final dados = EvolucaoFalsa(
      pesagens: pesagensLuna,
      referencia: Referencia(
        id: 'r1',
        petId: 'p1',
        ecc: 7,
        origem: OrigemReferencia.veterinario,
        data: DateTime(2026, 9, 30),
      ),
    );
    await abrir(tester, dados);

    await tocar(tester, botao('Remover referências'));
    await tocar(tester, botao('Confirmar exclusão'));

    expect(dados.referencias.remocoes, 1);
    expect(dados.pesagens.excluidas, isEmpty);
    expect(find.text('ECC e objetivo'), findsNothing);
  });
}
