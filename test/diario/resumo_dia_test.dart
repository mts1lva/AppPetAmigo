// R02, R04, R08 e R09 — resumo do dia, gramas da meta e textos do Diário.

import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/features/diario/domain/casos_de_uso/calcular_resumo_dia.dart';
import 'package:petamigo/features/diario/domain/entidades/extra.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';
import 'package:petamigo/features/diario/domain/entidades/resumo_dia.dart';
import 'package:petamigo/features/diario/domain/resumo_do_dia.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';
import 'package:petamigo/features/nutricao/domain/casos_de_uso/calcular_meta_diaria.dart';
import 'package:petamigo/features/nutricao/domain/meta_diaria.dart';

import '../apoio/pets_falsos.dart';

final hoje = DateTime(2026, 9, 30);

Refeicao refeicao({double kcal = 108, DateTime? quando, String id = 'r1'}) => Refeicao(
      id: id,
      petId: 'p1',
      alimentoId: 'a1',
      alimentoNome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      quantidadeG: 30,
      energiaKcal: kcal,
      dataHora: quando ?? DateTime(2026, 9, 30, 8),
    );

Extra extra({double kcal = 12, DateTime? quando, String id = 'e1'}) => Extra(
      id: id,
      petId: 'p1',
      descricao: 'Petisco',
      quantidadeG: 3,
      energiaKcal: kcal,
      dataHora: quando ?? DateTime(2026, 9, 30, 12),
    );

void main() {
  final metaLuna = metaDiaria(luna(), 5.4, hoje);

  group('R02 — resumo do dia', () {
    test('30 g a 360 kcal/100 g + petisco de 12 kcal → 120 kcal e 10%', () {
      final resumo = resumoDoDia(dia: hoje, refeicoes: [refeicao()], extras: [extra()]);
      expect(resumo.racaoKcal, 108);
      expect(resumo.extrasKcal, 12);
      expect(resumo.totalKcal, 120);
      expect(resumo.parcelaExtras, 10);
      expect(resumo.registros, 2);
    });

    test('ignora registros de outro dia e outro horário no mesmo dia entra', () {
      final resumo = resumoDoDia(
        dia: hoje,
        refeicoes: [
          refeicao(quando: DateTime(2026, 9, 29, 8)),
          refeicao(id: 'r2', quando: DateTime(2026, 9, 30, 20)),
        ],
        extras: const [],
      );
      expect(resumo.racaoKcal, 108);
      expect(resumo.registros, 1);
    });

    test('sem registros: vazio, sem tratar ausência como zero na UI (R09)', () {
      final resumo = resumoDoDia(dia: hoje, refeicoes: const [], extras: const []);
      expect(resumo, ResumoDia.vazio(hoje));
      expect(resumo.temRegistros, isFalse);
      expect(textoResumoDia(resumo, metaLuna), textoSemRegistros);
      expect(textoResumoDia(resumo, metaLuna), isNot(contains('0 kcal')));
    });

    test('com meta: 120 de 397 kcal e faltam 277', () {
      final resumo = ResumoDia(dia: hoje, racaoKcal: 108, extrasKcal: 12, registros: 2);
      expect(
        textoResumoDia(resumo, metaLuna),
        '120 de 397 kcal • Petiscos 10% dos registros\n'
        'Faltam 277 kcal para a meta de hoje.',
      );
    });

    test('total igual à meta: sem "Faltam 0 kcal"', () {
      final resumo = ResumoDia(dia: hoje, racaoKcal: 397, extrasKcal: 0, registros: 1);
      expect(
        textoResumoDia(resumo, metaLuna),
        '397 de 397 kcal • Petiscos 0% dos registros',
      );
      expect(textoResumoDia(resumo, metaLuna), isNot(contains('Faltam 0')));
    });

    test('acima da meta: N kcal acima da meta de hoje', () {
      final resumo = ResumoDia(dia: hoje, racaoKcal: 420, extrasKcal: 0, registros: 1);
      expect(
        textoResumoDia(resumo, metaLuna),
        '420 de 397 kcal • Petiscos 0% dos registros\n'
        '23 kcal acima da meta de hoje.',
      );
    });

    test('sem meta: 120 kcal e peça a pesagem', () {
      final resumo = ResumoDia(dia: hoje, racaoKcal: 108, extrasKcal: 12, registros: 2);
      expect(
        textoResumoDia(resumo, metaDiaria(luna(), null, hoje)),
        '120 kcal • Petiscos 10% dos registros\n$textoSemMeta',
      );
    });

    test('caso de uso CalcularResumoDia devolve o mesmo resultado de R02', () {
      const caso = CalcularResumoDia();
      final refeicoes = [refeicao()];
      final extras = [extra()];
      expect(
        caso(dia: hoje, refeicoes: refeicoes, extras: extras),
        resumoDoDia(dia: hoje, refeicoes: refeicoes, extras: extras),
      );
    });
  });

  group('R04 — gramas da meta', () {
    test('MER 396,75 com 360 kcal/100 g → ≈ 110 g', () {
      final g = gramas(396.75, 360);
      expect(g, isA<Disponivel<double>>());
      expect(g.valorOuNulo, closeTo(110.2, 0.01));
      expect(textoGramasAproximadas(g), '≈ 110 g');
    });

    test('atalho com meta e alimento: Meta de hoje: 397 kcal (≈ 110 g)', () {
      final m = const CalcularMetaDiaria()(pet: luna(), ultimaPesagemKg: 5.4, hoje: hoje);
      expect(m, isA<Disponivel<MetaDiaria>>());
      final mer = (m as Disponivel<MetaDiaria>).valor.mer;
      expect(
        textoMetaNoAtalho(m, gramas(mer, 360)),
        'Meta de hoje: 397 kcal (≈ 110 g)',
      );
    });

    test('densidade 0 → gramas indisponíveis; atalho mostra só as kcal', () {
      expect(textoGramasAproximadas(gramas(396.75, 0)), isNull);
      expect(textoMetaNoAtalho(metaLuna, gramas(396.75, 0)), 'Meta de hoje: 397 kcal');
    });
  });

  test('linhas do histórico: refeição e extra com e sem quantidade', () {
    expect(linhaRefeicao(refeicao()), '08:00 • Ração habitual • 30 g • 108 kcal');
    expect(linhaExtra(extra()), '12:00 • Petisco • 3 g • 12 kcal');
    expect(
      linhaExtra(Extra(
        id: 'e2',
        petId: 'p1',
        descricao: 'Petisco',
        energiaKcal: 12,
        dataHora: DateTime(2026, 9, 30, 12),
      )),
      '12:00 • Petisco • 12 kcal',
    );
  });

  test('R08 — refeição salva: de 0 para 108 kcal', () {
    final depois = ResumoDia(dia: hoje, racaoKcal: 108, extrasKcal: 0, registros: 1);
    expect(
      textoRefeicaoSalva(antesKcal: 0, depois: depois),
      'O diário passa de 0 para 108 kcal. Ração 108 kcal • Petiscos 0 kcal. Continue no seu ritmo.',
    );
  });
}
