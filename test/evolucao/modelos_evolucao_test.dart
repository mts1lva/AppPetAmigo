// Domínio da evolução (P4-0.1): R06, M2, M3, M6, M7 e M8 (S3 e celebração).
// Casos de `docs/specs/comum/modelos-matematicos.md` e `regras.md`. O M4 e o
// M5 estão no teste oficial T4 (`projecao_test.dart`).

import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/core/sugestao.dart';
import 'package:petamigo/features/evolucao/domain/celebracao.dart';
import 'package:petamigo/features/evolucao/domain/curva_ideal.dart';
import 'package:petamigo/features/evolucao/domain/data_prevista.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/evolucao/domain/grafico_dados.dart';
import 'package:petamigo/features/evolucao/domain/indicadores.dart';
import 'package:petamigo/features/evolucao/domain/pesagem_suspeita.dart';
import 'package:petamigo/features/evolucao/domain/sugestao_objetivo.dart';
import 'package:petamigo/features/evolucao/domain/peso_ideal.dart';

final hoje = DateTime(2026, 9, 30);

Pesagem pesagem(String id, double kg, DateTime data, {bool conferida = false}) =>
    Pesagem(id: id, petId: 'luna', pesoKg: kg, dataHora: data, conferida: conferida);

final pesagensLuna = [
  pesagem('p1', 5.6, DateTime(2026, 9, 16, 8)),
  pesagem('p2', 5.5, DateTime(2026, 9, 23, 8)),
  pesagem('p3', 5.4, DateTime(2026, 9, 30, 8)),
];

Referencia referencia({int? ecc, double? objetivoKg, DateTime? data}) => Referencia(
  id: 'r1',
  petId: 'luna',
  ecc: ecc,
  objetivoKg: objetivoKg,
  origem: OrigemReferencia.veterinario,
  data: data ?? hoje,
);

void main() {
  group('R06 — pesagem suspeita', () {
    test('54 com anterior 5,4 → suspeita, "Corrigir para 5,4 kg"', () {
      final c = conferirPesagem(54, 5.4);
      expect(c.suspeita, isTrue);
      expect(c.anteriorKg, 5.4);
      expect(c.sugestaoKg, 5.4);
    });

    test('0,54 com anterior 5,4 → sugestão 5,4 (sem 5,4000000000000004)', () {
      expect(conferirPesagem(0.54, 5.4).sugestaoKg, 5.4);
    });

    test('limites ×1,5 e ×0,67 são suspeitos, sem sugestão', () {
      expect(conferirPesagem(7.5, 5.0), const ConferenciaPesagem(suspeita: true, anteriorKg: 5.0));
      expect(conferirPesagem(3.35, 5.0).suspeita, isTrue);
      expect(conferirPesagem(7.4, 5.0).suspeita, isFalse);
      expect(conferirPesagem(3.4, 5.0).suspeita, isFalse);
    });

    test('variação normal não é suspeita', () {
      expect(conferirPesagem(5.4, 5.5).suspeita, isFalse);
    });

    test('sem pesagem anterior, não há verificação', () {
      expect(conferirPesagem(54, null), ConferenciaPesagem.semVerificacao);
    });

    test('referência: a anterior mais próxima; no peso inicial, a seguinte', () {
      expect(pesagemDeReferencia(pesagensLuna, dataHora: DateTime(2026, 9, 30, 20))?.id, 'p3');
      expect(pesagemDeReferencia(pesagensLuna, dataHora: DateTime(2026, 9, 25))?.id, 'p2');
      expect(pesagemDeReferencia(pesagensLuna, dataHora: DateTime(2026, 9, 16, 8), ignorarId: 'p1')?.id, 'p2');
      expect(pesagemDeReferencia(const [], dataHora: hoje), isNull);
    });
  });

  group('M2 — peso ideal', () {
    test('tabela do ECC com P = 5,4 kg', () {
      const esperado = {1: 7.71, 3: 6.00, 4: 5.40, 5: 5.40, 6: 4.91, 7: 4.50, 9: 3.86};
      esperado.forEach((ecc, kg) {
        expect(pesoIdealPeloEcc(5.4, ecc).valorOuNulo, closeTo(kg, 0.005), reason: 'ECC $ecc');
      });
    });

    test('ECC 7 → 4,5 kg (estimado pelo ECC 7)', () {
      final ideal = pesoIdeal(referencia(ecc: 7), pesagensLuna).valorOuNulo!;
      expect(ideal.kg, closeTo(4.5, 1e-9));
      expect(ideal.rotulo, '(estimado pelo ECC 7)');
    });

    test('objetivo informado tem prioridade sobre o ECC', () {
      final ideal = pesoIdeal(referencia(ecc: 7, objetivoKg: 4.8), pesagensLuna).valorOuNulo!;
      expect(ideal.kg, 4.8);
      expect(ideal.rotulo, '(objetivo informado)');
    });

    test('usa a pesagem mais próxima da data do ECC', () {
      final ideal = pesoIdeal(referencia(ecc: 7, data: DateTime(2026, 9, 17)), pesagensLuna).valorOuNulo!;
      expect(ideal.kg, closeTo(5.6 / 1.2, 1e-9));
    });

    test('sem ECC nem objetivo → texto de M2', () {
      expect(pesoIdeal(null, pesagensLuna), const Indisponivel<PesoIdeal>('Informe o ECC ou o objetivo em Evolução.'));
      expect(pesoIdeal(referencia(), pesagensLuna).disponivel, isFalse);
    });

    test('ECC fora de 1–9 não gera estimativa', () {
      expect(pesoIdealPeloEcc(5.4, 0).disponivel, isFalse);
      expect(pesoIdealPeloEcc(5.4, 10).disponivel, isFalse);
    });
  });

  group('M3 — curva ideal', () {
    test('perda: ideal(30) 5,172 e ideal(90) 4,745; nunca abaixo de Pi', () {
      final curva = curvaIdeal(p0: 5.4, pi: 4.5).valorOuNulo!;
      expect(curva, hasLength(91));
      expect(curva[0], 5.4);
      expect(curva[30], closeTo(5.172, 0.0005));
      expect(curva[90], closeTo(4.745, 0.0005));
      expect(curva.every((v) => v >= 4.5), isTrue);
    });

    test('ganho: sobe 1% por semana até Pi', () {
      final curva = curvaIdeal(p0: 4.0, pi: 4.2).valorOuNulo!;
      expect(curva[7], closeTo(4.04, 1e-9));
      expect(curva[90], 4.2);
    });

    test('manutenção: dentro de 1% de Pi a curva é Pi', () {
      expect(curvaIdeal(p0: 4.52, pi: 4.5).valorOuNulo!.toSet(), {4.5});
    });

    test('sem Pi → indisponível', () {
      expect(curvaIdeal(p0: 5.4, pi: null).disponivel, isFalse);
    });
  });

  group('M6 — dados do gráfico', () {
    final projecao = List<double>.generate(91, (d) => 5.4 - 0.015429 * d);
    final ideal = curvaIdeal(p0: 5.4, pi: 4.5).valorOuNulo!;

    GraficoDados grafico([List<Pesagem>? pesagens]) => montarGrafico(
      pesagens: pesagens ?? pesagensLuna,
      projecao: projecao,
      curvaIdeal: ideal,
      pesoIdealKg: 4.5,
      hoje: hoje,
      nomePet: 'Luna',
    ).valorOuNulo!;

    test('eixo X começa na primeira pesagem (mais recente que hoje − 30) e vai até hoje + 90', () {
      final g = grafico();
      expect(g.inicio, DateTime(2026, 9, 16));
      expect(g.fim, DateTime(2026, 12, 29));
      expect(g.fracaoX(g.inicio), 0);
      expect(g.fracaoX(g.fim), 1);
      expect(g.diaNaFracao(1), g.fim);
    });

    test('eixo X começa em hoje − 30 quando a primeira pesagem é mais antiga', () {
      final g = grafico([pesagem('velha', 6, DateTime(2026, 7, 1)), ...pesagensLuna]);
      expect(g.inicio, DateTime(2026, 8, 31));
      expect(g.historico, hasLength(3));
    });

    test('eixo Y com margem de 10%', () {
      final g = grafico();
      final minimo = projecao[90];
      const maximo = 5.6;
      final margem = (maximo - minimo) * 0.1;
      expect(g.yMin, closeTo(minimo - margem, 1e-9));
      expect(g.yMax, closeTo(maximo + margem, 1e-9));
      expect(g.fracaoY(g.yMin), 0);
      expect(g.fracaoY(g.yMax), 1);
    });

    test('max == min → ±0,5 kg', () {
      final g = montarGrafico(
        pesagens: [pesagem('p3', 5.4, hoje)],
        projecao: null,
        curvaIdeal: null,
        pesoIdealKg: null,
        hoje: hoje,
        nomePet: 'Luna',
      ).valorOuNulo!;
      expect(g.yMin, closeTo(4.9, 1e-9));
      expect(g.yMax, closeTo(5.9, 1e-9));
      expect(g.historico, hasLength(1));
    });

    test('30 set. → 5,4 kg (pesagem)', () {
      expect(grafico().textoNoDia(DateTime(2026, 9, 30)), '30 set. • 5,4 kg (pesagem)');
    });

    test('27 set. → ≈ 5,44 kg (estimado)', () {
      expect(grafico().textoNoDia(DateTime(2026, 9, 27)), '27 set. • ≈ 5,44 kg (estimado)');
    });

    test('dia futuro → projeção e ideal com 2 casas', () {
      final d = DateTime(2026, 11, 15);
      expect(grafico().textoNoDia(d), '15 nov. • Projeção 4,69 kg • Ideal 5,05 kg');
    });

    test('fora do eixo X → sem texto', () {
      expect(grafico().textoNoDia(DateTime(2026, 9, 10)), isNull);
    });

    test('sem nenhuma pesagem → estado vazio (M10), sem desenhar zero', () {
      final r = montarGrafico(
        pesagens: const [],
        projecao: null,
        curvaIdeal: null,
        pesoIdealKg: 4.5,
        hoje: hoje,
        nomePet: 'Luna',
      );
      expect(
        r,
        const Indisponivel<GraficoDados>('Ainda não há pesagens de Luna. Registre a primeira para ver o gráfico.'),
      );
    });
  });

  group('M7 — evolução', () {
    test('5,6 → 5,4 com Pi 4,5 → 18,2% → "18% do caminho"', () {
      final e = evolucao(pInicial: 5.6, pAtual: 5.4, pi: 4.5);
      expect(e.percentual, closeTo(18.18, 0.01));
      expect(e.texto, '18% do caminho');
      expect(e.passouDoIdeal, isFalse);
    });

    test('passou do ideal → 100% e dispara a S3', () {
      final e = evolucao(pInicial: 5.6, pAtual: 4.3, pi: 4.5);
      expect(e.percentual, 100);
      expect(e.passouDoIdeal, isTrue);
    });

    test('afastou do ideal → 0%', () {
      expect(evolucao(pInicial: 5.6, pAtual: 5.8, pi: 4.5).percentual, 0);
    });

    test('sem peso ideal → texto de M5', () {
      expect(evolucao(pInicial: 5.6, pAtual: 5.4, pi: null).texto, 'Defina o ECC ou o objetivo para estimar.');
    });
  });

  group('M8 — S3 mudar objetivo', () {
    final prevista = dataPrevista(p0: 5.4, pi: 4.5, kgDia: -0.015429, hoje: hoje);
    final naoAlcancado = dataPrevista(p0: 5.4, pi: 4.5, kgDia: 0, hoje: hoje);

    Sugestao? s3({double pAtual = 5.4, DataPrevista? previsao, DateTime? primeira, bool passou = false}) =>
        sugestaoMudarObjetivo(
          nomePet: 'Luna',
          pAtual: pAtual,
          pi: 4.5,
          previsao: previsao ?? prevista,
          primeiraPesagem: primeira ?? DateTime(2026, 9, 16),
          hoje: hoje,
          passouDoIdeal: passou,
        );

    test('(a) perto do ideal (≤ 2% de Pi)', () {
      expect(
        s3(pAtual: 4.59),
        const Sugestao(
          tipo: TipoSugestao.mudarObjetivo,
          texto: 'Luna está perto do peso ideal. Converse com o veterinário sobre passar para manutenção.',
        ),
      );
    });

    test('(b) "não é alcançado" com 14 dias de dados', () {
      expect(
        s3(previsao: naoAlcancado)?.texto,
        'Com o ritmo atual, o objetivo está distante. Vale revisar o objetivo com o veterinário.',
      );
    });

    test('(b) previsão acima de 180 dias', () {
      final longe = dataPrevista(p0: 5.4, pi: 4.5, kgDia: -0.004, hoje: hoje);
      expect(longe.dias, greaterThan(180));
      expect(s3(previsao: longe)?.tipo, TipoSugestao.mudarObjetivo);
    });

    test('(b) com menos de 14 dias de dados não aparece', () {
      expect(s3(previsao: naoAlcancado, primeira: DateTime(2026, 9, 20)), isNull);
    });

    test('passou do ideal (M7 > 100%) dispara a S3', () {
      expect(s3(pAtual: 4.3, passou: true)?.tipo, TipoSugestao.mudarObjetivo);
    });

    test('caminho normal → nenhuma sugestão', () {
      expect(s3(), isNull);
    });
  });

  group('M8 — celebração', () {
    test('5,5 → 5,4 com Pi 4,5 → "Luna chegou 100 g mais perto do peso ideal!"', () {
      expect(
        celebracao(nomePet: 'Luna', anteriorKg: 5.5, novoKg: 5.4, pi: 4.5),
        'Luna chegou 100 g mais perto do peso ideal!',
      );
    });

    test('diferença arredondada a 10 g', () {
      expect(
        celebracao(nomePet: 'Luna', anteriorKg: 5.5, novoKg: 5.364, pi: 4.5),
        'Luna chegou 140 g mais perto do peso ideal!',
      );
    });

    test('menos de 100 g → nada', () {
      expect(celebracao(nomePet: 'Luna', anteriorKg: 5.5, novoKg: 5.45, pi: 4.5), isNull);
    });

    test('afastando do ideal → nada, nem mensagem de culpa', () {
      expect(celebracao(nomePet: 'Luna', anteriorKg: 5.4, novoKg: 5.6, pi: 4.5), isNull);
    });

    test('sem Pi ou sem anterior → nada', () {
      expect(celebracao(nomePet: 'Luna', anteriorKg: 5.5, novoKg: 5.4, pi: null), isNull);
      expect(celebracao(nomePet: 'Luna', anteriorKg: null, novoKg: 5.4, pi: 4.5), isNull);
    });
  });
}
