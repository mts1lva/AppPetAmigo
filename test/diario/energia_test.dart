// R01 — energia da refeição (`comum/regras.md`).

import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/features/diario/domain/casos_de_uso/calcular_energia.dart';
import 'package:petamigo/features/diario/domain/energia.dart';

void main() {
  group('R01 — energia da refeição', () {
    test('30 g × 360 kcal/100 g = 108 kcal (protótipo)', () {
      expect(energiaRefeicao(30, 360), const Disponivel(108.0));
    });

    test('metade e uma e meia da porção habitual de 30 g', () {
      expect(energiaRefeicao(15, 360), const Disponivel(54.0));
      expect(energiaRefeicao(45, 360), const Disponivel(162.0));
    });

    test('editar a quantidade usa a densidade da refeição, não a do alimento', () {
      const densidadeAntiga = 360.0;
      const densidadeNovaDoAlimento = 400.0;
      final nova = energiaRefeicao(40, densidadeAntiga);
      expect(nova, const Disponivel(144.0));
      expect(energiaRefeicao(40, densidadeNovaDoAlimento), isNot(nova));
    });

    test('quantidade ≤ 0, NaN ou infinito → Indisponivel', () {
      for (final q in [0.0, -1.0, double.nan, double.infinity]) {
        expect(energiaRefeicao(q, 360), isA<Indisponivel<double>>(), reason: 'quantidade $q');
      }
    });

    test('densidade ≤ 0, NaN ou infinito → Indisponivel', () {
      for (final d in [0.0, -10.0, double.nan, double.infinity]) {
        expect(energiaRefeicao(30, d), isA<Indisponivel<double>>(), reason: 'densidade $d');
      }
    });

    test('caso de uso CalcularEnergia devolve o mesmo resultado de R01', () {
      const caso = CalcularEnergia();
      expect(caso(quantidadeG: 30, densidadeKcalPor100g: 360), energiaRefeicao(30, 360));
    });
  });

  group('R01 — petisco cadastrado (P-32)', () {
    test('2 unidades × 3 kcal = 6 kcal', () {
      expect(energiaPetisco(2, 3), const Disponivel(6.0));
    });

    test('unidades ou energia por unidade inválidas → indisponível com o texto de R05', () {
      expect(energiaPetisco(0, 3), const Indisponivel(motivoUnidadesInvalidas));
      expect(energiaPetisco(-1, 3), const Indisponivel(motivoUnidadesInvalidas));
      expect(energiaPetisco(2, 0), const Indisponivel(motivoEnergiaPorUnidadeInvalida));
      expect(energiaPetisco(2, double.nan), const Indisponivel(motivoEnergiaPorUnidadeInvalida));
    });

    test('textos de R05 da P-32', () {
      expect(motivoEnergiaPorUnidadeInvalida, 'Informe a energia por unidade.');
      expect(motivoUnidadesInvalidas, 'Informe um número inteiro de unidades.');
    });
  });
}
