// P-32 — petiscos cadastrados, por unidade: tela 09 (Tipo), atalho 06
// (petisco na lista, grava extra, "Petisco salvo"), tela 08 (escolha do
// petisco) e a linha do Diário.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_alimentos.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_atalho.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_petisco.dart';
import 'package:petamigo/features/diario/domain/energia.dart';
import 'package:petamigo/features/diario/domain/entidades/extra.dart';
import 'package:petamigo/features/diario/domain/entidades/petisco.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';

import '../apoio/diario_falso.dart';
import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

const bifinho = Petisco(id: 'b1', petId: 'p1', nome: 'Bifinho', kcalPorUnidade: 3, unidadesHabituais: 2);

Future<void> abrir(WidgetTester tester, DiarioFalsos diario, void Function(BuildContext) abrirTela) async {
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
    ],
    child: appDeTeste(Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(onPressed: () => abrirTela(context), child: const Text('abrir')),
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

/// O `PaCampo` mostra o rótulo como `Rótulo • ` antes do texto digitado.
Finder rotuloDe(String rotulo) => find.text('$rotulo • ');

Finder campo(String rotulo) => find.descendant(
      of: find.ancestor(of: rotuloDe(rotulo), matching: find.byType(PaCampo)),
      matching: find.byType(TextField),
    );

void main() {
  group('09 com o Tipo Petisco', () {
    testWidgets('troca os campos e grava o petisco por unidade', (tester) async {
      final diario = DiarioFalsos();
      await abrir(tester, diario, (c) => abrirAlimentos(c, petId: 'p1'));

      expect(find.text('$rotuloTipo • $opcaoTipoRacao'), findsOneWidget);
      await tocar(tester, find.text('$rotuloTipo • $opcaoTipoRacao'));
      await tocar(tester, botao(opcaoTipoPetisco));

      expect(rotuloDe(rotuloDensidade), findsNothing);
      expect(rotuloDe(rotuloEnergiaPorUnidade), findsOneWidget);
      await tester.enterText(find.byType(TextField).at(0), 'Bifinho');
      await tester.enterText(campo(rotuloEnergiaPorUnidade), '3');
      await tester.enterText(campo(rotuloUnidadesHabituais), '2');
      await tocar(tester, botao(botaoSalvarAlimento));

      final p = diario.petiscos.salvos.single;
      expect((p.nome, p.kcalPorUnidade, p.unidadesHabituais), ('Bifinho', 3, 2));
      expect(diario.alimentos.salvos, isEmpty);
      expect(find.byType(DialogoAlimentos), findsNothing);
    });

    testWidgets('unidades fracionárias e energia zero mostram os textos de R05', (tester) async {
      final diario = DiarioFalsos();
      await abrir(tester, diario, (c) => abrirAlimentos(c, petId: 'p1'));
      await tocar(tester, find.text('$rotuloTipo • $opcaoTipoRacao'));
      await tocar(tester, botao(opcaoTipoPetisco));
      await tester.enterText(find.byType(TextField).at(0), 'Bifinho');
      await tester.enterText(campo(rotuloEnergiaPorUnidade), '0');
      await tester.enterText(campo(rotuloUnidadesHabituais), '1,5');
      await tocar(tester, botao(botaoSalvarAlimento));

      expect(find.text(motivoEnergiaPorUnidadeInvalida), findsOneWidget);
      expect(find.text(motivoUnidadesInvalidas), findsOneWidget);
      expect(diario.petiscos.salvos, isEmpty);
    });

    testWidgets('a lista do tipo Petisco só traz petiscos', (tester) async {
      await abrir(
        tester,
        DiarioFalsos(alimentos: [racaoHabitual()], petiscos: [bifinho]),
        (c) => abrirAlimentos(c, petId: 'p1'),
      );
      await tocar(tester, find.text('$rotuloTipo • $opcaoTipoRacao'));
      await tocar(tester, botao(opcaoTipoPetisco));
      await tocar(tester, find.text('$rotuloAlimento • $rotuloNovoAlimento'));

      expect(botao('Bifinho'), findsOneWidget);
      expect(botao('Ração habitual'), findsNothing);
    });
  });

  group('06 com petisco cadastrado', () {
    testWidgets('a lista traz o petisco com "(petisco)" e o atalho continua na ração', (tester) async {
      await abrir(
        tester,
        DiarioFalsos(alimentos: [racaoHabitual()], petiscos: [bifinho]),
        (c) => abrirAtalho(c, petId: 'p1'),
      );

      expect(find.text('$rotuloAlimento • Ração habitual'), findsOneWidget);
      await tocar(tester, find.text('$rotuloAlimento • Ração habitual'));
      expect(botao(rotuloPetiscoNaLista('Bifinho')), findsOneWidget);
    });

    testWidgets('2 toques com o petisco gravam um extra e abrem "Petisco salvo"', (tester) async {
      final diario = DiarioFalsos(alimentos: [racaoHabitual()], petiscos: [bifinho]);
      await abrir(tester, diario, (c) => abrirAtalho(c, petId: 'p1'));
      await tocar(tester, find.text('$rotuloAlimento • Ração habitual'));
      await tocar(tester, botao(rotuloPetiscoNaLista('Bifinho')));

      expect(find.textContaining('Energia do rótulo: 3 kcal por unidade.'), findsOneWidget);
      expect(find.textContaining('Meta de hoje: 397 kcal'), findsOneWidget);
      expect(find.textContaining('≈'), findsNothing);
      expect(find.text('$rotuloCampoPorcao • ${rotuloPorcaoPetiscoHabitual(2, 6)}'), findsOneWidget);

      await tocar(tester, botao(botaoConfirmarPetisco));

      expect(diario.refeicoes.salvas, isEmpty);
      final e = diario.extras.salvos.single;
      expect((e.descricao, e.alimentoId, e.unidades, e.energiaKcal), ('Bifinho', 'b1', 2, 6));
      expect(find.text(tituloPetiscoSalvo), findsOneWidget);
      expect(find.text(tituloRefeicaoSalva), findsNothing);
    });

    testWidgets('"1 unidade" grava 3 kcal; com habitual 1 a opção não repete', (tester) async {
      final diario = DiarioFalsos(petiscos: [bifinho]);
      await abrir(tester, diario, (c) => abrirAtalho(c, petId: 'p1'));

      await tocar(tester, find.text('$rotuloCampoPorcao • ${rotuloPorcaoPetiscoHabitual(2, 6)}'));
      await tocar(tester, botao(rotuloPorcaoPetiscoUma(3)));
      await tocar(tester, botao(botaoConfirmarPetisco));
      expect((diario.extras.salvos.single.unidades, diario.extras.salvos.single.energiaKcal), (1, 3));
    });

    testWidgets('sem ração, começa no petisco; "Outra quantidade…" abre o 08 com ele', (tester) async {
      final diario = DiarioFalsos(petiscos: [bifinho.copyWith(unidadesHabituais: 1)]);
      await abrir(tester, diario, (c) => abrirAtalho(c, petId: 'p1'));

      await tocar(tester, find.text('$rotuloCampoPorcao • ${rotuloPorcaoPetiscoHabitual(1, 3)}'));
      expect(botao(rotuloPorcaoPetiscoUma(3)), findsNothing);
      await tocar(tester, botao(rotuloOutraQuantidade));

      expect(find.byType(DialogoPetisco), findsOneWidget);
      expect(find.text('$rotuloPetisco • Bifinho'), findsOneWidget);
      expect(diario.extras.salvos, isEmpty);
    });
  });

  group('08 com petisco cadastrado', () {
    testWidgets('registro novo vem com o petisco mais recente e calcula a energia', (tester) async {
      final diario = DiarioFalsos(petiscos: [bifinho]);
      await abrir(tester, diario, (c) => abrirPetisco(c, petId: 'p1'));

      expect(find.text('$rotuloPetisco • Bifinho'), findsOneWidget);
      expect(rotuloDe(rotuloDescricao), findsNothing);
      expect(find.textContaining('6 kcal $textoEnergiaRotuloSufixo'), findsOneWidget);

      await tester.enterText(campo(rotuloUnidades), '3');
      await tester.pump();
      expect(find.textContaining('9 kcal $textoEnergiaRotuloSufixo'), findsOneWidget);
      await tocar(tester, botao(botaoSalvarPetisco));

      final e = diario.extras.salvos.single;
      expect((e.descricao, e.alimentoId, e.unidades, e.energiaKcal, e.quantidadeG), ('Bifinho', 'b1', 3, 9, null));
    });

    testWidgets('"Outro petisco…" volta aos campos digitados de sempre', (tester) async {
      final diario = DiarioFalsos(petiscos: [bifinho]);
      await abrir(tester, diario, (c) => abrirPetisco(c, petId: 'p1'));
      await tocar(tester, find.text('$rotuloPetisco • Bifinho'));
      await tocar(tester, botao(rotuloOutroPetisco));

      expect(find.text(descricaoPetiscoPadrao), findsOneWidget);
      await tester.enterText(campo(rotuloEnergiaInformada), '12');
      await tocar(tester, botao(botaoSalvarPetisco));

      final e = diario.extras.salvos.single;
      expect((e.descricao, e.energiaKcal, e.alimentoId, e.unidades), ('Petisco', 12, null, null));
    });

    testWidgets('unidades inválidas mostram o texto de R05 e não gravam', (tester) async {
      final diario = DiarioFalsos(petiscos: [bifinho]);
      await abrir(tester, diario, (c) => abrirPetisco(c, petId: 'p1'));
      await tester.enterText(campo(rotuloUnidades), '0');
      await tocar(tester, botao(botaoSalvarPetisco));

      expect(find.text(motivoUnidadesInvalidas), findsOneWidget);
      expect(diario.extras.salvos, isEmpty);
    });

    testWidgets('editar usa a energia por unidade copiada, mesmo com o petisco arquivado', (tester) async {
      final antigo = Extra(
        id: 'e9',
        petId: 'p1',
        descricao: 'Bifinho',
        energiaKcal: 4, // 2 unidades × 2 kcal, antes de o rótulo mudar para 3
        dataHora: DateTime(2026, 9, 30, 8),
        alimentoId: 'b1',
        unidades: 2,
      );
      final diario = DiarioFalsos(petiscos: [bifinho.copyWith(arquivado: true)], extras: [antigo]);
      await abrir(tester, diario, (c) => abrirPetisco(c, petId: 'p1', extraId: 'e9'));

      expect(find.text('$rotuloPetisco • Bifinho'), findsOneWidget);
      await tester.enterText(campo(rotuloUnidades), '3');
      await tocar(tester, botao(botaoSalvarPetisco));

      final e = diario.extras.salvos.single;
      expect((e.id, e.unidades, e.energiaKcal, e.alimentoId), ('e9', 3, 6, 'b1'));
    });
  });

  group('linha do Diário (02)', () {
    test('petisco cadastrado mostra as unidades', () {
      final e = Extra(
        id: 'e1',
        petId: 'p1',
        descricao: 'Bifinho',
        energiaKcal: 6,
        dataHora: DateTime(2026, 9, 30, 12),
        alimentoId: 'b1',
        unidades: 2,
      );
      expect(linhaExtra(e), '12:00 • Bifinho • 2 un. • 6 kcal');
      expect(rotuloSemanticoExtra(e), 'Editar registro: 12:00, Bifinho, 2 unidades, 6 quilocalorias');
    });

    test('petisco digitado continua igual', () {
      final e = Extra(id: 'e1', petId: 'p1', descricao: 'Petisco', quantidadeG: 3, energiaKcal: 12, dataHora: DateTime(2026, 9, 30, 12));
      expect(linhaExtra(e), '12:00 • Petisco • 3 g • 12 kcal');
    });
  });
}
