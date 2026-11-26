// T4 — Teste oficial da Unidade II (U2-17): projeção adaptativa (M4) e data
// prevista (M5). Casos de `docs/specs/comum/modelos-matematicos.md` → M4/M5,
// com hoje = 30/09/2026.

import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/features/evolucao/domain/curva_ideal.dart';
import 'package:petamigo/features/evolucao/domain/data_prevista.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/indicadores.dart';
import 'package:petamigo/features/evolucao/domain/projecao.dart';
import 'package:petamigo/features/nutricao/domain/meta_diaria.dart' as m1;

final hoje = DateTime(2026, 9, 30);

/// Pi da Luna: ECC 7 com P = 5,4 kg → 5,4 ÷ 1,2.
const pi = 4.5;

/// MER da Luna (M1): 70 × 5,4^0,75 × 1,6.
final rerLuna = m1.rer(5.4).valorOuNulo!;
final merLuna = rerLuna * 1.6;

Pesagem pesagem(String id, double kg, DateTime data, {bool conferida = false}) =>
    Pesagem(id: id, petId: 'luna', pesoKg: kg, dataHora: data, conferida: conferida);

/// 5,6 (16/09), 5,5 (23/09), 5,4 (30/09).
final pesagensLuna = [
  pesagem('p1', 5.6, DateTime(2026, 9, 16, 8)),
  pesagem('p2', 5.5, DateTime(2026, 9, 23, 8)),
  pesagem('p3', 5.4, DateTime(2026, 9, 30, 8)),
];

/// 120 kcal/dia em 28, 29 e 30/09.
final refeicoesLuna = {DateTime(2026, 9, 28): 120.0, DateTime(2026, 9, 29): 120.0, DateTime(2026, 9, 30): 120.0};

/// kcal de uma atividade = (RER ÷ 24) × (MET − 1) × horas; brincadeira MET 4.
double kcalBrincadeira(int minutos) => rerLuna / 24 * (4 - 1) * (minutos / 60);

/// Brincadeira de 10 min em 28, 29 e 30/09, em média nos 14 dias.
final atividadeLuna = 3 * kcalBrincadeira(10) / 14;

Projecao projecaoDisponivel(Resultado<Projecao> r) => switch (r) {
  Disponivel(:final valor) => valor,
  Indisponivel(:final motivo) => fail('Projeção indisponível: $motivo'),
};

void main() {
  group('T4 — caso completo (pesagens, refeições e atividade)', () {
    late Projecao p;

    setUp(() {
      p = projecaoDisponivel(
        projecao(
          pesagens: pesagensLuna,
          ingestaoPorDia: refeicoesLuna,
          atividadeKcalPorDia: atividadeLuna,
          mer: merLuna,
          hoje: hoje,
        ),
      );
    });

    test('kcal de cada brincadeira 5,166 e atividade média 1,107 kcal/dia', () {
      expect(kcalBrincadeira(10), closeTo(5.166, 0.0005));
      expect(atividadeLuna, closeTo(1.107, 0.0005));
    });

    test('obs −0,014286; en −0,036085; w 0,75', () {
      expect(p.observada, closeTo(-0.014286, 0.0000005));
      expect(p.energetica, closeTo(-0.036085, 0.0000005));
      expect(p.pesoObservada, 0.75);
      expect(p.nPesagens, 3);
    });

    test('combinação −0,019736 é limitada a −0,015429', () {
      expect(p.kgDiaSemLimite, closeTo(-0.019736, 0.0000005));
      expect(p.kgDia, closeTo(-0.015429, 0.0000005));
      expect(p.limitada, isTrue);
    });

    test('proj(30) 4,937 e proj(90) 4,011', () {
      expect(p.curva, hasLength(91));
      expect(p.curva[0], 5.4);
      expect(p.curva[30], closeTo(4.937, 0.0005));
      expect(p.curva[90], closeTo(4.011, 0.0005));
    });

    test('data prevista: 59 dias → 28 nov. 2026', () {
      final previsao = dataPrevista(p0: p.p0, pi: pi, kgDia: p.kgDia, hoje: hoje);
      expect(previsao.situacao, SituacaoPrevisao.prevista);
      expect(previsao.dias, 59);
      expect(previsao.data, DateTime(2026, 11, 28));
      expect(previsao.texto, '28 nov. 2026');
    });
  });

  group('T4 — só pesagens (teste do arredondamento)', () {
    test('kgDia −0,014286 → 63 dias → 02 dez. 2026 (64 sem o round(…, 6))', () {
      final p = projecaoDisponivel(
        projecao(pesagens: pesagensLuna, ingestaoPorDia: const {}, atividadeKcalPorDia: 0, mer: merLuna, hoje: hoje),
      );
      expect(p.energetica, isNull);
      expect(p.kgDia, closeTo(-0.014286, 0.0000005));
      expect(p.limitada, isFalse);

      // Sem o arredondamento, o ceil daria 64.
      expect(((pi - p.p0) / p.kgDia).ceil(), 64);

      final previsao = dataPrevista(p0: p.p0, pi: pi, kgDia: p.kgDia, hoje: hoje);
      expect(previsao.dias, 63);
      expect(previsao.texto, '02 dez. 2026');
    });
  });

  group('T4 — divisão por zero', () {
    test('uma pesagem só (Sxx = 0): obs indisponível, sem exceção', () {
      final r = projecao(
        pesagens: [pesagem('p3', 5.4, DateTime(2026, 9, 30))],
        ingestaoPorDia: const {},
        atividadeKcalPorDia: 0,
        mer: merLuna,
        hoje: hoje,
      );
      expect(tendenciaObservada(pontosDaRegressao([pesagem('p3', 5.4, hoje)], hoje)), isNull);
      expect(r, const Indisponivel<Projecao>(motivoSemProjecao));
    });

    test('uma pesagem só com refeições: projeção só pela parte energética', () {
      final p = projecaoDisponivel(
        projecao(
          pesagens: [pesagem('p3', 5.4, DateTime(2026, 9, 30))],
          ingestaoPorDia: refeicoesLuna,
          atividadeKcalPorDia: atividadeLuna,
          mer: merLuna,
          hoje: hoje,
        ),
      );
      expect(p.observada, isNull);
      expect(p.kgDiaSemLimite, closeTo(-0.036085, 0.0000005));
    });

    test('pesagens no mesmo dia (Sxx = 0): vale a última, obs indisponível', () {
      final pontos = pontosDaRegressao([
        pesagem('a', 5.6, DateTime(2026, 9, 30, 8)),
        pesagem('b', 5.4, DateTime(2026, 9, 30, 20)),
      ], hoje);
      expect(pontos, hasLength(1));
      expect(pontos.single.kg, 5.4);
      expect(tendenciaObservada(pontos), isNull);
    });

    test('peso estável (kgDia = 0) → "não é alcançado"', () {
      final previsao = dataPrevista(p0: 5.4, pi: pi, kgDia: 0, hoje: hoje);
      expect(previsao.situacao, SituacaoPrevisao.naoAlcancado);
      expect(previsao.texto, 'Com o ritmo atual, o peso ideal não é alcançado.');
    });

    test('ganhando peso com objetivo de perda (+0,01) → "não é alcançado"', () {
      expect(dataPrevista(p0: 5.4, pi: pi, kgDia: 0.01, hoje: hoje).situacao, SituacaoPrevisao.naoAlcancado);
    });

    test('Pinicial == Pi → evolução "—"', () {
      final e = evolucao(pInicial: 4.5, pAtual: 4.4, pi: 4.5);
      expect(e.situacao, SituacaoEvolucao.inicialJaIdeal);
      expect(e.texto, '—');
    });
  });

  group('T4 — sem dados', () {
    test('nenhuma pesagem e nenhuma refeição → texto de M4', () {
      final r = projecao(pesagens: const [], ingestaoPorDia: const {}, atividadeKcalPorDia: 0, mer: null, hoje: hoje);
      expect(r, const Indisponivel<Projecao>('Registre pesagens ou refeições para ver a projeção.'));
    });
  });

  group('T4 — curva ideal', () {
    test('ideal(90) = 4,745 para P0 5,4 e Pi 4,5', () {
      final curva = curvaIdeal(p0: 5.4, pi: pi).valorOuNulo!;
      expect(curva[90], closeTo(4.745, 0.0005));
    });
  });

  group('M4 — limite e pesagem conferida', () {
    test('54 kg mantido (conferida) fica fora da regressão e a projeção não despenca', () {
      final pontos = pontosDaRegressao([
        ...pesagensLuna.take(2),
        pesagem('erro', 54, DateTime(2026, 9, 30, 8), conferida: true),
      ], hoje);
      expect(pontos.map((p) => p.kg), [5.6, 5.5]);
      expect(tendenciaObservada(pontos), closeTo(-0.014286, 0.0000005));
    });

    test('pesagem conferida dentro do limite continua na regressão', () {
      final pontos = pontosDaRegressao([
        ...pesagensLuna.take(2),
        pesagem('ok', 5.4, DateTime(2026, 9, 30, 8), conferida: true),
      ], hoje);
      expect(pontos, hasLength(3));
    });

    test('pesagens com mais de 30 dias ficam fora da janela', () {
      final pontos = pontosDaRegressao([pesagem('velha', 6.0, DateTime(2026, 8, 31)), ...pesagensLuna], hoje);
      expect(pontos, hasLength(3));
    });

    test('menos de 3 dias com refeição → parte energética indisponível', () {
      expect(
        tendenciaEnergetica(
          ingestaoPorDia: {DateTime(2026, 9, 29): 120, DateTime(2026, 9, 30): 120},
          atividadeKcalPorDia: 0,
          mer: merLuna,
          hoje: hoje,
        ),
        isNull,
      );
    });

    test('ganho acima do limite também é cortado, com o sinal mantido', () {
      final p = projecaoDisponivel(
        projecao(
          pesagens: [pesagem('a', 5.0, DateTime(2026, 9, 23)), pesagem('b', 5.4, DateTime(2026, 9, 30))],
          ingestaoPorDia: const {},
          atividadeKcalPorDia: 0,
          mer: null,
          hoje: hoje,
        ),
      );
      expect(p.limitada, isTrue);
      expect(p.kgDia, closeTo(0.02 * 5.4 / 7, 1e-12));
    });
  });

  group('M5 — demais situações', () {
    test('sem peso ideal', () {
      expect(
        dataPrevista(p0: 5.4, pi: null, kgDia: -0.01, hoje: hoje).texto,
        'Defina o ECC ou o objetivo para estimar.',
      );
    });

    test('dentro de 1% do ideal', () {
      expect(dataPrevista(p0: 4.52, pi: pi, kgDia: -0.01, hoje: hoje).texto, 'Peso ideal alcançado.');
    });

    test('peso já no objetivo e sem ritmo (sem refeições) → "Peso ideal alcançado." (ordem do M5)', () {
      expect(dataPrevista(p0: 4.5, pi: 4.5, kgDia: null, hoje: hoje).texto, 'Peso ideal alcançado.');
      expect(
        dataPrevista(p0: 5.4, pi: 4.5, kgDia: null, hoje: hoje).texto,
        'Registre pesagens ou refeições para estimar.',
      );
    });

    test('sem ritmo', () {
      expect(
        dataPrevista(p0: 5.4, pi: pi, kgDia: null, hoje: hoje).texto,
        'Registre pesagens ou refeições para estimar.',
      );
    });

    test('mais de 365 dias', () {
      final previsao = dataPrevista(p0: 5.4, pi: pi, kgDia: -0.001, hoje: hoje);
      expect(previsao.situacao, SituacaoPrevisao.maisDeUmAno);
      expect(previsao.texto, 'Mais de 1 ano com o ritmo atual.');
    });
  });
}
