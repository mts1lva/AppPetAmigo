// P4-1.2 — Tela 11 Pesagem, tela 25 Conferir pesagem e N3 Pesagem salva.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/evolucao/apresentacao/telas/dialogo_pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';

import '../apoio/evolucao_falsa.dart';
import '../apoio/montar.dart';

Pesagem pesagem(String id, double kg, DateTime data, {bool conferida = false}) =>
    Pesagem(id: id, petId: 'p1', pesoKg: kg, dataHora: data, conferida: conferida);

/// 5,6 (16/09, peso inicial), 5,5 (23/09).
List<Pesagem> pesagensLuna() => [
      pesagem('w1', 5.6, DateTime(2026, 9, 16, 8)),
      pesagem('w2', 5.5, DateTime(2026, 9, 23, 8)),
    ];

final ecc7 = Referencia(id: 'r1', petId: 'p1', ecc: 7, origem: OrigemReferencia.veterinario, data: DateTime(2026, 9, 30));

Future<void> abrir(WidgetTester tester, EvolucaoFalsa dados, {String? pesagemId}) async {
  tester.view
    ..physicalSize = const Size(390, 844)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ProviderScope(
    overrides: dados.overrides,
    child: appDeTeste(Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () => abrirPesagem(context, petId: 'p1', pesagemId: pesagemId),
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

Future<void> digitarPeso(WidgetTester tester, String texto) => tester.enterText(find.byType(TextField), texto);

void main() {
  group('11 Pesagem', () {
    testWidgets('nova: título, subtítulo, campos com agora, texto e botões sem "Excluir registro"', (tester) async {
      await abrir(tester, EvolucaoFalsa(pesagens: pesagensLuna()));

      expect(find.text('Pesagem'), findsOneWidget);
      expect(find.text('Valores positivos em quilogramas.'), findsOneWidget);
      expect(find.text('Data • 30 set. 2026'), findsOneWidget);
      expect(find.text('Horário • 09:00'), findsOneWidget);
      expect(
        find.text('Variações suspeitas exigem conferência; o registro não é descartado silenciosamente.'),
        findsOneWidget,
      );
      expect(botao('Salvar peso'), findsOneWidget);
      expect(botao('Excluir registro'), findsNothing);
      expect(botao('Conferir variação'), findsNothing, reason: 'não existe no app');
      expect(botao('Voltar'), findsOneWidget);
    });

    testWidgets('salvar um peso comum grava, fecha e não celebra sem peso ideal', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna());
      await abrir(tester, dados);

      await digitarPeso(tester, '5,4');
      await tocar(tester, botao('Salvar peso'));

      expect(dados.pesagens.salvas.single, pesagem('nova-1', 5.4, DateTime(2026, 9, 30, 9)));
      expect(find.text('Pesagem'), findsNothing);
      expect(find.text('Pesagem salva'), findsNothing);
    });

    testWidgets('R05: vazio, zero e acima de 150 kg mostram o erro e não salvam', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna());
      await abrir(tester, dados);

      await tocar(tester, botao('Salvar peso'));
      expect(find.text('O valor precisa ser positivo.'), findsOneWidget);

      await digitarPeso(tester, '151');
      await tocar(tester, botao('Salvar peso'));
      expect(find.text('Confira o valor: acima de 150 kg.'), findsOneWidget);
      expect(dados.pesagens.salvas, isEmpty);
    });

    testWidgets('editar: preenche com a pesagem e mostra "Excluir registro"', (tester) async {
      await abrir(tester, EvolucaoFalsa(pesagens: pesagensLuna()), pesagemId: 'w2');

      expect(find.text('Pesagem'), findsOneWidget);
      expect(find.text('Data • 23 set. 2026'), findsOneWidget);
      expect(find.text('Horário • 08:00'), findsOneWidget);
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, '5,5');
      expect(botao('Excluir registro'), findsOneWidget);
    });

    testWidgets('Excluir registro → 23 → confirmar exclui e fecha', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna());
      await abrir(tester, dados, pesagemId: 'w2');

      await tocar(tester, botao('Excluir registro'));
      expect(find.text('Confirmar exclusão'), findsWidgets);
      await tocar(tester, botao('Confirmar exclusão'));

      expect(dados.pesagens.excluidas, ['w2']);
      expect(find.text('Pesagem'), findsNothing);
    });

    testWidgets('peso inicial (U2-06): título "Peso inicial" e sem "Excluir registro"', (tester) async {
      await abrir(tester, EvolucaoFalsa(pesagens: pesagensLuna()), pesagemId: 'w1');

      expect(find.text('Peso inicial'), findsOneWidget);
      expect(botao('Excluir registro'), findsNothing);
    });
  });

  group('25 Conferir pesagem (R06)', () {
    testWidgets('54 com anterior 5,5 → abre o 25 com o campo em erro e "Corrigir para 5,4 kg"', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna());
      await abrir(tester, dados);

      await digitarPeso(tester, '54');
      await tocar(tester, botao('Salvar peso'));

      expect(find.text('Conferir pesagem'), findsOneWidget);
      expect(find.text('Valor fora do esperado.'), findsOneWidget);
      expect(find.text('Peso informado • 54 kg'), findsOneWidget);
      expect(
        find.text('Anterior: 5,5 kg. Confira unidade e separador decimal. '
            'Corrija ou mantenha o valor; nenhum dado será descartado silenciosamente.'),
        findsOneWidget,
      );
      expect(botao('Corrigir para 5,4 kg'), findsOneWidget);
      expect(botao('Manter valor informado'), findsOneWidget);
      expect(dados.pesagens.salvas, isEmpty, reason: 'nada é salvo antes da escolha');
    });

    testWidgets('"Corrigir para 5,4 kg" salva o valor sugerido', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna());
      await abrir(tester, dados);

      await digitarPeso(tester, '54');
      await tocar(tester, botao('Salvar peso'));
      await tocar(tester, botao('Corrigir para 5,4 kg'));

      final salva = dados.pesagens.salvas.single;
      expect((salva.pesoKg, salva.conferida), (5.4, false));
      expect(find.text('Pesagem'), findsNothing);
    });

    testWidgets('"Manter valor informado" salva 54 com conferida', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna());
      await abrir(tester, dados);

      await digitarPeso(tester, '54');
      await tocar(tester, botao('Salvar peso'));
      await tocar(tester, botao('Manter valor informado'));

      final salva = dados.pesagens.salvas.single;
      expect((salva.pesoKg, salva.conferida), (54.0, true));
    });

    testWidgets('sem sugestão: "Corrigir valor" volta ao 11 sem salvar', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna());
      await abrir(tester, dados);

      await digitarPeso(tester, '9');
      await tocar(tester, botao('Salvar peso'));
      expect(botao('Corrigir valor'), findsOneWidget);
      await tocar(tester, botao('Corrigir valor'));

      expect(find.text('Pesagem'), findsOneWidget);
      expect(find.text('Conferir pesagem'), findsNothing);
      expect(dados.pesagens.salvas, isEmpty);
    });

    testWidgets('"Voltar" volta ao 11 sem salvar', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna());
      await abrir(tester, dados);

      await digitarPeso(tester, '54');
      await tocar(tester, botao('Salvar peso'));
      await tocar(tester, botao('Voltar').last);

      expect(find.text('Pesagem'), findsOneWidget);
      expect(dados.pesagens.salvas, isEmpty);
    });

    testWidgets('peso inicial compara com a pesagem seguinte', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna());
      await abrir(tester, dados, pesagemId: 'w1');

      await digitarPeso(tester, '55');
      await tocar(tester, botao('Salvar peso'));

      expect(find.textContaining('Anterior: 5,5 kg.'), findsOneWidget);
      expect(botao('Corrigir para 5,5 kg'), findsOneWidget);
    });

    testWidgets('sem pesagem anterior não há conferência', (tester) async {
      final dados = EvolucaoFalsa();
      await abrir(tester, dados);

      await digitarPeso(tester, '54');
      await tocar(tester, botao('Salvar peso'));

      expect(find.text('Conferir pesagem'), findsNothing);
      expect(dados.pesagens.salvas.single.pesoKg, 54);
    });
  });

  group('N3 Pesagem salva (M8)', () {
    testWidgets('aproximou 100 g do ideal → celebração', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna(), referencia: ecc7);
      await abrir(tester, dados);

      // Pi pelo ECC 7 com a pesagem mais próxima da data do ECC (a nova, 5,4).
      await digitarPeso(tester, '5,4');
      await tocar(tester, botao('Salvar peso'));

      expect(find.text('Pesagem salva'), findsOneWidget);
      expect(find.text('Salva neste aparelho.'), findsOneWidget);
      expect(find.byType(PaGatoSorrindo), findsOneWidget);
      expect(find.text('Luna chegou 100 g mais perto do peso ideal!\nContinue no seu ritmo.'), findsOneWidget);
      expect(botao('Ver evolução'), findsOneWidget);

      await tocar(tester, botao('Voltar'));
      expect(find.text('Pesagem salva'), findsNothing);
    });

    testWidgets('afastou do ideal → nenhuma celebração nem mensagem', (tester) async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna(), referencia: ecc7);
      await abrir(tester, dados);

      await digitarPeso(tester, '5,7');
      await tocar(tester, botao('Salvar peso'));

      expect(find.text('Pesagem salva'), findsNothing);
      expect(dados.pesagens.salvas, hasLength(1));
    });
  });
}
