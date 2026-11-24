import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/pets/apresentacao/telas/dialogo_dados_pet.dart';
import 'package:petamigo/features/pets/apresentacao/telas/dialogo_seus_pets.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

Future<void> abrir(WidgetTester tester, PetsFalsos pets) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: pets.overrides,
    child: appDeTeste(Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(onPressed: () => abrirSeusPets(context), child: const Text('abrir')),
        ),
      ),
    )),
  ));
  await tester.tap(find.text('abrir'));
  await tester.pumpAndSettle();
}

/// Thor: cão macho filhote de 6 meses.
Pet thor() => luna(id: 'p2', nome: 'Thor').copyWith(especie: Especie.cao, sexo: Sexo.macho, idadeMeses: 6);

void main() {
  testWidgets('título, subtítulo e uma linha por pet com o atual marcado', (tester) async {
    // O último dos iniciais é o pet atual.
    await abrir(tester, PetsFalsos(iniciais: [(thor(), 3), (luna(), 5.4)]));

    expect(find.text('Seus pets'), findsOneWidget);
    expect(find.text('Cada pet tem histórico, metas e lembretes próprios.'), findsOneWidget);
    final linhas = tester.widgetList<PaHistorico>(find.byType(PaHistorico)).map((h) => h.texto).toList();
    expect(linhas, [
      'Thor • Cão filhote • 6 meses',
      'Luna • Gata • 6 anos • atual',
    ]);
    expect(tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Cadastrar outro pet')).variante,
        PaBotaoVariante.primario);
    expect(tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Voltar')).variante, PaBotaoVariante.secundario);
  });

  testWidgets('tocar num pet o torna o atual e fecha', (tester) async {
    final pets = PetsFalsos(iniciais: [(thor(), 3), (luna(), 5.4)]);
    await abrir(tester, pets);

    await tester.tap(find.textContaining('Thor •'));
    await tester.pumpAndSettle();

    expect(pets.atual, 'p2');
    expect(find.byType(DialogoSeusPets), findsNothing);
  });

  testWidgets('"Cadastrar outro pet" fecha o N1 e abre o 05 em modo cadastro', (tester) async {
    await abrir(tester, PetsFalsos(iniciais: [(luna(), 5.4)]));

    await tester.tap(find.widgetWithText(PaBotao, 'Cadastrar outro pet'));
    await tester.pumpAndSettle();

    expect(find.byType(DialogoSeusPets), findsNothing);
    expect(find.byType(DialogoDadosPet), findsOneWidget);
    expect(find.text('Dados do pet'), findsOneWidget);
  });

  testWidgets('"Voltar" fecha sem trocar o pet', (tester) async {
    final pets = PetsFalsos(iniciais: [(thor(), 3), (luna(), 5.4)]);
    await abrir(tester, pets);

    await tester.tap(find.widgetWithText(PaBotao, 'Voltar'));
    await tester.pumpAndSettle();

    expect(find.byType(DialogoSeusPets), findsNothing);
    expect(pets.atual, 'p1');
  });
}
