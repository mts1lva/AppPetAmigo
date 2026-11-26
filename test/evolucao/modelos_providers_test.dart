// P4-1.3 — Providers de M9 sobre os streams reais do P2 (refeições, extras,
// aderência) e do P3 (gasto de atividade), com o caso da Luna de M4/M5.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/features/atividades/domain/entidades/atividade.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';
import 'package:petamigo/features/diario/domain/entidades/resumo_dia.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/evolucao_providers.dart';
import 'package:petamigo/features/evolucao/domain/data_prevista.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/evolucao/domain/indicadores.dart';
import 'package:petamigo/features/evolucao/domain/modelos_do_pet.dart';

import '../apoio/evolucao_falsa.dart';

final hoje = DateTime(2026, 9, 30, 9);

Pesagem pesagem(String id, double kg, DateTime data) => Pesagem(id: id, petId: 'p1', pesoKg: kg, dataHora: data);

final pesagensLuna = [
  pesagem('w1', 5.6, DateTime(2026, 9, 16, 8)),
  pesagem('w2', 5.5, DateTime(2026, 9, 23, 8)),
  pesagem('w3', 5.4, DateTime(2026, 9, 30, 8)),
];

final ecc7 = Referencia(id: 'r1', petId: 'p1', ecc: 7, origem: OrigemReferencia.veterinario, data: DateTime(2026, 9, 30));

/// 120 kcal num dia (uma refeição só).
Refeicao refeicao(String id, DateTime dia, {double kcal = 120}) => Refeicao(
      id: id,
      petId: 'p1',
      alimentoNome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      quantidadeG: kcal / 3.6,
      energiaKcal: kcal,
      dataHora: DateTime(dia.year, dia.month, dia.day, 8),
    );

/// 120 kcal em 28, 29 e 30/09.
final refeicoesLuna = [
  for (final d in [28, 29, 30]) refeicao('m$d', DateTime(2026, 9, d)),
];

/// Brincadeira de 10 min em 28, 29 e 30/09.
final atividadesLuna = [
  for (final d in [28, 29, 30])
    Atividade(id: 'a$d', petId: 'p1', tipo: TipoAtividade.brincadeira, duracaoMin: 10, dataHora: DateTime(2026, 9, d, 7)),
];

Future<ProviderContainer> montar(EvolucaoFalsa dados) async {
  final c = ProviderContainer(overrides: dados.overrides);
  addTearDown(c.dispose);
  c.listen(modelosProvider('p1'), (_, _) {});
  await pumpEventQueue();
  return c;
}

void main() {
  group('caso completo da Luna (M4/M5)', () {
    late ProviderContainer c;

    setUp(() async {
      c = await montar(EvolucaoFalsa(
        pesagens: pesagensLuna,
        referencia: ecc7,
        refeicoes: refeicoesLuna,
        atividades: atividadesLuna,
        agora: hoje,
      ));
    });

    test('M2: peso ideal 4,5 kg (estimado pelo ECC 7)', () {
      final ideal = c.read(pesoIdealProvider('p1'))!.valorOuNulo!;
      expect(ideal.kg, closeTo(4.5, 1e-9));
      expect(ideal.rotulo, '(estimado pelo ECC 7)');
    });

    test('M4: pesagens + refeições do P2 + atividade do P3 → −0,015429 limitado', () {
      final p = c.read(projecaoProvider('p1'))!.valorOuNulo!;
      expect(p.observada, closeTo(-0.014286, 0.0000005));
      expect(p.energetica, closeTo(-0.036085, 0.0000005));
      expect(p.kgDia, closeTo(-0.015429, 0.0000005));
      expect(p.limitada, isTrue);
    });

    test('M3: curva ideal(90) 4,745', () {
      expect(c.read(curvaIdealProvider('p1'))!.valorOuNulo![90], closeTo(4.745, 0.0005));
    });

    test('M5: 28 nov. 2026', () {
      expect(c.read(dataPrevistaProvider('p1'))!.texto, '28 nov. 2026');
    });

    test('M7: evolução 18% do caminho', () {
      expect(c.read(indicadoresProvider('p1'))!.texto, '18% do caminho');
    });
  });

  group('recalcula sozinho (U2-05)', () {
    test('uma refeição nova muda a projeção e a previsão sem nenhum "atualizar"', () async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna, referencia: ecc7, refeicoes: refeicoesLuna.take(2).toList(), agora: hoje);
      final c = await montar(dados);
      final antes = c.read(projecaoProvider('p1'))!.valorOuNulo!;
      expect(antes.energetica, isNull, reason: 'só 2 dias com registro');
      expect(c.read(dataPrevistaProvider('p1'))!.texto, '02 dez. 2026');

      await dados.diario.refeicoes.salvar(refeicoesLuna.last, agora: hoje);
      await pumpEventQueue();

      final depois = c.read(projecaoProvider('p1'))!.valorOuNulo!;
      expect(depois.energetica, isNotNull);
      expect(c.read(dataPrevistaProvider('p1'))!.texto, isNot('02 dez. 2026'));
    });

    test('editar o peso inicial atualiza a evolução (U2-06)', () async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna, referencia: ecc7, agora: hoje);
      final c = await montar(dados);
      expect(c.read(indicadoresProvider('p1'))!.texto, '18% do caminho');

      await dados.pesagens.salvar(pesagem('w1', 6.3, DateTime(2026, 9, 16, 8)), agora: hoje);
      await pumpEventQueue();

      // (6,3 − 5,4) ÷ (6,3 − 4,5) = 50%.
      expect(c.read(indicadoresProvider('p1'))!.texto, '50% do caminho');
    });

    test('uma atividade nova muda a parte energética', () async {
      final dados = EvolucaoFalsa(pesagens: pesagensLuna, referencia: ecc7, refeicoes: refeicoesLuna, agora: hoje);
      final c = await montar(dados);
      final antes = c.read(projecaoProvider('p1'))!.valorOuNulo!.energetica!;

      await dados.atividades.salvar(atividadesLuna.first, agora: hoje);
      await pumpEventQueue();

      expect(c.read(projecaoProvider('p1'))!.valorOuNulo!.energetica!, lessThan(antes));
    });
  });

  group('sem dados (M10)', () {
    test('nenhuma pesagem: tudo indisponível, sem exceção', () async {
      final c = await montar(EvolucaoFalsa(agora: hoje));
      expect(c.read(projecaoProvider('p1')), isA<Indisponivel<dynamic>>());
      expect(c.read(curvaIdealProvider('p1')), isA<Indisponivel<dynamic>>());
      expect(c.read(dataPrevistaProvider('p1'))!.situacao, SituacaoPrevisao.semPesoIdeal);
      expect(c.read(indicadoresProvider('p1'))!.situacao, SituacaoEvolucao.indisponivel);
    });

    test('sem referência: sem curva ideal, mas com projeção', () async {
      final c = await montar(EvolucaoFalsa(pesagens: pesagensLuna, agora: hoje));
      expect(c.read(curvaIdealProvider('p1')), isA<Indisponivel<dynamic>>());
      expect(c.read(projecaoProvider('p1')), isA<Disponivel<dynamic>>());
      expect(c.read(dataPrevistaProvider('p1'))!.texto, 'Defina o ECC ou o objetivo para estimar.');
    });
  });

  test('ingestaoPorDia: só os dias com registro (R09), ração + extras', () {
    final dias = [
      ResumoDia(dia: DateTime(2026, 9, 29), racaoKcal: 0, extrasKcal: 0, registros: 0),
      ResumoDia(dia: DateTime(2026, 9, 30), racaoKcal: 108, extrasKcal: 12, registros: 2),
    ];
    expect(ingestaoPorDia(dias), {DateTime(2026, 9, 30): 120.0});
  });
}
