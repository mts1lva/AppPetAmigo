// T1 — Teste oficial da Unidade II (U2-17): meta diária (RER × fator), M1.
// Casos de `docs/specs/comum/modelos-matematicos.md` → M1.

import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/features/nutricao/domain/casos_de_uso/calcular_meta_diaria.dart';
import 'package:petamigo/features/nutricao/domain/meta_diaria.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

final hoje = DateTime(2026, 9, 30);

Pet petDeTeste({
  int idadeMeses = 72,
  bool castrado = true,
  NivelAtividade atividade = NivelAtividade.moderada,
  Sexo sexo = Sexo.femea,
}) =>
    Pet(
      id: 'pet-teste',
      nome: 'Luna',
      especie: Especie.gato,
      sexo: sexo,
      idadeMeses: idadeMeses,
      idadeInformadaEm: hoje,
      castrado: castrado,
      nivelAtividade: atividade,
    );

MetaDiaria metaDisponivel(Resultado<MetaDiaria> r) => switch (r) {
      Disponivel(:final valor) => valor,
      Indisponivel(:final motivo) => fail('Meta indisponível: $motivo'),
    };

void main() {
  group('T1 — M1 meta diária (RER × fator)', () {
    test('Luna: 5,4 kg, gata adulta castrada, atividade moderada → RER 247,97; fator 1,6; MER 396,75', () {
      final meta = metaDisponivel(metaDiaria(petDeTeste(), 5.4, hoje));

      expect(meta.rer, closeTo(247.97, 0.005));
      expect(meta.fator, const FatorAtividade(1.6, OrigemFator.castrado));
      expect(meta.mer, closeTo(396.75, 0.005));
      expect(meta.mer.round(), 397, reason: 'exibe 397 kcal/dia');
    });

    test('conversão: MER 396,75 com 360 kcal/100 g → 110,2 g (exibe 110 g)', () {
      final g = gramas(396.75, 360);

      expect(g, isA<Disponivel<double>>());
      expect(g.valorOuNulo, closeTo(110.2, 0.01));
      expect(g.valorOuNulo!.round(), 110);
    });

    test('filhote: 5,4 kg, 6 meses → fator 3,0; MER 743,9', () {
      final meta = metaDisponivel(metaDiaria(petDeTeste(idadeMeses: 6), 5.4, hoje));

      expect(meta.fator, const FatorAtividade(3.0, OrigemFator.filhote));
      expect(meta.mer, closeTo(743.9, 0.01));
    });

    test('sem pesagem → Indisponivel com o texto do Início', () {
      expect(
        metaDiaria(petDeTeste(), null, hoje),
        const Indisponivel<MetaDiaria>('Registre uma pesagem para calcular a meta.'),
      );
    });

    test('densidade 0 → MER disponível, gramas indisponíveis', () {
      final meta = metaDisponivel(metaDiaria(petDeTeste(), 5.4, hoje));

      expect(gramas(meta.mer, 0), isA<Indisponivel<double>>());
      expect(gramas(meta.mer, -10), isA<Indisponivel<double>>());
    });

    group('ordem dos fatores (o primeiro que se aplica vale)', () {
      test('filhote castrado → 3,0', () {
        expect(fatorAtividade(petDeTeste(idadeMeses: 6, castrado: true), hoje).valor, 3.0);
      });

      test('castrado com atividade alta → 2,0', () {
        expect(
          fatorAtividade(petDeTeste(castrado: true, atividade: NivelAtividade.alta), hoje),
          const FatorAtividade(2.0, OrigemFator.atividadeAlta),
        );
      });

      test('filhote com atividade alta → 3,0', () {
        expect(fatorAtividade(petDeTeste(idadeMeses: 11, atividade: NivelAtividade.alta), hoje).valor, 3.0);
      });

      test('adulto não castrado, atividade baixa ou moderada → 1,8 (P-17)', () {
        for (final atividade in [NivelAtividade.baixa, NivelAtividade.moderada]) {
          expect(
            fatorAtividade(petDeTeste(castrado: false, atividade: atividade), hoje),
            const FatorAtividade(1.8, OrigemFator.adultoNaoCastrado),
          );
        }
      });

      test('12 meses já é adulto', () {
        expect(fatorAtividade(petDeTeste(idadeMeses: 12), hoje).origem, OrigemFator.castrado);
      });

      test('a idade avança desde a data informada: 11 meses informados há 1 mês → adulto', () {
        final pet = Pet(
          id: 'p',
          nome: 'Tom',
          especie: Especie.cao,
          sexo: Sexo.macho,
          idadeMeses: 11,
          idadeInformadaEm: DateTime(2026, 8, 30),
          castrado: true,
          nivelAtividade: NivelAtividade.moderada,
        );
        expect(fatorAtividade(pet, hoje).origem, OrigemFator.castrado);
        expect(fatorAtividade(pet, DateTime(2026, 9, 29)).origem, OrigemFator.filhote);
      });
    });

    test('peso inválido (≤ 0, NaN, infinito) → Indisponivel, sem exceção', () {
      for (final peso in [0.0, -1.0, double.nan, double.infinity]) {
        expect(rer(peso), isA<Indisponivel<double>>(), reason: 'peso $peso');
        expect(metaDiaria(petDeTeste(), peso, hoje), isA<Indisponivel<MetaDiaria>>());
      }
    });

    test('caso de uso CalcularMetaDiaria devolve o mesmo resultado do M1', () {
      const caso = CalcularMetaDiaria();
      expect(
        caso(pet: petDeTeste(), ultimaPesagemKg: 5.4, hoje: hoje),
        metaDiaria(petDeTeste(), 5.4, hoje),
      );
    });
  });
}
