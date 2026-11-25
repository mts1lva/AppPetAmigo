// T2 — Teste oficial da Unidade II (U2-17): aderência ao plano (M7) e
// sugestão de petiscos (S1 / M8). Casos de `modelos-matematicos.md`.

import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/resultado.dart';
import 'package:petamigo/core/sugestao.dart';
import 'package:petamigo/features/diario/domain/aderencia.dart';
import 'package:petamigo/features/diario/domain/casos_de_uso/avaliar_sugestao_petiscos.dart';
import 'package:petamigo/features/diario/domain/casos_de_uso/calcular_aderencia.dart';
import 'package:petamigo/features/diario/domain/entidades/resumo_dia.dart';
import 'package:petamigo/features/diario/domain/sugestao_petiscos.dart';
import 'package:petamigo/features/diario/domain/textos_diario.dart';
import 'package:petamigo/features/nutricao/domain/meta_diaria.dart';

import '../apoio/pets_falsos.dart';

final hoje = DateTime(2026, 9, 30);

ResumoDia dia(int d, double racao, double extras) => ResumoDia(
      dia: DateTime(2026, 9, d),
      racaoKcal: racao,
      extrasKcal: extras,
      registros: (racao > 0 || extras > 0) ? 1 : 0,
    );

void main() {
  final metaLuna = metaDiaria(luna(), 5.4, hoje);

  group('T2 — M7 aderência ao plano alimentar', () {
    test('totais 380, 400, 120, 228, 410, —, 390 com meta 396,75 → 4 de 6 = 67%', () {
      expect(metaLuna, isA<Disponivel<MetaDiaria>>());
      expect((metaLuna as Disponivel<MetaDiaria>).valor.mer, closeTo(396.75, 0.005));

      // Faixa 0,9×MER … 1,1×MER = 357,1 … 436,4.
      final dias = [
        dia(24, 380, 0),
        dia(25, 400, 0),
        dia(26, 120, 0),
        dia(27, 228, 0),
        dia(28, 410, 0),
        // 29: sem registro (não conta)
        dia(30, 390, 0),
      ];
      final r = aderencia(dias: dias, meta: metaLuna, hoje: hoje);
      expect(r, isA<Disponivel<Aderencia>>());
      final a = (r as Disponivel<Aderencia>).valor;
      expect(a.aderentes, 4);
      expect(a.diasComRegistro, 6);
      expect(a.percentual, closeTo(4 / 6 * 100, 0.0001));
      expect(textoAderencia(a), '67% (4 de 6 dias com registro)');
    });

    test('sem nenhum dia com registro → indisponível, sem divisão por zero', () {
      expect(
        aderencia(dias: const [], meta: metaLuna, hoje: hoje),
        const Indisponivel<Aderencia>(motivoAderenciaSemRegistros),
      );
      expect(
        aderencia(dias: [ResumoDia.vazio(hoje)], meta: metaLuna, hoje: hoje),
        const Indisponivel<Aderencia>(motivoAderenciaSemRegistros),
      );
    });

    test('meta indisponível → indisponível', () {
      expect(
        aderencia(dias: [dia(30, 380, 0)], meta: metaDiaria(luna(), null, hoje), hoje: hoje),
        const Indisponivel<Aderencia>(motivoAderenciaSemMeta),
      );
    });

    test('dia fora da janela de 14 dias não entra', () {
      final r = aderencia(
        dias: [dia(16, 380, 0), dia(17, 380, 0), dia(30, 380, 0)],
        meta: metaLuna,
        hoje: hoje,
      );
      final a = (r as Disponivel<Aderencia>).valor;
      expect(a.diasComRegistro, 2, reason: '16/09 está há 14 dias (fora); 17 (hoje−13) e 30 entram');
      expect(a.aderentes, 2);
    });

    test('caso de uso CalcularAderencia devolve o mesmo resultado de M7', () {
      final dias = [dia(30, 380, 0)];
      expect(
        const CalcularAderencia()(dias: dias, meta: metaLuna, hoje: hoje),
        aderencia(dias: dias, meta: metaLuna, hoje: hoje),
      );
    });
  });

  group('T2 — S1 sugestão de reduzir petiscos', () {
    test('3 dias com extras acima de 10% → sugere', () {
      final dias = [
        dia(28, 80, 20), // 20%
        dia(29, 80, 20),
        dia(30, 80, 20),
      ];
      final s = sugestaoPetiscos(dias: dias, hoje: hoje);
      expect(s, isNotNull);
      expect(s!.tipo, TipoSugestao.reduzirPetiscos);
      expect(s.texto, textoSugestaoPetiscos(3));
    });

    test('2 dias → não sugere', () {
      final dias = [
        dia(29, 80, 20),
        dia(30, 80, 20),
      ];
      expect(sugestaoPetiscos(dias: dias, hoje: hoje), isNull);
    });

    test('dias sem registro não contam', () {
      final dias = [
        dia(26, 80, 20),
        ResumoDia.vazio(DateTime(2026, 9, 27)),
        ResumoDia.vazio(DateTime(2026, 9, 28)),
        dia(29, 80, 20),
        dia(30, 108, 12), // 10% exato: não é acima de 10%
      ];
      expect(sugestaoPetiscos(dias: dias, hoje: hoje), isNull);
    });

    test('dia fora da janela de 7 dias não entra', () {
      final dias = [
        dia(23, 80, 20), // 7 dias atrás: 23 a 30 = 8 dias de distância, fora
        dia(24, 80, 20),
        dia(29, 80, 20),
        dia(30, 80, 20),
      ];
      // 24, 29 e 30 estão na janela (hoje−6 … hoje). 23 está há 7 dias
      // (hoje−7), fora de 7 dias inclusivos (hoje−6).
      expect(sugestaoPetiscos(dias: dias, hoje: hoje), isNotNull);
      expect(sugestaoPetiscos(dias: [dia(23, 80, 20), dia(29, 80, 20), dia(30, 80, 20)], hoje: hoje), isNull);
    });

    test('caso de uso AvaliarSugestaoPetiscos devolve o mesmo resultado de S1', () {
      final dias = [dia(28, 80, 20), dia(29, 80, 20), dia(30, 80, 20)];
      expect(
        const AvaliarSugestaoPetiscos()(dias: dias, hoje: hoje),
        sugestaoPetiscos(dias: dias, hoje: hoje),
      );
    });
  });
}
