import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/diario/apresentacao/providers/alimento_atalho_provider.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_alimentos.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_atalho.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_refeicao.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_refeicao_salva.dart';
import 'package:petamigo/features/diario/domain/entidades/alimento.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';

import '../apoio/diario_falso.dart';
import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

Future<void> abrir(
  WidgetTester tester,
  DiarioFalsos diario, {
  List<Override> extras = const [],
}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...PetsFalsos(iniciais: [(luna(), 5.4)]).overrides,
      ...diario.overrides,
      agoraProvider.overrideWithValue(() => DateTime(2026, 9, 30, 9)),
      ultimaPesagemProvider.overrideWith(
        (ref, petId) => Stream.value(Pesagem(id: 'pes1', petId: petId, pesoKg: 5.4, dataHora: DateTime(2026, 9, 1))),
      ),
      ...extras,
    ],
    child: appDeTeste(Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(onPressed: () => abrirAtalho(context, petId: 'p1'), child: const Text('abrir')),
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
  group('06 Registrar refeição', () {
    testWidgets('sem alimento abre o caminho para o 09', (tester) async {
      await abrir(tester, DiarioFalsos());
      expect(find.text(subtituloAlimentosAtalho), findsOneWidget);
      await tocar(tester, botao(botaoGerenciarAlimentos));
      expect(find.byType(DialogoAlimentos), findsOneWidget);
    });

    testWidgets('título, porção habitual pré-selecionada, meta e rótulo', (tester) async {
      await abrir(tester, DiarioFalsos(alimentos: [racaoHabitual()]));

      expect(find.text(tituloAtalho), findsOneWidget);
      expect(find.text(subtituloAtalho), findsOneWidget);
      expect(find.textContaining('Energia do rótulo: 360 kcal/100 g'), findsOneWidget);
      expect(find.textContaining('Meta de hoje: 397 kcal (≈ 110 g)'), findsOneWidget);
      expect(find.textContaining(rotuloPorcaoHabitual), findsOneWidget);
      expect(botao(botaoConfirmarRefeicao), findsOneWidget);
      expect(botao(botaoAlterarDados), findsOneWidget);
    });

    const sache = Alimento(id: 'a2', petId: 'p1', nome: 'Sachê', densidadeKcalPor100g: 80, porcaoPadraoG: 85);
    const umido = Alimento(id: 'a3', petId: 'p1', nome: 'Úmido', densidadeKcalPor100g: 120, porcaoPadraoG: 50);

    testWidgets('sem refeição, vem o último alimento cadastrado', (tester) async {
      await abrir(tester, DiarioFalsos(alimentos: [racaoHabitual(), sache]));

      expect(find.textContaining('Energia do rótulo: 80 kcal/100 g'), findsOneWidget);
      expect(find.textContaining('Energia do rótulo: 360 kcal/100 g'), findsNothing);
    });

    testWidgets('espera o alimento do atalho, mesmo que a lista chegue antes', (tester) async {
      await abrir(
        tester,
        DiarioFalsos(alimentos: [racaoHabitual(), sache, umido]),
        extras: [
          alimentoAtalhoProvider.overrideWith(
            (ref, petId) => Stream.fromFuture(
              Future<Alimento?>.delayed(const Duration(milliseconds: 500), () => sache),
            ),
          ),
        ],
      );
      // A lista já chegou; o atalho só chega depois de 500 ms.
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.textContaining('Energia do rótulo: 80 kcal/100 g'), findsOneWidget);
    });

    testWidgets('2 toques: Confirmar grava a porção habitual e abre o 20', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()]);
      await abrir(tester, diario);

      await tocar(tester, botao(botaoConfirmarRefeicao));

      expect(diario.refeicoes.salvas, hasLength(1));
      final r = diario.refeicoes.salvas.single;
      expect((r.quantidadeG, r.energiaKcal), (30, 108));
      expect(find.byType(DialogoRefeicaoSalva), findsOneWidget);
      expect(find.text(tituloRefeicaoSalva), findsOneWidget);
      expect(find.text(subtituloRefeicaoSalva), findsOneWidget);
      expect(find.textContaining('O diário passa de 0 para 108 kcal'), findsOneWidget);
    });

    testWidgets('R08 usa as refeições já emitidas no total do dia', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()], refeicoes: [refeicaoHabitual()]);
      await abrir(tester, diario);

      await tocar(tester, botao(botaoConfirmarRefeicao));

      expect(find.byType(DialogoRefeicaoSalva), findsOneWidget);
      expect(find.textContaining('O diário passa de 108 para 216 kcal'), findsOneWidget);
    });

    testWidgets('R08 espera o stream que ainda não emitiu e não trata como dia vazio', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()], refeicoes: [refeicaoHabitual()]);
      diario.refeicoes.atrasoObservar = const Duration(milliseconds: 80);
      await abrir(tester, diario);

      await tocar(tester, botao(botaoConfirmarRefeicao));

      expect(find.byType(DialogoRefeicaoSalva), findsOneWidget);
      expect(find.textContaining('O diário passa de 108 para 216 kcal'), findsOneWidget);
      expect(find.textContaining('O diário passa de 0 para 108 kcal'), findsNothing);
    });

    testWidgets('R08 não trata erro do stream como dia vazio', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()]);
      diario.refeicoes.erroObservar = ArgumentError('Não foi possível ler o diário.');
      await abrir(tester, diario);

      await tocar(tester, botao(botaoConfirmarRefeicao));

      expect(diario.refeicoes.salvas, isEmpty);
      expect(find.byType(DialogoRefeicaoSalva), findsNothing);
      expect(find.byType(DialogoAtalho), findsOneWidget);
      expect(find.text('Não foi possível ler o diário.'), findsOneWidget);
    });

    testWidgets('Metade grava 15 g / 54 kcal', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()]);
      await abrir(tester, diario);

      await tocar(tester, find.textContaining('$rotuloCampoPorcao • '));
      await tocar(tester, botao(rotuloPorcao(rotuloPorcaoMetade, 15, 54)));
      await tocar(tester, botao(botaoConfirmarRefeicao));

      expect(diario.refeicoes.salvas.single.quantidadeG, 15);
      expect(diario.refeicoes.salvas.single.energiaKcal, 54);
    });

    testWidgets('Outra quantidade abre o 07 com foco na quantidade', (tester) async {
      await abrir(tester, DiarioFalsos(alimentos: [racaoHabitual()]));
      await tocar(tester, find.textContaining('$rotuloCampoPorcao • '));
      await tocar(tester, botao(rotuloOutraQuantidade));
      expect(find.byType(DialogoRefeicao), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField).first).focusNode!.hasFocus, isTrue);
    });

    testWidgets('Alterar dados abre o 07 preenchido, sem gravar', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()]);
      await abrir(tester, diario);
      await tocar(tester, botao(botaoAlterarDados));
      expect(diario.refeicoes.salvas, isEmpty);
      expect(find.byType(DialogoRefeicao), findsOneWidget);
      expect(find.text('30'), findsOneWidget);
    });
  });
}
