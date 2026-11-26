/// M9 — A cadeia de modelos de um pet a partir dos registros (U2-05). Dart
/// puro: os providers só juntam os streams e chamam estas funções, então
/// toda a conta é testável sem Flutter.
library;

import '../../../core/resultado.dart';
import '../../diario/domain/aderencia.dart';
import '../../diario/domain/entidades/resumo_dia.dart';
import 'curva_ideal.dart';
import 'data_prevista.dart';
import 'entidades/pesagem.dart';
import 'entidades/referencia.dart';
import 'indicadores.dart';
import 'peso_ideal.dart';
import 'projecao.dart';

/// Ingestão de M4 a partir dos resumos do diário: kcal de cada dia **com
/// registro** (dia vazio não entra, R09).
Map<DateTime, double> ingestaoPorDia(Iterable<ResumoDia> dias) => {
      for (final d in dias)
        if (d.temRegistros) d.dia: d.totalKcal,
    };

/// Tudo o que a Evolução mostra sobre um pet, calculado de uma vez.
final class ModelosDoPet {
  const ModelosDoPet({
    required this.pesagens,
    required this.pesoIdeal,
    required this.curvaIdeal,
    required this.projecao,
    required this.previsao,
    required this.evolucao,
    required this.aderencia,
  });

  /// Da mais antiga (peso inicial) para a mais recente (peso atual).
  final List<Pesagem> pesagens;

  /// M2.
  final Resultado<PesoIdeal> pesoIdeal;

  /// M3; indisponível sem pesagem ou sem peso ideal.
  final Resultado<List<double>> curvaIdeal;

  /// M4.
  final Resultado<Projecao> projecao;

  /// M5.
  final DataPrevista previsao;

  /// M7 (evolução).
  final Evolucao evolucao;

  /// M7 (aderência, do P2); `null` enquanto o diário carrega.
  final Resultado<Aderencia>? aderencia;

  Pesagem? get pesoInicial => pesagens.firstOrNull;
  Pesagem? get pesoAtual => pesagens.lastOrNull;
  double? get pesoIdealKg => pesoIdeal.valorOuNulo?.kg;
}

/// Calcula M2 a M7 para um pet.
///
/// - [ingestao]: kcal por dia com registro (ver [ingestaoPorDia]).
/// - [atividadeKcalPorDia]: média de 14 dias do P3 (`gastoAtividadeProvider`);
///   0 sem atividade.
/// - [mer]: M1, `null` sem pesagem.
ModelosDoPet calcularModelos({
  required List<Pesagem> pesagens,
  required Referencia? referencia,
  required Map<DateTime, double> ingestao,
  required double atividadeKcalPorDia,
  required double? mer,
  required Resultado<Aderencia>? aderencia,
  required DateTime hoje,
}) {
  final ordenadas = [...pesagens]..sort((a, b) => a.dataHora.compareTo(b.dataHora));
  final ideal = pesoIdeal(referencia, ordenadas);
  final pi = ideal.valorOuNulo?.kg;
  final atual = ordenadas.lastOrNull?.pesoKg;

  final proj = projecao(
    pesagens: ordenadas,
    ingestaoPorDia: ingestao,
    atividadeKcalPorDia: atividadeKcalPorDia,
    mer: mer,
    hoje: hoje,
  );
  final p = proj.valorOuNulo;

  return ModelosDoPet(
    pesagens: ordenadas,
    pesoIdeal: ideal,
    curvaIdeal: atual == null || pi == null ? const Indisponivel(motivoCurvaIndisponivel) : curvaIdeal(p0: atual, pi: pi),
    projecao: proj,
    previsao: dataPrevista(p0: p?.p0 ?? atual, pi: pi, kgDia: p?.kgDia, hoje: hoje),
    evolucao: evolucao(pInicial: ordenadas.firstOrNull?.pesoKg, pAtual: atual, pi: pi),
    aderencia: aderencia,
  );
}
