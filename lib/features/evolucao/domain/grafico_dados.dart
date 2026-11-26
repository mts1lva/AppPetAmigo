/// M6 — Matemática do gráfico interativo (U2-02, U2-07). Dart puro.
///
/// O `CustomPainter` (P4-1.4) recebe um [GraficoDados] pronto e **não faz
/// conta**: só converte as frações 0–1 de [GraficoDados.fracaoX] e
/// [GraficoDados.fracaoY] para pixels.
library;

import 'dart:math' as math;

import '../../../core/formato/datas.dart';
import '../../../core/formato/numeros.dart';
import '../../../core/resultado.dart';
import 'calendario.dart';
import 'entidades/pesagem.dart';
import 'parametros.dart';

/// M10 — estado vazio no lugar do gráfico.
String textoGraficoVazio(String nomePet) =>
    'Ainda não há pesagens de $nomePet. Registre a primeira para ver o gráfico.';

/// Um ponto de uma série: dia e peso.
typedef PontoGrafico = ({DateTime dia, double kg});

final class GraficoDados {
  const GraficoDados._({
    required this.hoje,
    required this.inicio,
    required this.fim,
    required this.yMin,
    required this.yMax,
    required this.historico,
    required this.projecao,
    required this.curvaIdeal,
    required this.pesoIdealKg,
    required this.todasPesagens,
  });

  final DateTime hoje;

  /// Eixo X: de `hoje − 30` (ou da primeira pesagem, se mais recente)…
  final DateTime inicio;

  /// … até `hoje + 90`.
  final DateTime fim;

  /// Eixo Y, já com a margem de 10% (ou ±0,5 kg se a faixa for nula).
  final double yMin;
  final double yMax;

  /// Pesagens reais dentro do eixo X, uma por dia (a última), em ordem.
  final List<PontoGrafico> historico;

  /// M4, de hoje a hoje + 90. Vazia se indisponível.
  final List<PontoGrafico> projecao;

  /// M3, de hoje a hoje + 90. Vazia se indisponível.
  final List<PontoGrafico> curvaIdeal;

  /// M2, linha horizontal. `null` se indisponível.
  final double? pesoIdealKg;

  /// Todas as pesagens (uma por dia, em ordem), inclusive as anteriores ao
  /// eixo X, para interpolar na borda.
  final List<PontoGrafico> todasPesagens;

  int get totalDias => diasEntre(inicio, fim);

  /// Posição horizontal de [dia], de 0 ([inicio]) a 1 ([fim]).
  double fracaoX(DateTime dia) => diasEntre(inicio, dia) / totalDias;

  /// Posição vertical de [kg], de 0 ([yMin], embaixo) a 1 ([yMax], em cima).
  double fracaoY(double kg) => (kg - yMin) / (yMax - yMin);

  /// O dia sob o dedo, a partir da fração horizontal (presa em 0–1).
  DateTime diaNaFracao(double fracao) => somarDias(inicio, (fracao.clamp(0.0, 1.0) * totalDias).round());

  /// A pesagem exata de [dia], se houver.
  PontoGrafico? pesagemNoDia(DateTime dia) {
    final alvo = diaDe(dia);
    for (final p in todasPesagens) {
      if (p.dia == alvo) return p;
    }
    return null;
  }

  /// Texto do balão sob o dedo (M6):
  /// - dia com pesagem → `30 set. • 5,4 kg (pesagem)`;
  /// - dia passado sem pesagem → interpolação entre as vizinhas:
  ///   `27 set. • ≈ 5,44 kg (estimado)`;
  /// - dia futuro → `15 nov. • Projeção 4,70 kg • Ideal 4,94 kg` (só as
  ///   séries disponíveis).
  ///
  /// `null` fora do eixo X ou quando não há o que mostrar naquele dia (por
  /// exemplo, entre a última pesagem e hoje, sem vizinha à direita).
  String? textoNoDia(DateTime dia) {
    final alvo = diaDe(dia);
    if (alvo.isBefore(inicio) || alvo.isAfter(fim)) return null;
    final rotuloDia = formatarDiaMes(alvo);

    final exata = pesagemNoDia(alvo);
    if (exata != null) return '$rotuloDia • ${formatarPeso(exata.kg)} (pesagem)';

    final d = diasEntre(hoje, alvo);
    if (d <= 0) {
      final kg = _interpolar(alvo);
      return kg == null ? null : '$rotuloDia • ≈ ${formatarPeso(kg, casas: 2)} (estimado)';
    }

    final partes = [
      if (projecao.isNotEmpty) 'Projeção ${formatarPeso(projecao[d].kg, casas: 2)}',
      if (curvaIdeal.isNotEmpty) 'Ideal ${formatarPeso(curvaIdeal[d].kg, casas: 2)}',
    ];
    return partes.isEmpty ? null : '$rotuloDia • ${partes.join(' • ')}';
  }

  double? _interpolar(DateTime alvo) {
    PontoGrafico? antes;
    PontoGrafico? depois;
    for (final p in todasPesagens) {
      if (p.dia.isBefore(alvo)) antes = p;
      if (p.dia.isAfter(alvo)) {
        depois = p;
        break;
      }
    }
    if (antes == null || depois == null) return null;
    final total = diasEntre(antes.dia, depois.dia);
    final parte = diasEntre(antes.dia, alvo);
    final kg = antes.kg + (depois.kg - antes.kg) * parte / total;
    return kg.isFinite ? kg : null;
  }

  @override
  String toString() => 'GraficoDados(${historico.length} pesagens)';
}

/// Monta os dados do gráfico. Sem nenhuma pesagem: [Indisponivel] com o
/// texto do estado vazio (M10), e nada é desenhado.
///
/// [projecao] e [curvaIdeal] são os 91 valores de M4 e M3 (`null` se
/// indisponíveis); [pesoIdealKg] é o M2.
Resultado<GraficoDados> montarGrafico({
  required Iterable<Pesagem> pesagens,
  required List<double>? projecao,
  required List<double>? curvaIdeal,
  required double? pesoIdealKg,
  required DateTime hoje,
  required String nomePet,
}) {
  // Chave pelo número do dia: uma consulta de fuso por pesagem (RNF06).
  final porDia = <int, Pesagem>{};
  for (final p in pesagens) {
    if (!p.pesoKg.isFinite || p.pesoKg <= 0) continue;
    final dia = numeroDoDia(p.dataHora);
    final atual = porDia[dia];
    if (atual == null || !p.dataHora.isBefore(atual.dataHora)) porDia[dia] = p;
  }
  if (porDia.isEmpty) return Indisponivel(textoGraficoVazio(nomePet));

  final numeros = porDia.keys.toList()..sort();
  final todas = [for (final n in numeros) (dia: diaDoNumero(n), kg: porDia[n]!.pesoKg)];

  final dia0 = diaDe(hoje);
  final limiteEsquerdo = somarDias(dia0, -diasPassadosGrafico);
  final primeira = todas.first.dia;
  final inicio = primeira.isAfter(limiteEsquerdo) ? primeira : limiteEsquerdo;
  final fim = somarDias(dia0, horizonteDias);

  final historico = [
    for (final p in todas)
      if (!p.dia.isBefore(inicio) && !p.dia.isAfter(fim)) p,
  ];

  List<PontoGrafico> serie(List<double>? valores) => valores == null || valores.length <= horizonteDias
      ? const []
      : [for (var d = 0; d <= horizonteDias; d++) (dia: somarDias(dia0, d), kg: valores[d])];

  final proj = serie(projecao);
  final ideal = serie(curvaIdeal);
  final pi = pesoIdealKg != null && pesoIdealKg.isFinite && pesoIdealKg > 0 ? pesoIdealKg : null;

  final valores = [
    for (final p in historico) p.kg,
    for (final p in proj) p.kg,
    for (final p in ideal) p.kg,
    ?pi,
  ].where((v) => v.isFinite).toList();
  if (valores.isEmpty) return Indisponivel(textoGraficoVazio(nomePet));

  var minimo = valores.reduce(math.min);
  var maximo = valores.reduce(math.max);
  if (maximo == minimo) {
    minimo -= margemEixoYPlano;
    maximo += margemEixoYPlano;
  } else {
    final margem = (maximo - minimo) * margemEixoY;
    minimo -= margem;
    maximo += margem;
  }

  return Disponivel(
    GraficoDados._(
      hoje: dia0,
      inicio: inicio,
      fim: fim,
      yMin: minimo,
      yMax: maximo,
      historico: historico,
      projecao: proj,
      curvaIdeal: ideal,
      pesoIdealKg: pi,
      todasPesagens: todas,
    ),
  );
}

/// Lacuna entre pesagens que ganha uma linha no texto alternativo (F06).
const diasLacunaTextoAlternativo = 14;

/// R07 — texto alternativo do gráfico (RNF02), sempre visível embaixo dele:
/// ```
/// 16 set. 5,6 kg → 23 set. 5,5 kg → 30 set. 5,4 kg
/// Peso ideal 4,5 kg • Projeção para 29 dez.: 4,0 kg
/// Previsão para o peso ideal: 28 nov. 2026
/// Sem pesagens entre 1 ago. e 20 ago.        (lacuna > 14 dias)
/// ```
/// Cada linha só aparece com o dado disponível; a previsão (texto de M5,
/// [previsao]) só com peso ideal.
String textoAlternativoGrafico(GraficoDados g, {String? previsao}) {
  final pesagens = g.historico.map((p) => '${formatarDiaMes(p.dia)} ${formatarPeso(p.kg)}').join(' → ');
  final ideal = g.pesoIdealKg;
  final ultimaProjecao = g.projecao.lastOrNull;
  final referencias = [
    if (ideal != null) 'Peso ideal ${formatarPeso(ideal)}',
    if (ultimaProjecao != null)
      'Projeção para ${formatarDiaMes(ultimaProjecao.dia)}: ${formatarPeso(ultimaProjecao.kg)}',
  ];
  final lacunas = [
    for (var i = 1; i < g.historico.length; i++)
      if (diasEntre(g.historico[i - 1].dia, g.historico[i].dia) > diasLacunaTextoAlternativo)
        _frase('Sem pesagens entre ${formatarDiaMes(g.historico[i - 1].dia)} e ${formatarDiaMes(g.historico[i].dia)}'),
  ];
  return [
    if (pesagens.isNotEmpty) pesagens,
    if (referencias.isNotEmpty) referencias.join(' • '),
    if (previsao != null && ideal != null) 'Previsão para o peso ideal: $previsao',
    ...lacunas,
  ].join('\n');
}

/// Fecha a frase com ponto, sem repetir o da abreviação do mês (`30 set.`).
String _frase(String texto) => texto.endsWith('.') ? texto : '$texto.';
