// P1-4.6 — acessibilidade das telas do P1 (`pacote-1` → Critérios):
// - com a fonte do sistema em 200%, nada corta (o Flutter acusa qualquer
//   "overflow" como erro do teste);
// - o leitor de tela (TalkBack) lê os 4 destinos com o estado "selecionado"
//   e os rótulos dos campos do 05.
// A conferência com o TalkBack de verdade, no aparelho, continua manual.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/app.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/inicio/apresentacao/providers/sugestoes_provider.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/lembretes_provider.dart';
import 'package:petamigo/features/nutricao/apresentacao/telas/dialogo_como_meta.dart';
import 'package:petamigo/features/pets/apresentacao/telas/dialogo_dados_pet.dart';
import 'package:petamigo/features/pets/apresentacao/telas/dialogo_seus_pets.dart';
import 'package:petamigo/features/pets/apresentacao/telas/tela_vamos_comecar.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

import '../apoio/golden.dart';
import '../apoio/inicio_falso.dart';
import '../apoio/pets_falsos.dart';

/// App inteiro em 390 × 844 dp, com a fonte do sistema em [escala].
Future<void> montarApp(WidgetTester tester, PetsFalsos pets, {double escala = 2}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  tester.platformDispatcher.textScaleFactorTestValue = escala;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...pets.overrides,
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

/// Luna (atual) e Thor: com 2 pets aparecem "Trocar de pet" e "Excluir este pet".
PetsFalsos doisPets() => PetsFalsos(iniciais: [
      (luna(id: 'p2', nome: 'Thor').copyWith(especie: Especie.cao, sexo: Sexo.macho), 12),
      (luna(), 5.4),
    ]);

Future<void> tocar(WidgetTester tester, Finder alvo) async {
  await tester.ensureVisible(alvo);
  await tester.pumpAndSettle();
  await tester.tap(alvo);
  await tester.pumpAndSettle();
}

void main() {
  group('fonte em 200%: nada corta', () {
    testWidgets('26 Vamos começar?', (tester) async {
      await montarApp(tester, PetsFalsos());
      expect(find.byType(TelaVamosComecar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('01 Início, com a navegação crescendo em altura', (tester) async {
      await montarApp(tester, doisPets());
      expect(find.text('Trocar de pet'), findsOneWidget);
      expect(tester.takeException(), isNull);

      for (final item in ['Início', 'Diário', 'Atividades', 'Evolução']) {
        final altura = tester.getSize(find.ancestor(of: find.text(item), matching: find.byType(ConstrainedBox)).first).height;
        expect(altura, greaterThan(56), reason: '$item: com 200%, o item cresce em vez de cortar');
      }
    });

    testWidgets('05 Dados de Luna e 23 Confirmar exclusão', (tester) async {
      await montarApp(tester, doisPets());
      await tocar(tester, find.widgetWithText(PaBotao, 'Editar pet'));
      expect(find.byType(DialogoDadosPet), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tocar(tester, find.widgetWithText(PaBotao, 'Excluir este pet'));
      expect(find.text('Confirmar exclusão'), findsWidgets, reason: 'título e botão');
      expect(tester.takeException(), isNull);
    });

    testWidgets('18 Como a meta é calculada', (tester) async {
      await montarApp(tester, doisPets());
      await tocar(tester, find.widgetWithText(PaBotao, 'Entender a referência'));
      expect(find.byType(DialogoComoMeta), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('N1 Seus pets', (tester) async {
      await montarApp(tester, doisPets());
      await tocar(tester, find.text('Trocar de pet'));
      expect(find.byType(DialogoSeusPets), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('evidência: Início com a fonte em 200% (390 × 844 a 2x)', (tester) async {
    await montarApp(tester, doisPets());
    prepararTelaGolden(tester);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await expectLater(telaInteira, matchesGoldenFile('../goldens/arquivos/01-inicio-fonte-200.png'));
  });

  group('leitor de tela', () {
    testWidgets('lê os 4 destinos como botões, com o Início selecionado', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, doisPets(), escala: 1);

      for (final (item, selecionado) in [('Início', true), ('Diário', false), ('Atividades', false), ('Evolução', false)]) {
        expect(
          tester.getSemantics(find.bySemanticsLabel(item)),
          isSemantics(label: item, isButton: true, hasSelectedState: true, isSelected: selecionado),
          reason: item,
        );
      }
      semantica.dispose();
    });

    testWidgets('lê os rótulos dos campos do 05', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, doisPets(), escala: 1);
      await tocar(tester, find.widgetWithText(PaBotao, 'Editar pet'));

      for (final rotulo in ['Nome', 'Espécie', 'Sexo', 'Idade', 'Castração', 'Atividade', 'Peso inicial (kg)']) {
        expect(find.bySemanticsLabel(rotulo), findsOneWidget, reason: rotulo);
      }
      semantica.dispose();
    });

    testWidgets('o cabeçalho do Início é um botão que diz o que faz', (tester) async {
      final semantica = tester.ensureSemantics();
      await montarApp(tester, doisPets(), escala: 1);

      expect(
        tester.getSemantics(find.bySemanticsLabel('Luna, Gata • 6 anos')),
        isSemantics(isButton: true, hint: 'Abre Seus pets', hasTapAction: true),
      );
      semantica.dispose();
    });
  });
}
