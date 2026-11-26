import 'package:flutter/widgets.dart';

import '../../../../core/ui/ui.dart';
import '../../domain/textos_diario.dart';

/// Tela 22 Confira a densidade (`pacote-2` → 22). Densidade em estado de erro;
/// "Corrigir valor" devolve `true` para o 09 reabrir com os campos preservados.
class DialogoConfiraDensidade extends StatefulWidget {
  const DialogoConfiraDensidade({super.key, required this.densidadeTexto});

  final String densidadeTexto;

  @override
  State<DialogoConfiraDensidade> createState() => _DialogoConfiraDensidadeState();
}

class _DialogoConfiraDensidadeState extends State<DialogoConfiraDensidade> {
  late final _densidade = TextEditingController(text: widget.densidadeTexto);

  @override
  void dispose() {
    _densidade.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PaDialogo(
      titulo: tituloConfiraDensidade,
      subtitulo: subtituloConfiraDensidade,
      texto: textoConfiraDensidade,
      campos: [
        PaCampo.numero(
          rotulo: rotuloDensidade,
          controller: _densidade,
          sufixo: sufixoKcalPor100g,
          erro: '',
        ),
      ],
      botoes: [
        PaBotao.primario(texto: botaoCorrigirValor, aoTocar: () => Navigator.of(context).pop(true)),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop(false)),
      ],
    );
  }
}
