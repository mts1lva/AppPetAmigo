import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/cores.dart';
import '../../../../app/tema/espacos.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/formato.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/grafico_dados.dart';

/// Gráfico interativo da Evolução (U2-02; `design-system.md` → Gráfico
/// interativo). Recebe o [GraficoDados] pronto de M6: o [PintorGrafico] só
/// converte frações em pixels, sem conta de modelo.
///
/// Arrastar ou tocar mostra o valor do dia sob o dedo num balão; ao soltar,
/// o balão fica 2 s e o leitor de tela anuncia o texto. O desenho é
/// [ExcludeSemantics]: quem lê o gráfico é o [textoAlternativo] (R07),
/// sempre visível embaixo, junto da legenda.
class GraficoEvolucao extends StatefulWidget {
  const GraficoEvolucao({super.key, required this.dados, required this.textoAlternativo});

  final GraficoDados dados;
  final String textoAlternativo;

  /// Altura da área do gráfico.
  static const altura = 180.0;

  /// Palavras da legenda, cada uma depois do desenho do traço da série
  /// (RNF02): contínuo, tracejado e pontilhado.
  static const legenda = ['pesagens', 'projeção', 'curva ideal'];

  /// Tempo que o balão fica depois de soltar o dedo.
  static const tempoBalao = Duration(seconds: 2);

  @override
  State<GraficoEvolucao> createState() => _GraficoEvolucaoState();
}

class _GraficoEvolucaoState extends State<GraficoEvolucao> {
  DateTime? _dia;
  Timer? _esconder;

  @override
  void dispose() {
    _esconder?.cancel();
    super.dispose();
  }

  void _mover(Offset local, double largura) {
    _esconder?.cancel();
    final dia = widget.dados.diaNaFracao(PintorGrafico.fracaoNoX(local.dx, largura));
    if (dia == _dia) return;
    if (widget.dados.pesagemNoDia(dia) != null) HapticFeedback.selectionClick();
    setState(() => _dia = dia);
  }

  void _soltar() {
    final dia = _dia;
    if (dia == null) return;
    final texto = widget.dados.textoNoDia(dia);
    if (texto != null) {
      SemanticsService.sendAnnouncement(View.of(context), texto, Directionality.of(context));
    }
    _esconder?.cancel();
    _esconder = Timer(GraficoEvolucao.tempoBalao, () {
      if (mounted) setState(() => _dia = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dia = _dia;
    final texto = dia == null ? null : widget.dados.textoNoDia(dia);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: espacar([
        SizedBox(
          height: GraficoEvolucao.altura,
          child: LayoutBuilder(
            builder: (context, limites) {
              final largura = limites.maxWidth;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (d) => _mover(d.localPosition, largura),
                onTapUp: (_) => _soltar(),
                onHorizontalDragStart: (d) => _mover(d.localPosition, largura),
                onHorizontalDragUpdate: (d) => _mover(d.localPosition, largura),
                onHorizontalDragEnd: (_) => _soltar(),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: ExcludeSemantics(
                        child: CustomPaint(painter: PintorGrafico(dados: widget.dados, diaSelecionado: dia)),
                      ),
                    ),
                    if (dia != null && texto != null)
                      _Balao(texto: texto, x: PintorGrafico.xDoDia(widget.dados, dia, largura), largura: largura),
                  ],
                ),
              );
            },
          ),
        ),
        const ExcludeSemantics(child: _Legenda()),
        Text(widget.textoAlternativo, style: PaTexto.legenda),
      ]),
    );
  }
}

/// Balão do valor sob o dedo: `superficie`, borda `borda`, raio 12, padding
/// 8. Nunca sai da área: fica à direita do dedo e inverte perto da borda.
class _Balao extends StatelessWidget {
  const _Balao({required this.texto, required this.x, required this.largura});

  final String texto;
  final double x;
  final double largura;

  static const _distancia = 8.0;

  @override
  Widget build(BuildContext context) {
    final aDireita = x < largura / 2;
    return Positioned(
      top: 0,
      left: aDireita ? x + _distancia : null,
      right: aDireita ? null : largura - x + _distancia,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: (aDireita ? largura - x : x) - _distancia),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: PaCores.superficie,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: PaCores.borda, width: PaEspaco.bordaLargura),
          ),
          child: ExcludeSemantics(child: Text(texto, style: PaTexto.legenda)),
        ),
      ),
    );
  }
}

/// Estado vazio (M10): gato sorrindo, texto e **Registrar peso**. Nunca
/// desenha zero.
class GraficoVazio extends StatelessWidget {
  const GraficoVazio({super.key, required this.nomePet, required this.aoRegistrarPeso});

  final String nomePet;
  final VoidCallback? aoRegistrarPeso;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: espacar([
        const Align(alignment: Alignment.centerLeft, child: PaGatoSorrindo()),
        Text(textoGraficoVazio(nomePet), style: PaTexto.corpo),
        PaBotao.primario(texto: 'Registrar peso', aoTocar: aoRegistrarPeso),
      ]),
    );
  }
}

/// Desenha as séries de [GraficoDados] (`design-system.md`). Só converte
/// frações (0–1) em pixels.
class PintorGrafico extends CustomPainter {
  PintorGrafico({required this.dados, this.diaSelecionado});

  final GraficoDados dados;
  final DateTime? diaSelecionado;

  /// Espaço no topo para os rótulos `hoje` e `ideal …`.
  static const margemTopo = 18.0;

  /// Espaço à esquerda e embaixo para o traço dos eixos.
  static const margemEixo = 2.0;

  /// x, em pixels, do [dia] numa área de [largura]: a mesma conta do
  /// desenho, para o gesto e o balão baterem com o ponto pintado.
  static double xDoDia(GraficoDados dados, DateTime dia, double largura) =>
      margemEixo + dados.fracaoX(dia) * (largura - margemEixo);

  /// Fração horizontal (0–1) sob o dedo em [x].
  static double fracaoNoX(double x, double largura) => (x - margemEixo) / (largura - margemEixo);

  @override
  void paint(Canvas canvas, Size size) {
    final area = Rect.fromLTRB(margemEixo, margemTopo, size.width, size.height - margemEixo);
    Offset ponto(DateTime dia, double kg) =>
        Offset(area.left + dados.fracaoX(dia) * area.width, area.bottom - dados.fracaoY(kg) * area.height);

    // Eixos: `borda`, traço 2.
    final eixo = Paint()
      ..color = PaCores.borda
      ..strokeWidth = 2;
    canvas
      ..drawLine(Offset(area.left, area.top), Offset(area.left, area.bottom), eixo)
      ..drawLine(Offset(area.left, area.bottom), Offset(area.right, area.bottom), eixo);

    // Hoje: vertical `borda`, traço 1, com o rótulo.
    final xHoje = area.left + dados.fracaoX(dados.hoje) * area.width;
    canvas.drawLine(
      Offset(xHoje, area.top),
      Offset(xHoje, area.bottom),
      Paint()
        ..color = PaCores.borda
        ..strokeWidth = 1,
    );
    _rotulo(canvas, 'hoje', Offset(xHoje, 0), centralizar: true, largura: size.width);

    // Peso ideal: horizontal `texto`, traço 1, rótulo na ponta direita.
    final ideal = dados.pesoIdealKg;
    if (ideal != null) {
      final y = area.bottom - dados.fracaoY(ideal) * area.height;
      canvas.drawLine(
        Offset(area.left, y),
        Offset(area.right, y),
        Paint()
          ..color = PaCores.texto
          ..strokeWidth = 1,
      );
      _rotulo(canvas, 'ideal ${formatarPeso(ideal)}', Offset(area.right, y - 18), alinharDireita: true, largura: size.width);
    }

    // Curva ideal: `texto`, traço 2, pontilhado 2/4.
    _serie(canvas, [for (final p in dados.curvaIdeal) ponto(p.dia, p.kg)], PaCores.texto, 2, tracejado: (2, 4));

    // Projeção: `verde`, traço 2, tracejado 6/4.
    _serie(canvas, [for (final p in dados.projecao) ponto(p.dia, p.kg)], PaCores.verde, 2, tracejado: (6, 4));

    // Histórico: `verde`, traço 3, contínuo, pontos de raio 5.
    final historico = [for (final p in dados.historico) ponto(p.dia, p.kg)];
    _serie(canvas, historico, PaCores.verde, 3);
    final bolinha = Paint()..color = PaCores.verde;
    for (final p in historico) {
      canvas.drawCircle(p, 5, bolinha);
    }

    // Dia sob o dedo: vertical `texto`, 1 dp.
    final dia = diaSelecionado;
    if (dia != null) {
      final x = area.left + dados.fracaoX(dia) * area.width;
      canvas.drawLine(
        Offset(x, area.top),
        Offset(x, area.bottom),
        Paint()
          ..color = PaCores.texto
          ..strokeWidth = 1,
      );
    }
  }

  void _serie(Canvas canvas, List<Offset> pontos, Color cor, double largura, {(double, double)? tracejado}) {
    if (pontos.length < 2) return;
    final caminho = Path()..moveTo(pontos.first.dx, pontos.first.dy);
    for (final p in pontos.skip(1)) {
      caminho.lineTo(p.dx, p.dy);
    }
    final tinta = Paint()
      ..color = cor
      ..strokeWidth = largura
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(tracejado == null ? caminho : _tracejar(caminho, tracejado.$1, tracejado.$2), tinta);
  }

  static Path _tracejar(Path caminho, double traco, double espaco) {
    final saida = Path();
    for (final metrica in caminho.computeMetrics()) {
      var d = 0.0;
      while (d < metrica.length) {
        saida.addPath(metrica.extractPath(d, d + traco), Offset.zero);
        d += traco + espaco;
      }
    }
    return saida;
  }

  void _rotulo(
    Canvas canvas,
    String texto,
    Offset onde, {
    required double largura,
    bool centralizar = false,
    bool alinharDireita = false,
  }) {
    final pintor = TextPainter(
      text: TextSpan(text: texto, style: PaTexto.legenda.copyWith(height: 1)),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    var x = onde.dx;
    if (centralizar) x -= pintor.width / 2;
    if (alinharDireita) x -= pintor.width;
    x = x.clamp(0.0, (largura - pintor.width).clamp(0.0, largura));
    pintor.paint(canvas, Offset(x, onde.dy));
  }

  @override
  bool shouldRepaint(PintorGrafico antigo) => antigo.dados != dados || antigo.diaSelecionado != diaSelecionado;
}

/// Legenda embaixo do gráfico: o desenho de cada traço seguido da palavra
/// (`design-system.md`: `── pesagens   - - projeção   ··· curva ideal`).
/// Desenhada, porque a Inter não tem os caracteres de traço `─`.
class _Legenda extends StatelessWidget {
  const _Legenda();

  @override
  Widget build(BuildContext context) {
    Widget item(_Traco traco, String palavra) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(size: const Size(20, 8), painter: _PintorTraco(traco)),
            const SizedBox(width: 6),
            Text(palavra, style: PaTexto.legenda),
          ],
        );
    return Wrap(
      spacing: 16,
      runSpacing: 4,
      children: [
        item(_Traco.continuo, GraficoEvolucao.legenda[0]),
        item(_Traco.tracejado, GraficoEvolucao.legenda[1]),
        item(_Traco.pontilhado, GraficoEvolucao.legenda[2]),
      ],
    );
  }
}

enum _Traco { continuo, tracejado, pontilhado }

class _PintorTraco extends CustomPainter {
  const _PintorTraco(this.traco);

  final _Traco traco;

  @override
  void paint(Canvas canvas, Size size) {
    final (cor, largura, padrao) = switch (traco) {
      _Traco.continuo => (PaCores.verde, 3.0, null),
      _Traco.tracejado => (PaCores.verde, 2.0, (6.0, 4.0)),
      _Traco.pontilhado => (PaCores.texto, 2.0, (2.0, 4.0)),
    };
    final tinta = Paint()
      ..color = cor
      ..strokeWidth = largura;
    final y = size.height / 2;
    if (padrao == null) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), tinta);
      return;
    }
    for (var x = 0.0; x < size.width; x += padrao.$1 + padrao.$2) {
      canvas.drawLine(Offset(x, y), Offset((x + padrao.$1).clamp(0, size.width), y), tinta);
    }
  }

  @override
  bool shouldRepaint(_PintorTraco antigo) => antigo.traco != traco;
}
