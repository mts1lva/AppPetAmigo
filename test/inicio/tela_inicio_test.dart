import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/sugestao.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/diario/apresentacao/providers/resumo_dia_provider.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_alimentos.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_atalho.dart';
import 'package:petamigo/features/diario/domain/entidades/resumo_dia.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/inicio/apresentacao/providers/sugestoes_provider.dart';
import 'package:petamigo/features/inicio/apresentacao/telas/tela_inicio.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/lembretes_provider.dart';
import 'package:petamigo/features/nutricao/apresentacao/telas/dialogo_como_meta.dart';
import 'package:petamigo/features/pets/apresentacao/telas/dialogo_dados_pet.dart';
import 'package:petamigo/features/pets/apresentacao/telas/dialogo_seus_pets.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

import '../apoio/diario_falso.dart';
import '../apoio/inicio_falso.dart';
import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

/// 30/09/2026, 09:00: "Bom dia" e "Hoje · 30 set.", como no PNG 01.
final agora = DateTime(2026, 9, 30, 9);

Pesagem pesagem(String petId, double kg) =>
    Pesagem(id: 'pes-$petId', petId: petId, pesoKg: kg, dataHora: DateTime(2026, 9, 1));

Future<void> montar(
  WidgetTester tester, {
  required PetsFalsos pets,
  Map<String, Stream<Pesagem?>> pesos = const {},
  List<Override> extras = const [],
  AdiadasFalsas? adiadas,
  DiarioFalsos? diario,
}) async {
  tester.view
    ..physicalSize = const Size(390, 2400)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...pets.overrides,
        lembretesProvider.overrideWith((ref, petId) => Stream.value([])),
        ...(diario ?? DiarioFalsos()).overrides,
        agoraProvider.overrideWithValue(() => agora),
        ultimaPesagemProvider.overrideWith((ref, petId) => pesos[petId] ?? Stream.value(null)),
        sugestoesAdiadasRepositorioProvider.overrideWithValue(adiadas ?? AdiadasFalsas()),
        ...extras,
      ],
      child: appDeTeste(const Scaffold(body: TelaInicio())),
    ),
  );
  await tester.pumpAndSettle();
}

String textoDoCard(WidgetTester tester, String titulo) =>
    tester.widget<PaCard>(find.widgetWithText(PaCard, titulo).first).texto ?? '';

void main() {
  testWidgets('Luna: saudação, cabeçalho e cards com os dados reais', (tester) async {
    await montar(
      tester,
      pets: PetsFalsos(iniciais: [(luna(), 5.4)]),
      pesos: {'p1': Stream.value(pesagem('p1', 5.4))},
    );

    expect(find.text('Bom dia'), findsOneWidget);
    expect(find.text('Um cuidado de cada vez.'), findsOneWidget);
    expect(find.text('Gata • 6 anos'), findsOneWidget);
    expect(find.text('Trocar de pet'), findsNothing, reason: 'só com 2 ou mais pets');

    expect(textoDoCard(tester, 'Luna'), 'Gata • 6 anos • castrada\nAtividade moderada • 5,4 kg');
    expect(textoDoCard(tester, 'Hoje · 30 set.'), 'Ainda sem registros hoje.');
    expect(
      textoDoCard(tester, 'Referência alimentar'),
      'Meta de hoje: 397 kcal\nRER × 1,6 (castrada). Estimativa educativa.',
    );
    expect(textoDoCard(tester, 'Lembretes'), 'Nenhum lembrete ativo.');
    expect(textoDoCard(tester, 'Seu controle'), 'Dados salvos neste aparelho.');
    expect(find.text('Sugestões'), findsNothing, reason: 'sem sugestões, o card não aparece');

    for (final botao in [
      'Editar pet',
      'Registrar refeição',
      'Entender a referência',
      'Configurar lembretes',
      'Privacidade e cópia remota',
    ]) {
      expect(find.widgetWithText(PaBotao, botao), findsOneWidget, reason: botao);
    }
    expect(
      tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Registrar refeição')).variante,
      PaBotaoVariante.primario,
    );
  });

  testWidgets('editar o peso recalcula a meta e o card do pet na hora (U2-06)', (tester) async {
    final peso = StreamController<Pesagem?>();
    addTearDown(peso.close);
    await montar(
      tester,
      pets: PetsFalsos(iniciais: [(luna(), 5.4)]),
      pesos: {'p1': peso.stream},
    );

    peso.add(pesagem('p1', 5.4));
    await tester.pumpAndSettle();
    expect(textoDoCard(tester, 'Referência alimentar'), startsWith('Meta de hoje: 397 kcal'));

    peso.add(pesagem('p1', 4.5));
    await tester.pumpAndSettle();
    expect(textoDoCard(tester, 'Referência alimentar'), startsWith('Meta de hoje: 346 kcal'));
    expect(textoDoCard(tester, 'Luna'), endsWith('4,5 kg'));
  });

  testWidgets('sem pesagem: peso não informado e o motivo da meta', (tester) async {
    await montar(tester, pets: PetsFalsos(iniciais: [(luna(), 5.4)]));

    expect(textoDoCard(tester, 'Luna'), endsWith('peso não informado'));
    expect(textoDoCard(tester, 'Referência alimentar'), 'Registre uma pesagem para calcular a meta.');
  });

  testWidgets('card Hoje com registros mostra o total contra a meta (R02)', (tester) async {
    await montar(
      tester,
      pets: PetsFalsos(iniciais: [(luna(), 5.4)]),
      pesos: {'p1': Stream.value(pesagem('p1', 5.4))},
      extras: [
        resumoDiaProvider.overrideWith(
          (ref, args) => Stream.value(ResumoDia(dia: args.$2, racaoKcal: 108, extrasKcal: 12, registros: 3)),
        ),
      ],
    );

    expect(textoDoCard(tester, 'Hoje · 30 set.'), 'Ração 108 kcal • Petiscos 12 kcal\nTotal: 120 de 397 kcal');
  });

  testWidgets('com 2 pets: "Trocar de pet" e o cabeçalho abre o N1', (tester) async {
    final thor = luna(id: 'p2', nome: 'Thor').copyWith(especie: Especie.cao, sexo: Sexo.macho);
    await montar(tester, pets: PetsFalsos(iniciais: [(thor, 12), (luna(), 5.4)]));

    expect(find.text('Trocar de pet'), findsOneWidget);
    await tester.tap(find.text('Gata • 6 anos'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoSeusPets), findsOneWidget);
  });

  testWidgets('trocar o pet atual troca a tela inteira (U2-10)', (tester) async {
    final thor = luna(id: 'p2', nome: 'Thor').copyWith(especie: Especie.cao, sexo: Sexo.macho, castrado: false);
    final pets = PetsFalsos(iniciais: [(thor, 12), (luna(), 5.4)]);
    await montar(
      tester,
      pets: pets,
      pesos: {'p1': Stream.value(pesagem('p1', 5.4)), 'p2': Stream.value(pesagem('p2', 12))},
    );
    expect(find.widgetWithText(PaCard, 'Luna'), findsOneWidget);

    await pets.definirId('p2');
    await tester.pumpAndSettle();

    expect(find.widgetWithText(PaCard, 'Luna'), findsNothing);
    expect(textoDoCard(tester, 'Thor'), 'Cão • 6 anos • não castrado\nAtividade moderada • 12,0 kg');
    expect(find.text('Cão • 6 anos'), findsOneWidget);
  });

  testWidgets('Registrar refeição sem alimento abre o 09 (P2-2.1)', (tester) async {
    await montar(tester, pets: PetsFalsos(iniciais: [(luna(), 5.4)]));
    await tester.tap(find.widgetWithText(PaBotao, 'Registrar refeição'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoAlimentos), findsOneWidget);
  });

  testWidgets('Registrar refeição com alimento abre o 06 (P2-2.1)', (tester) async {
    await montar(
      tester,
      pets: PetsFalsos(iniciais: [(luna(), 5.4)]),
      diario: DiarioFalsos(alimentos: [racaoHabitual()]),
    );
    await tester.tap(find.widgetWithText(PaBotao, 'Registrar refeição'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoAtalho), findsOneWidget);
  });

  testWidgets('"Editar pet" abre o 05 em modo edição', (tester) async {
    await montar(tester, pets: PetsFalsos(iniciais: [(luna(), 5.4)]));

    await tester.tap(find.widgetWithText(PaBotao, 'Editar pet'));
    await tester.pumpAndSettle();

    expect(find.byType(DialogoDadosPet), findsOneWidget);
    expect(find.text('Dados de Luna'), findsOneWidget);
  });

  testWidgets('card Sugestões: ação e "Agora não" adia a sugestão (M8)', (tester) async {
    final adiadas = AdiadasFalsas();
    await montar(
      tester,
      pets: PetsFalsos(iniciais: [(luna(), 5.4)]),
      adiadas: adiadas,
      extras: [
        sugestoesProvider.overrideWith(
          (ref, petId) => const [Sugestao(tipo: TipoSugestao.reduzirPetiscos, texto: 'Texto da S1')],
        ),
      ],
    );

    expect(find.text('Sugestões'), findsOneWidget);
    expect(find.text('Texto da S1'), findsOneWidget);
    expect(find.widgetWithText(PaBotao, 'Ver diário'), findsOneWidget);

    await tester.tap(find.widgetWithText(PaBotao, 'Agora não'));
    await tester.pump();
    expect(adiadas.adiadas, {TipoSugestao.reduzirPetiscos: agora});
  });

  testWidgets('"Entender a referência" abre a tela 18 com os números da Luna; os dois botões fecham', (tester) async {
    await montar(tester, pets: PetsFalsos(iniciais: [(luna(), 5.4)]), pesos: {'p1': Stream.value(pesagem('p1', 5.4))});

    for (final botao in ['Voltar ao perfil', 'Voltar']) {
      await tester.tap(find.widgetWithText(PaBotao, 'Entender a referência'));
      await tester.pumpAndSettle();
      expect(find.byType(DialogoComoMeta), findsOneWidget);
      expect(find.text('Como a meta é calculada'), findsOneWidget);
      expect(find.text('Fórmula veterinária (NRC).'), findsOneWidget);
      expect(
        tester.widget<PaDialogo>(find.byType(PaDialogo)).texto,
        'RER = 70 × peso^0,75 = 70 × 5,4^0,75 = 248 kcal\n'
        'Fator 1,6 (castrada) → meta de 397 kcal por dia\n'
        'Estimativa educativa. Não substitui a avaliação do veterinário.',
      );
      expect(tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Voltar ao perfil')).variante, PaBotaoVariante.primario);

      await tester.tap(find.widgetWithText(PaBotao, botao));
      await tester.pumpAndSettle();
      expect(find.byType(DialogoComoMeta), findsNothing, reason: botao);
    }
  });
}
