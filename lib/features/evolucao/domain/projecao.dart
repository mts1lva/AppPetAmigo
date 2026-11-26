/// M4 — Projeção adaptativa de 90 dias (U2-04). Dart puro.
///
/// Combina o que o **peso realmente fez** (regressão das pesagens) com o que
/// a **alimentação e a atividade indicam** (balanço energético). Quanto mais
/// pesagens recentes, mais peso tem a tendência observada.
library;

import 'dart:math' as math;

import '../../../core/resultado.dart';
import 'calendario.dart';
import 'entidades/pesagem.dart';
import 'parametros.dart';

const motivoSemProjecao = 'Registre pesagens ou refeições para ver a projeção.';

/// Linha da tela quando o ritmo foi cortado no limite de segurança (M4 d).
const textoProjecaoLimitada = 'projeção limitada ao ritmo máximo seguro';

final class Projecao {
  const Projecao({
    required this.p0,
    required this.observada,
    required this.energetica,
    required this.pesoObservada,
    required this.nPesagens,
    required this.kgDiaSemLimite,
    required this.kgDia,
    required this.limitada,
    required this.curva,
  });

  /// Última pesagem, em kg.
  final double p0;

  /// (a) Tendência observada, kg/dia; `null` sem 2 pesagens úteis.
  final double? observada;

  /// (b) Tendência energética, kg/dia; `null` sem MER ou com menos de 3 dias
  /// com registro.
  final double? energetica;

  /// `w = min(1, nPesagens ÷ 4)`.
  final double pesoObservada;

  /// Pesagens usadas na regressão (janela de 30 dias, uma por dia, sem as
  /// conferidas fora do limite).
  final int nPesagens;

  /// (c) Combinação, antes do limite.
  final double kgDiaSemLimite;

  /// (d) Ritmo final, já limitado a 2% do peso por semana.
  final double kgDia;

  final bool limitada;

  /// (e) `proj(0) … proj(90)`, em kg.
  final List<double> curva;

  @override
  String toString() => 'Projecao(limitada: $limitada)';
}

/// Uma pesagem usada pela regressão: dia relativo e peso.
typedef PontoPeso = ({DateTime dia, double kg});

/// M4 completo.
///
/// - [ingestaoPorDia]: kcal do dia (ração + extras), **só** dos dias com
///   registro. Dia vazio não entra (R09). As chaves podem ter hora; vale o dia.
/// - [atividadeKcalPorDia]: Σ kcal das atividades nos últimos 14 dias ÷ 14
///   (o `gastoAtividadeProvider` do P3).
/// - [mer]: meta diária (M1), `null` se indisponível.
Resultado<Projecao> projecao({
  required Iterable<Pesagem> pesagens,
  required Map<DateTime, double> ingestaoPorDia,
  required double atividadeKcalPorDia,
  required double? mer,
  required DateTime hoje,
}) {
  final ultima = _ultima(pesagens);
  if (ultima == null) return const Indisponivel(motivoSemProjecao);
  final p0 = ultima.pesoKg;
  if (!p0.isFinite || p0 <= 0) return const Indisponivel(motivoSemProjecao);

  final pontos = pontosDaRegressao(pesagens, hoje);
  final obs = tendenciaObservada(pontos);
  final en = tendenciaEnergetica(
    ingestaoPorDia: ingestaoPorDia,
    atividadeKcalPorDia: atividadeKcalPorDia,
    mer: mer,
    hoje: hoje,
  );

  final w = math.min(1.0, pontos.length / pesagensParaPesoTotal);
  final double kgDiaSemLimite;
  if (obs != null && en != null) {
    kgDiaSemLimite = w * obs + (1 - w) * en;
  } else if (obs != null) {
    kgDiaSemLimite = obs;
  } else if (en != null) {
    kgDiaSemLimite = en;
  } else {
    return const Indisponivel(motivoSemProjecao);
  }

  final limite = ritmoSemanalMaximo * p0 / 7;
  final limitada = kgDiaSemLimite.abs() > limite;
  final kgDia = limitada ? limite * kgDiaSemLimite.sign : kgDiaSemLimite;

  final curva = List<double>.generate(horizonteDias + 1, (d) => math.max(pesoMinimoProjecao, p0 + kgDia * d));

  final valores = [kgDiaSemLimite, kgDia, ...curva];
  assert(valores.every((v) => v.isFinite), 'M4 produziu um valor não finito');
  if (!valores.every((v) => v.isFinite)) return const Indisponivel(motivoSemProjecao);

  return Disponivel(
    Projecao(
      p0: p0,
      observada: obs,
      energetica: en,
      pesoObservada: w,
      nPesagens: pontos.length,
      kgDiaSemLimite: kgDiaSemLimite,
      kgDia: kgDia,
      limitada: limitada,
      curva: curva,
    ),
  );
}

/// Pesagens que entram na regressão (M4 a), em ordem de data:
/// 1. no mesmo dia, vale a última;
/// 2. sai a pesagem `conferida` que, comparada com a anterior válida, passa
///    de 2% do peso por semana (erro de digitação mantido pelo tutor). Ela
///    continua no gráfico;
/// 3. só os últimos 30 dias (`hoje − 29 … hoje`).
List<PontoPeso> pontosDaRegressao(Iterable<Pesagem> pesagens, DateTime hoje) {
  // Chave pelo número do dia: uma consulta de fuso por pesagem (RNF06).
  final porDia = <int, Pesagem>{};
  for (final p in pesagens) {
    final dia = numeroDoDia(p.dataHora);
    final atual = porDia[dia];
    if (atual == null || !p.dataHora.isBefore(atual.dataHora)) porDia[dia] = p;
  }
  final ordenadas = [for (final e in porDia.entries) (dia: e.key, p: e.value)]
    ..sort((a, b) => a.p.dataHora.compareTo(b.p.dataHora));

  final validas = <({int dia, Pesagem p})>[];
  for (final item in ordenadas) {
    if (item.p.conferida && validas.isNotEmpty && _foraDoLimite(validas.last, item)) continue;
    validas.add(item);
  }

  final diaHoje = numeroDoDia(hoje);
  return [
    for (final v in validas)
      if (diaHoje - v.dia < janelaPesagensDias && diaHoje - v.dia >= 0) (dia: diaDoNumero(v.dia), kg: v.p.pesoKg),
  ];
}

/// (a) Regressão linear (mínimos quadrados), em kg/dia.
/// ```
/// x = dias desde a primeira pesagem da janela; y = kg
/// obs = Sxy ÷ Sxx        (exige n ≥ 2 e Sxx > 0; senão, null)
/// ```
double? tendenciaObservada(List<PontoPeso> pontos) {
  if (pontos.length < 2) return null;
  final inicio = pontos.first.dia;
  final xs = [for (final p in pontos) diasEntre(inicio, p.dia).toDouble()];
  final ys = [for (final p in pontos) p.kg];
  final mx = xs.reduce((a, b) => a + b) / xs.length;
  final my = ys.reduce((a, b) => a + b) / ys.length;
  var sxx = 0.0;
  var sxy = 0.0;
  for (var i = 0; i < xs.length; i++) {
    sxx += (xs[i] - mx) * (xs[i] - mx);
    sxy += (xs[i] - mx) * (ys[i] - my);
  }
  if (sxx <= 0) return null;
  final obs = sxy / sxx;
  return obs.isFinite ? obs : null;
}

/// (b) Balanço energético dos últimos 14 dias (`hoje − 13 … hoje`), em kg/dia.
/// ```
/// ingestão = média de kcal/dia nos dias com registro (exige ≥ 3)
/// gasto    = MER + atividade
/// en       = (ingestão − gasto) ÷ 7.700
/// ```
double? tendenciaEnergetica({
  required Map<DateTime, double> ingestaoPorDia,
  required double atividadeKcalPorDia,
  required double? mer,
  required DateTime hoje,
}) {
  if (mer == null || !mer.isFinite || !atividadeKcalPorDia.isFinite) return null;
  final porDia = <DateTime, double>{};
  ingestaoPorDia.forEach((data, kcal) {
    final atras = diasEntre(data, hoje);
    if (atras >= 0 && atras < janelaEnergiaDias && kcal.isFinite) {
      final dia = diaDe(data);
      porDia[dia] = (porDia[dia] ?? 0) + kcal;
    }
  });
  if (porDia.length < minimoDiasComRegistro) return null;
  final ingestao = porDia.values.reduce((a, b) => a + b) / porDia.length;
  final en = (ingestao - (mer + atividadeKcalPorDia)) / kcalPorKg;
  return en.isFinite ? en : null;
}

/// Mais de 2% do peso por semana entre [anterior] e [p]. No mesmo dia,
/// qualquer diferença passa do limite.
bool _foraDoLimite(({int dia, Pesagem p}) anteriorValida, ({int dia, Pesagem p}) atual) {
  final (anterior, p) = (anteriorValida.p, atual.p);
  final dias = atual.dia - anteriorValida.dia;
  final variacao = (p.pesoKg - anterior.pesoKg).abs() / anterior.pesoKg;
  if (dias <= 0) return variacao > 0;
  return variacao / (dias / 7) > ritmoSemanalMaximo;
}

Pesagem? _ultima(Iterable<Pesagem> pesagens) {
  Pesagem? ultima;
  for (final p in pesagens) {
    if (ultima == null || !p.dataHora.isBefore(ultima.dataHora)) ultima = p;
  }
  return ultima;
}
