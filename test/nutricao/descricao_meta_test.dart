import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/nutricao/domain/descricao_meta.dart';
import 'package:petamigo/features/nutricao/domain/meta_diaria.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

import '../apoio/pets_falsos.dart';

void main() {
  final hoje = DateTime(2026, 9, 30);
  final lunaPet = luna();

  group('R03 — card "Referência alimentar"', () {
    test('Luna sem alimento: só as kcal (P-24)', () {
      expect(
        textoReferenciaAlimentar(metaDiaria(lunaPet, 5.4, hoje), lunaPet),
        'Meta de hoje: 397 kcal\nRER × 1,6 (castrada). Estimativa educativa.',
      );
    });

    test('Luna com Ração habitual (360 kcal/100 g): ≈ 110 g (R04)', () {
      expect(
        textoReferenciaAlimentar(
          metaDiaria(lunaPet, 5.4, hoje),
          lunaPet,
          alimentoNome: 'Ração habitual',
          densidadeKcalPor100g: 360,
        ),
        'Meta de hoje: 397 kcal (≈ 110 g de Ração habitual)\nRER × 1,6 (castrada). Estimativa educativa.',
      );
    });

    test('densidade inválida: só as kcal', () {
      expect(
        textoReferenciaAlimentar(metaDiaria(lunaPet, 5.4, hoje), lunaPet, alimentoNome: 'X', densidadeKcalPor100g: 0),
        startsWith('Meta de hoje: 397 kcal\n'),
      );
    });

    test('sem pesagem: o motivo de M1', () {
      expect(
        textoReferenciaAlimentar(metaDiaria(lunaPet, null, hoje), lunaPet),
        'Registre uma pesagem para calcular a meta.',
      );
    });
  });

  group('rótulo do fator', () {
    String rotulo(Pet p) => rotuloFator(p, fatorAtividade(p, hoje));

    test('castrada, não castrado, filhote e atividade alta', () {
      expect(rotulo(lunaPet), 'castrada');
      expect(rotulo(lunaPet.copyWith(sexo: Sexo.macho, castrado: false)), 'não castrado');
      expect(rotulo(lunaPet.copyWith(idadeMeses: 6)), 'filhote');
      expect(rotulo(lunaPet.copyWith(nivelAtividade: NivelAtividade.alta)), 'atividade alta');
    });

    test('o fator aparece com uma casa: 3,0 no filhote', () {
      final filhote = lunaPet.copyWith(idadeMeses: 6);
      expect(textoReferenciaAlimentar(metaDiaria(filhote, 5.4, hoje), filhote), contains('RER × 3,0 (filhote).'));
    });
  });
}
