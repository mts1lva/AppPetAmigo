import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/app/app.dart';
import 'package:petamigo/app/router.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/inicio/apresentacao/telas/tela_inicio.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pet_atual_provider.dart';
import 'package:petamigo/features/pets/apresentacao/telas/tela_vamos_comecar.dart';

import '../apoio/inicio_falso.dart';

/// A tela da aba visível: o Início real (o título dele é a saudação) ou o
/// título da tela provisória (a palavra também aparece na navegação).
Finder tituloDaAba(String titulo) => titulo == 'Início'
    ? find.byType(TelaInicio)
    : find.descendant(of: find.byType(PaTelaPrincipal), matching: find.text(titulo));

int abaAtiva(WidgetTester tester) => tester.widget<PaNavegacao>(find.byType(PaNavegacao)).indiceAtual;

Future<StreamController<String?>> montarApp(WidgetTester tester, {String? petInicial}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final pet = StreamController<String?>();
  addTearDown(pet.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [petAtualIdProvider.overrideWith((ref) => pet.stream), ...overridesSemBanco()],
      child: const PetAmigoApp(),
    ),
  );
  pet.add(petInicial);
  await tester.pumpAndSettle();
  return pet;
}

void main() {
  group('redirecionarPorPet', () {
    test('carregando → /carregando', () {
      expect(redirecionarPorPet(const AsyncLoading(), Rotas.inicio), Rotas.carregando);
      expect(redirecionarPorPet(const AsyncLoading(), Rotas.carregando), isNull);
    });

    test('sem pet → /comecar', () {
      expect(redirecionarPorPet(const AsyncData(null), Rotas.inicio), Rotas.comecar);
      expect(redirecionarPorPet(const AsyncData(null), Rotas.diario), Rotas.comecar);
      expect(redirecionarPorPet(const AsyncData(null), Rotas.comecar), isNull);
    });

    test('com pet: sai do 26 e do carregamento para o Início; nas abas, fica', () {
      expect(redirecionarPorPet(const AsyncData('p1'), Rotas.comecar), Rotas.inicio);
      expect(redirecionarPorPet(const AsyncData('p1'), Rotas.carregando), Rotas.inicio);
      expect(redirecionarPorPet(const AsyncData('p1'), Rotas.diario), isNull);
    });
  });

  group('Navegação', () {
    testWidgets('sem pet: mostra o 26 "Vamos começar?" sem a navegação inferior', (tester) async {
      await montarApp(tester);

      expect(find.byType(TelaVamosComecar), findsOneWidget);
      expect(find.text('Vamos começar?'), findsOneWidget);
      expect(find.text('Cadastre seu cão ou gato.'), findsOneWidget);
      expect(find.byType(PaNavegacao), findsNothing);
    });

    testWidgets('com pet: Início e 3 abas provisórias; tocar troca a aba', (tester) async {
      await montarApp(tester, petInicial: 'p1');

      expect(find.byType(PaNavegacao), findsOneWidget);
      expect(tituloDaAba('Início'), findsOneWidget);
      expect(abaAtiva(tester), 0);

      for (final (i, aba) in [(1, 'Diário'), (2, 'Atividades'), (3, 'Evolução'), (0, 'Início')]) {
        await tester.tap(find.descendant(of: find.byType(PaNavegacao), matching: find.text(aba)));
        await tester.pumpAndSettle();
        expect(tituloDaAba(aba), findsOneWidget);
        expect(abaAtiva(tester), i);
      }
    });

    testWidgets('botão voltar numa aba ≠ Início vai para o Início', (tester) async {
      await montarApp(tester, petInicial: 'p1');
      await tester.tap(find.descendant(of: find.byType(PaNavegacao), matching: find.text('Evolução')));
      await tester.pumpAndSettle();

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(abaAtiva(tester), 0);
      expect(tituloDaAba('Início'), findsOneWidget);
    });

    testWidgets('cadastrar o primeiro pet leva ao Início; excluir o último volta ao 26', (tester) async {
      final pet = await montarApp(tester);
      expect(find.byType(TelaVamosComecar), findsOneWidget);

      pet.add('p1');
      await tester.pumpAndSettle();
      expect(tituloDaAba('Início'), findsOneWidget);
      expect(find.byType(PaNavegacao), findsOneWidget);

      pet.add(null);
      await tester.pumpAndSettle();
      expect(find.byType(TelaVamosComecar), findsOneWidget);
      expect(find.byType(PaNavegacao), findsNothing);
    });
  });
}
