import 'package:flutter/widgets.dart';

import '../../app/tema/cores.dart';
import '../../app/tema/espacos.dart';
import '../../app/tema/tipografia.dart';

/// Estado de sincronização mostrado pela [PaMensagem] (texto da tela 16).
enum PaMensagemEstado {
  pendente('pendente'),
  sincronizado('sincronizado'),
  falha('falha');

  const PaMensagemEstado(this.texto);

  final String texto;
}

/// Mensagem de estado (`design-system.md` → 4. PaMensagem).
///
/// Caixa igual à do `PaCampo`, com altura mínima 62. As três variantes são
/// visualmente idênticas, como no protótipo (P-11): o significado vem do
/// texto, nunca da cor (RNF02).
class PaMensagem extends StatelessWidget {
  const PaMensagem({super.key, required this.estado});

  final PaMensagemEstado estado;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: PaMedida.mensagemAlturaMin),
        padding: const EdgeInsets.all(PaEspaco.paddingCard),
        alignment: Alignment.centerLeft,
        decoration: BoxDecoration(
          color: PaCores.superficie,
          borderRadius: BorderRadius.circular(PaEspaco.raio),
          border: Border.all(color: PaCores.borda, width: PaEspaco.bordaLargura),
        ),
        child: Text(estado.texto, style: PaTexto.corpo),
      ),
    );
  }
}
