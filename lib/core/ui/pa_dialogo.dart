import 'package:material_ui/material_ui.dart';

import '../../app/tema/cores.dart';
import '../../app/tema/espacos.dart';
import '../../app/tema/tipografia.dart';
import 'espacar.dart';

/// Abre um diálogo do design system por cima da tela atual, com o véu
/// (`PaCores.veu`). "Voltar", o véu e o botão voltar do Android fecham sem
/// salvar.
Future<T?> mostrarPaDialogo<T>(BuildContext context, {required WidgetBuilder builder}) {
  return showDialog<T>(context: context, barrierColor: PaCores.veu, builder: builder);
}

/// Diálogo do design system (`design-system.md` → 5. PaDialogo).
///
/// Conteúdo em coluna com espaço de 12: título, subtítulo, texto explicativo,
/// campos e botões. Ordem dos botões: **primário(s) → perigo → secundário
/// ("Voltar"/"Cancelar") por último**. Rola dentro do diálogo se passar da
/// altura disponível.
class PaDialogo extends StatelessWidget {
  const PaDialogo({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.texto,
    this.campos = const [],
    this.botoes = const [],
  });

  final String titulo;
  final String? subtitulo;
  final String? texto;
  final List<Widget> campos;
  final List<Widget> botoes;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: PaCores.superficie,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: PaEspaco.margemTela, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(PaEspaco.raio)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PaMedida.dialogoLarguraMax),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(PaEspaco.paddingDialogo),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: espacar([
              Semantics(header: true, child: Text(titulo, style: PaTexto.titulo)),
              if (subtitulo != null) Text(subtitulo!, style: PaTexto.legenda),
              if (texto != null) Text(texto!, style: PaTexto.corpo),
              ...campos,
              ...botoes,
            ]),
          ),
        ),
      ),
    );
  }
}
