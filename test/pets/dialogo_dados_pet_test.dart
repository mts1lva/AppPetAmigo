import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/pets/apresentacao/telas/dialogo_dados_pet.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

Future<void> abrir(WidgetTester tester, PetsFalsos pets, {String? petId}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: pets.overrides,
    child: appDeTeste(Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(onPressed: () => abrirDadosPet(context, petId: petId), child: const Text('abrir')),
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

Future<void> escolher(WidgetTester tester, String campo, String opcao) async {
  await tocar(tester, find.textContaining('$campo • '));
  await tocar(tester, find.widgetWithText(PaBotao, opcao));
}

Finder botao(String texto) => find.widgetWithText(PaBotao, texto);

void main() {
  group('05 Dados do pet — cadastro', () {
    testWidgets('título, subtítulo, campos na ordem da spec e sem "Excluir este pet"', (tester) async {
      await abrir(tester, PetsFalsos());

      expect(find.text('Dados do pet'), findsOneWidget);
      expect(find.text('Cadastro e edição no mesmo formulário.'), findsOneWidget);
      final rotulos = ['Nome • ', 'Espécie • ', 'Sexo • ', 'Idade • ', 'Castração • ', 'Atividade • ', 'Peso inicial • '];
      final ys = [for (final r in rotulos) tester.getTopLeft(find.textContaining(r).first).dy];
      expect(ys, orderedEquals([...ys]..sort()));
      expect(botao('Excluir este pet'), findsNothing);
      for (final b in ['Adicionar ou trocar foto', 'Salvar pet', 'Voltar']) {
        expect(botao(b), findsOneWidget);
      }
    });

    testWidgets('Idade: anos e depois meses, exibida como "6 anos"', (tester) async {
      await abrir(tester, PetsFalsos());

      await tocar(tester, find.textContaining('Idade • '));
      expect(find.text('Idade (anos)'), findsOneWidget);
      await tocar(tester, botao('6 anos'));
      expect(find.text('Idade (meses)'), findsOneWidget);
      await tocar(tester, botao('3 meses'));

      expect(find.text('Idade • 6 anos'), findsOneWidget);
    });

    testWidgets('preencher e salvar grava o pet com o peso inicial e fecha o diálogo', (tester) async {
      final pets = PetsFalsos();
      await abrir(tester, pets);

      await tester.enterText(find.byType(TextField).first, 'Luna');
      await escolher(tester, 'Espécie', 'Gato');
      await escolher(tester, 'Sexo', 'Fêmea');
      await tocar(tester, find.textContaining('Idade • '));
      await tocar(tester, botao('6 anos'));
      await tocar(tester, botao('0 meses'));
      await escolher(tester, 'Castração', 'Sim');
      await escolher(tester, 'Atividade', 'Moderada');
      await tester.enterText(find.byType(TextField).last, '5,4');
      await tocar(tester, botao('Salvar pet'));

      final (pet, peso) = pets.cadastros.single;
      expect((pet.nome, pet.especie, pet.sexo, pet.idadeMeses, pet.castrado, pet.nivelAtividade),
          ('Luna', Especie.gato, Sexo.femea, 72, true, NivelAtividade.moderada));
      expect(peso, 5.4);
      expect(find.byType(DialogoDadosPet), findsNothing);
    });

    testWidgets('R05: salvar vazio mostra os erros, não grava e não fecha', (tester) async {
      final pets = PetsFalsos();
      await abrir(tester, pets);

      await tocar(tester, botao('Salvar pet'));

      expect(pets.cadastros, isEmpty);
      expect(find.byType(DialogoDadosPet), findsOneWidget);
      expect(find.text('Informe o nome.'), findsOneWidget);
      expect(find.text('Informe a idade.'), findsOneWidget);
      expect(find.text('O valor precisa ser positivo.'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField).first).focusNode!.hasFocus, isTrue,
          reason: 'o foco vai ao primeiro campo com erro');

      await tester.enterText(find.byType(TextField).first, 'Luna');
      await tester.pump();
      expect(find.text('Informe o nome.'), findsNothing, reason: 'corrigir o campo tira o erro');
    });

    testWidgets('peso acima de 150 kg', (tester) async {
      await abrir(tester, PetsFalsos());
      await tester.enterText(find.byType(TextField).last, '151');
      await tocar(tester, botao('Salvar pet'));
      expect(find.text('Confira o valor: acima de 150 kg.'), findsOneWidget);
    });
  });

  group('05 Dados do pet — edição', () {
    testWidgets('preenche com os dados salvos, inclusive o peso inicial', (tester) async {
      await abrir(tester, PetsFalsos(iniciais: [(luna(), 5.4)]), petId: 'p1');

      expect(find.text('Dados de Luna'), findsOneWidget);
      expect(find.text('Espécie • Gato'), findsOneWidget);
      expect(find.text('Sexo • Fêmea'), findsOneWidget);
      expect(find.text('Idade • 6 anos'), findsOneWidget);
      expect(find.text('Castração • Sim'), findsOneWidget);
      expect(find.text('Atividade • Moderada'), findsOneWidget);
      expect(find.text('5,4'), findsOneWidget);
    });

    testWidgets('salvar sem mexer no peso não regrava a pesagem; mudar o peso inicial regrava (U2-06)',
        (tester) async {
      final pets = PetsFalsos(iniciais: [(luna(), 5.4)]);
      await abrir(tester, pets, petId: 'p1');
      await tester.enterText(find.byType(TextField).first, 'Mia');
      await tocar(tester, botao('Salvar pet'));
      expect(pets.edicoes.single.$1.nome, 'Mia');
      expect(pets.edicoes.single.$2, isNull);

      await tocar(tester, find.text('abrir'));
      await tester.enterText(find.byType(TextField).last, '5.6');
      await tocar(tester, botao('Salvar pet'));
      expect(pets.edicoes.last.$2, 5.6);
    });

    testWidgets('com um pet só, não há "Excluir este pet"', (tester) async {
      await abrir(tester, PetsFalsos(iniciais: [(luna(), 5.4)]), petId: 'p1');
      expect(botao('Excluir este pet'), findsNothing);
    });

    testWidgets('com 2 ou mais pets, "Excluir este pet" confirma na tela 23 e exclui', (tester) async {
      final pets = PetsFalsos(iniciais: [(luna(), 5.4), (luna(id: 'p2', nome: 'Thor'), 20)]);
      await abrir(tester, pets, petId: 'p1');
      expect(tester.widget<PaBotao>(botao('Excluir este pet')).variante, PaBotaoVariante.perigo);

      await tocar(tester, botao('Excluir este pet'));
      expect(find.text('Confirmar exclusão'), findsWidgets);
      await tocar(tester, botao('Cancelar'));
      expect(pets.exclusoes, isEmpty);
      expect(find.byType(DialogoDadosPet), findsOneWidget);

      await tocar(tester, botao('Excluir este pet'));
      await tocar(tester, botao('Confirmar exclusão'));
      expect(pets.exclusoes, ['p1']);
      expect(find.byType(DialogoDadosPet), findsNothing);
    });
  });
}
