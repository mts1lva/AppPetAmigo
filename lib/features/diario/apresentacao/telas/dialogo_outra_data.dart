import 'package:material_ui/material_ui.dart';

import '../../../../core/formato/datas.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/textos_diario.dart';

/// Abre o 19 Consultar outra data. Devolve `true` se o tutor retomar hoje.
Future<bool> abrirOutraData(BuildContext context, {required DateTime data}) async {
  final retomar = await mostrarPaDialogo<bool>(
    context,
    builder: (_) => DialogoOutraData(data: data),
  );
  return retomar ?? false;
}

/// Tela 19 Consultar outra data (`pacote-2` → 19; R09).
class DialogoOutraData extends StatelessWidget {
  const DialogoOutraData({super.key, required this.data});

  final DateTime data;

  @override
  Widget build(BuildContext context) {
    return PaDialogo(
      titulo: tituloOutraData,
      subtitulo: formatarDataExtenso(data),
      texto: textoSemRegistros,
      botoes: [
        PaBotao.primario(texto: botaoRetomarHoje, aoTocar: () => Navigator.of(context).pop(true)),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop(false)),
      ],
    );
  }
}
