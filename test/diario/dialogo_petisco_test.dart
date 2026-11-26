import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_petisco.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';

import '../apoio/diario_falso.dart';
import '../apoio/montar.dart';

Future<void> abrir(WidgetTester tester, DiarioFalsos diario, {String? extraId}) async {
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
            onPressed: () => abrirPetisco(context, petId: 'p1', extraId: extraId),
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
  group('08 Petisco ou extra', () {
    testWidgets('título, descrição padrão Petisco e sem excluir no cadastro', (tester) async {
      await abrir(tester, DiarioFalsos());

      expect(find.text(tituloPetisco), findsOneWidget);
      expect(find.text(subtituloPetisco), findsOneWidget);
      expect(find.text(descricaoPetiscoPadrao), findsOneWidget);
      expect(botao(botaoSalvarPetisco), findsOneWidget);
      expect(botao(botaoExcluirRegistro), findsNothing);
    });

    testWidgets('salvar sem energia mostra o erro e não grava', (tester) async {
      final diario = DiarioFalsos();
      await abrir(tester, diario);
      await tocar(tester, botao(botaoSalvarPetisco));
      expect(diario.extras.salvos, isEmpty);
      expect(find.text(mensagemInformeEnergia), findsOneWidget);
    });

    testWidgets('quantidade opcional: 12 kcal sem gramas grava e fecha', (tester) async {
      final diario = DiarioFalsos();
      await abrir(tester, diario);
      await tester.enterText(find.byType(TextField).at(2), '12');
      await tocar(tester, botao(botaoSalvarPetisco));

      expect(diario.extras.salvos, hasLength(1));
      final e = diario.extras.salvos.single;
      expect((e.descricao, e.quantidadeG, e.energiaKcal), ('Petisco', null, 12));
      expect(find.byType(DialogoPetisco), findsNothing);
    });

    testWidgets('editar preenche, excluir confirma e remove', (tester) async {
      final diario = DiarioFalsos(extras: [extraHabitual()]);
      await abrir(tester, diario, extraId: 'e1');

      expect(find.text('Petisco'), findsWidgets);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
      await tocar(tester, botao(botaoExcluirRegistro));
      await tocar(tester, botao('Confirmar exclusão'));
      expect(diario.extras.excluidos, ['e1']);
    });

    testWidgets('excluir espera a transação e só então fecha', (tester) async {
      final diario = DiarioFalsos(extras: [extraHabitual()]);
      final porta = Completer<void>();
      diario.extras.antesDeGravar = () => porta.future;
      await abrir(tester, diario, extraId: 'e1');

      await tocar(tester, botao(botaoExcluirRegistro));
      await tocar(tester, botao('Confirmar exclusão'));
      await tester.pump();

      expect(find.byType(DialogoPetisco), findsOneWidget);
      expect(diario.extras.excluidos, isEmpty);

      porta.complete();
      await tester.pumpAndSettle();

      expect(diario.extras.excluidos, ['e1']);
      expect(find.byType(DialogoPetisco), findsNothing);
    });

    testWidgets('falha ao excluir mostra o erro e mantém o diálogo', (tester) async {
      final diario = DiarioFalsos(extras: [extraHabitual()]);
      diario.extras.antesDeGravar = () async {
        throw ArgumentError('Não foi possível excluir.');
      };
      await abrir(tester, diario, extraId: 'e1');

      await tocar(tester, botao(botaoExcluirRegistro));
      await tocar(tester, botao('Confirmar exclusão'));
      await tester.pumpAndSettle();

      expect(diario.extras.excluidos, isEmpty);
      expect(find.byType(DialogoPetisco), findsOneWidget);
      expect(find.text('Não foi possível excluir.'), findsOneWidget);
    });
  });
}
