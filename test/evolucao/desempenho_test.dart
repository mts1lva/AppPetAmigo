// P4-4.3 — RNF06 (parte do host): os modelos da Evolução (M2–M7 e o M6 do
// gráfico) com 1.000 pesagens levam menos de 50 ms em pelo menos 95% de 20
// execuções. A medição no aparelho (abrir a tela em até 2 s, em `--profile`)
// está em integration_test/desempenho_evolucao_test.dart.

import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/evolucao/domain/calendario.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';
import 'package:petamigo/features/evolucao/domain/grafico_dados.dart';
import 'package:petamigo/features/evolucao/domain/modelos_do_pet.dart';

final hoje = DateTime(2026, 9, 30, 9);

/// 1.000 pesagens, uma a cada 8 horas, terminando hoje.
final mil = [
  for (var i = 0; i < 1000; i++)
    Pesagem(
      id: 'w$i',
      petId: 'p1',
      pesoKg: 6 - i * 0.0006,
      dataHora: hoje.subtract(Duration(hours: 8 * (999 - i))),
    ),
];

final ecc7 = Referencia(id: 'r1', petId: 'p1', ecc: 7, origem: OrigemReferencia.veterinario, data: DateTime(2026, 9, 30));

/// Um recálculo completo, como o `modelosProvider` + `graficoProvider` fazem
/// a cada registro novo.
void recalcular() {
  final m = calcularModelos(
    pesagens: mil,
    referencia: ecc7,
    ingestao: {for (var d = 0; d < 14; d++) DateTime(2026, 9, 30 - d): 380},
    atividadeKcalPorDia: 1.1,
    mer: 396.75,
    aderencia: null,
    hoje: hoje,
  );
  final g = montarGrafico(
    pesagens: m.pesagens,
    projecao: m.projecao.valorOuNulo?.curva,
    curvaIdeal: m.curvaIdeal.valorOuNulo,
    pesoIdealKg: m.pesoIdealKg,
    hoje: hoje,
    nomePet: 'Luna',
  ).valorOuNulo!;
  textoAlternativoGrafico(g, previsao: m.previsao.texto);
}

void main() {
  test('numeroDoDia equivale a diaDe e diasEntre ao longo de 2 anos, inclusive perto da meia-noite', () {
    final base = DateTime(2025, 1, 1);
    for (var d = 0; d < 730; d++) {
      for (final hora in [0, 1, 12, 23]) {
        final data = DateTime(2025, 1, 1 + d, hora, hora == 23 ? 59 : 0);
        expect(diaDoNumero(numeroDoDia(data)), diaDe(data), reason: '$data');
        expect(numeroDoDia(data) - numeroDoDia(base), diasEntre(base, data), reason: '$data');
      }
    }
  });

  test('M2–M7 + M6 com 1.000 pesagens: < 50 ms em 95% de 20 execuções', () {
    recalcular(); // aquecimento do JIT
    final tempos = <int>[];
    for (var i = 0; i < 20; i++) {
      final relogio = Stopwatch()..start();
      recalcular();
      tempos.add(relogio.elapsedMicroseconds);
    }
    tempos.sort();
    final p95 = tempos[(tempos.length * 0.95).ceil() - 1];
    // ignore: avoid_print
    print('RNF06 modelos (µs): mediana ${tempos[tempos.length ~/ 2]}, p95 $p95, máx ${tempos.last}');
    expect(p95, lessThan(50000));
  });
}
