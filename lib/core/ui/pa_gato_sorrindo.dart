import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app/tema/espacos.dart';

/// Gato sorrindo (64 × 64) do cabeçalho do Início e do estado vazio do
/// gráfico. É decorativo: o leitor de tela não o lê.
class PaGatoSorrindo extends StatelessWidget {
  const PaGatoSorrindo({super.key, this.tamanho = PaMedida.gatoSorrindo});

  static const arquivo = 'assets/img/gato_sorrindo.svg';

  final double tamanho;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SvgPicture.asset(arquivo, width: tamanho, height: tamanho),
    );
  }
}
