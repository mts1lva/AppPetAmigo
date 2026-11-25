import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/diario/apresentacao/providers/diario_ui_providers.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_alimentos.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_outra_data.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_petisco.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_refeicao.dart';
import 'package:petamigo/features/diario/apresentacao/telas/tela_diario.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';

import '../apoio/diario_falso.dart';
import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

final agora = DateTime(2026, 9, 30, 9);

Future<void> montar(WidgetTester tester, {DiarioFalsos? diario}) async {
  tester.view
    ..physicalSize = const Size(390, 1200)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final pets = PetsFalsos(iniciais: [(luna(), 5.4)]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...pets.overrides,
      ...(diario ?? DiarioFalsos()).overrides,
      agoraProvider.overrideWithValue(() => agora),
      ultimaPesagemProvider.overrideWith(
        (ref, petId) => Stream.value(Pesagem(id: 'pes1', petId: petId, pesoKg: 5.4, dataHora: DateTime(2026, 9, 1))),
      ),
    ],
    child: appDeTeste(const Scaffold(body: TelaDiario())),
  ));
  await tester.pumpAndSettle();
}

Finder botao(String texto) => find.widgetWithText(PaBotao, texto);

void main() {
  testWidgets('02 Diário: título, data, cards vazios e R09 no resumo', (tester) async {
    await montar(tester);

    expect(find.text(tituloDiario), findsOneWidget);
    expect(find.text('30 setembro 2026'), findsOneWidget);
    expect(find.text(tituloDataSelecionada), findsOneWidget);
    expect(find.text(textoCardData), findsOneWidget);
    expect(find.text(textoSemRefeicoes), findsOneWidget);
    expect(find.text(textoSemPetiscos), findsOneWidget);
    expect(botao(botaoAdicionarRefeicao), findsOneWidget);
    expect(botao(botaoEditarPetisco), findsNothing);
    expect(find.text(textoSemRegistros), findsOneWidget);
    expect(find.text(textoSemRegistros), isNot(contains('0 kcal')));
    expect(botao(botaoAdicionarPetisco), findsOneWidget);
    expect(botao(botaoGerenciarAlimentos), findsOneWidget);
  });

  testWidgets('com registros: linhas PaHistorico, resumo R02 e editar', (tester) async {
    await montar(
      tester,
      diario: DiarioFalsos(
        alimentos: [racaoHabitual()],
        refeicoes: [refeicaoHabitual()],
        extras: [extraHabitual()],
      ),
    );

    expect(find.text('08:00 • Ração habitual • 30 g • 108 kcal'), findsOneWidget);
    expect(find.text('12:00 • Petisco • 3 g • 12 kcal'), findsOneWidget);
    expect(find.textContaining('120 de 397 kcal • Petiscos 10% dos registros'), findsOneWidget);
    expect(botao(botaoEditarRefeicao), findsOneWidget);
    expect(botao(botaoEditarPetisco), findsOneWidget);

    await tester.tap(find.text('08:00 • Ração habitual • 30 g • 108 kcal'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoRefeicao), findsOneWidget);
  });

  testWidgets('Gerenciar alimentos abre o 09; Adicionar petisco abre o 08', (tester) async {
    await montar(tester, diario: DiarioFalsos(alimentos: [racaoHabitual()]));

    await tester.tap(botao(botaoGerenciarAlimentos));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoAlimentos), findsOneWidget);
    await tester.tap(botao('Voltar'));
    await tester.pumpAndSettle();

    await tester.tap(botao(botaoAdicionarPetisco));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoPetisco), findsOneWidget);
  });

  testWidgets('P-05: título Diário atualizado', (tester) async {
    await montar(tester);
    ProviderScope.containerOf(tester.element(find.byType(TelaDiario))).read(diarioAtualizadoProvider.notifier).marcar();
    await tester.pump();
    expect(find.text(tituloDiarioAtualizado), findsOneWidget);
    expect(find.text(tituloDiario), findsNothing);
  });

  testWidgets('Consultar diário atualizado abre o 02 no dia da refeição, com ela na lista', (tester) async {
    final diaRefeicao = DateTime(2026, 9, 29, 8);
    await montar(
      tester,
      diario: DiarioFalsos(
        alimentos: [racaoHabitual()],
        refeicoes: [refeicaoHabitual(quando: diaRefeicao)],
      ),
    );

    expect(find.text('30 setembro 2026'), findsOneWidget);
    expect(find.text(textoSemRefeicoes), findsOneWidget);

    ProviderScope.containerOf(tester.element(find.byType(TelaDiario)))
        .read(diarioAtualizadoProvider.notifier)
        .marcar(dia: diaRefeicao);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text(tituloDiarioAtualizado), findsOneWidget);
    expect(find.text('29 setembro 2026'), findsOneWidget);
    expect(find.text('08:00 • Ração habitual • 30 g • 108 kcal'), findsOneWidget);
    expect(find.text(textoSemRefeicoes), findsNothing);
  });

  testWidgets('19: textos de R09; Retomar devolve true', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 844)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    var retomar = false;
    await tester.pumpWidget(appDeTeste(Scaffold(
      body: Builder(
        builder: (context) => TextButton(
          onPressed: () async => retomar = await abrirOutraData(context, data: DateTime(2026, 9, 29)),
          child: const Text('abrir'),
        ),
      ),
    )));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoOutraData), findsOneWidget);
    expect(find.text(tituloOutraData), findsOneWidget);
    expect(find.text('29 setembro 2026'), findsOneWidget);
    expect(find.text(textoSemRegistros), findsOneWidget);
    await tester.tap(botao(botaoRetomarHoje));
    await tester.pumpAndSettle();
    expect(retomar, isTrue);
  });
}
