// P4-2.1 — S3 no card de sugestões do Início e conferência R06 (tela 25) na
// edição do peso inicial do formulário 05.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/sugestao.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/evolucao/domain/sugestao_objetivo.dart';
import 'package:petamigo/features/inicio/apresentacao/providers/sugestoes_provider.dart';
import 'package:petamigo/features/pets/apresentacao/telas/dialogo_dados_pet.dart';

import '../apoio/evolucao_falsa.dart';
import '../apoio/inicio_falso.dart';
import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

final hoje = DateTime(2026, 9, 30, 9);

Pesagem pesagem(String id, double kg, DateTime data) => Pesagem(id: id, petId: 'p1', pesoKg: kg, dataHora: data);

/// 5,6 (16/09), 5,5 (23/09), 5,4 (30/09).
final pesagensLuna = [
  pesagem('w1', 5.6, DateTime(2026, 9, 16, 8)),
  pesagem('w2', 5.5, DateTime(2026, 9, 23, 8)),
  pesagem('w3', 5.4, DateTime(2026, 9, 30, 8)),
];

Referencia objetivo(double kg) =>
    Referencia(id: 'r1', petId: 'p1', objetivoKg: kg, origem: OrigemReferencia.veterinario, data: DateTime(2026, 9, 1));

const textoPerto = 'Luna está perto do peso ideal. Converse com o veterinário sobre passar para manutenção.';

void main() {
  group('S3 a partir dos registros', () {
    Sugestao? s3(List<Pesagem> pesagens, Referencia? r, {double? kgDia}) => sugestaoMudarObjetivoDosRegistros(
          nomePet: 'Luna',
          pesagens: pesagens,
          referencia: r,
          kgDia: kgDia,
          hoje: hoje,
        );

    test('(a) peso atual a até 2% do objetivo', () {
      expect(s3(pesagensLuna, objetivo(5.35))?.texto, textoPerto);
    });

    test('(a) passou do ideal (evolução acima de 100%)', () {
      expect(s3(pesagensLuna, objetivo(5.0), kgDia: -0.01), isNull, reason: 'longe e ainda não passou');
      final passou = [pesagem('w1', 5.6, DateTime(2026, 9, 16)), pesagem('w2', 4.5, DateTime(2026, 9, 30))];
      expect(s3(passou, objetivo(5.0))?.texto, textoPerto);
    });

    test('(b) ritmo não alcança o objetivo, com 14 dias de dados', () {
      expect(s3(pesagensLuna, objetivo(4.5), kgDia: 0)?.texto, textoObjetivoDistante);
    });

    test('sem pesagem ou sem peso ideal → nenhuma sugestão', () {
      expect(s3(const [], objetivo(4.5)), isNull);
      expect(s3(pesagensLuna, null), isNull);
    });
  });

  group('sugestoesProvider com a S3 (P4-2.1)', () {
    Future<List<Sugestao>> sugestoes(EvolucaoFalsa dados) async {
      final container = ProviderContainer(overrides: [
        ...dados.overrides,
        sugestoesAdiadasRepositorioProvider.overrideWithValue(AdiadasFalsas()),
      ]);
      addTearDown(container.dispose);
      container.listen(sugestoesProvider('p1'), (_, _) {});
      await pumpEventQueue();
      return container.read(sugestoesProvider('p1'));
    }

    test('perto do objetivo → a S3 aparece no card do Início', () async {
      final lista = await sugestoes(EvolucaoFalsa(pesagens: pesagensLuna, referencia: objetivo(5.35), agora: hoje));
      expect(lista, [const Sugestao(tipo: TipoSugestao.mudarObjetivo, texto: textoPerto)]);
    });

    test('sem referência → nenhuma sugestão', () async {
      expect(await sugestoes(EvolucaoFalsa(pesagens: pesagensLuna, agora: hoje)), isEmpty);
    });
  });

  group('05 — conferência R06 do peso inicial (U2-06)', () {
    Future<PetsFalsos> abrir(WidgetTester tester) async {
      tester.view
        ..physicalSize = const Size(390, 844)
        ..devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final pets = PetsFalsos(iniciais: [(luna(), 5.6)])
        ..pesagensExtras['p1'] = [pesagem('w2', 5.4, DateTime(2026, 9, 23, 8))];
      await tester.pumpWidget(ProviderScope(
        overrides: pets.overrides,
        child: appDeTeste(Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: TextButton(onPressed: () => abrirDadosPet(context, petId: 'p1'), child: const Text('abrir')),
            ),
          ),
        )),
      ));
      await tester.tap(find.text('abrir'));
      await tester.pumpAndSettle();
      return pets;
    }

    Future<void> tocar(WidgetTester tester, Finder alvo) async {
      await tester.ensureVisible(alvo);
      await tester.pumpAndSettle();
      await tester.tap(alvo);
      await tester.pumpAndSettle();
    }

    Finder botao(String texto) => find.widgetWithText(PaBotao, texto);

    Future<void> mudarPeso(WidgetTester tester, String texto) async {
      await tester.enterText(find.byType(TextField).last, texto);
      await tocar(tester, botao('Salvar pet'));
    }

    testWidgets('54 com a pesagem seguinte 5,4 → abre o 25 com "Corrigir para 5,4 kg"', (tester) async {
      final pets = await abrir(tester);
      await mudarPeso(tester, '54');

      expect(find.text('Conferir pesagem'), findsOneWidget);
      expect(find.text('Peso informado • 54 kg'), findsOneWidget);
      expect(find.textContaining('Anterior: 5,4 kg.'), findsOneWidget);
      expect(pets.edicoes, isEmpty, reason: 'nada é salvo antes da escolha');
    });

    testWidgets('"Manter valor informado" salva 54 como conferida', (tester) async {
      final pets = await abrir(tester);
      await mudarPeso(tester, '54');
      await tocar(tester, botao('Manter valor informado'));

      expect(pets.edicoes.single.$2, 54);
      expect(pets.conferidos.single, isTrue);
      expect(find.text('Dados de Luna'), findsNothing);
    });

    testWidgets('"Corrigir para 5,4 kg" salva 5,4 sem conferida', (tester) async {
      final pets = await abrir(tester);
      await mudarPeso(tester, '54');
      await tocar(tester, botao('Corrigir para 5,4 kg'));

      expect(pets.edicoes.single.$2, 5.4);
      expect(pets.conferidos.single, isFalse);
    });

    testWidgets('"Voltar" no 25 volta ao 05 sem salvar', (tester) async {
      final pets = await abrir(tester);
      await mudarPeso(tester, '54');
      await tocar(tester, botao('Voltar').last);

      expect(find.text('Dados de Luna'), findsOneWidget);
      expect(pets.edicoes, isEmpty);
    });

    testWidgets('peso comum não abre o 25', (tester) async {
      final pets = await abrir(tester);
      await mudarPeso(tester, '5,5');

      expect(find.text('Conferir pesagem'), findsNothing);
      expect(pets.edicoes.single.$2, 5.5);
      expect(pets.conferidos.single, isFalse);
    });
  });
}
