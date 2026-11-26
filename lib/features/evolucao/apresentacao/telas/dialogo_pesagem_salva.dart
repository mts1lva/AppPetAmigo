import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/celebracao.dart';
import '../../domain/textos_evolucao.dart';
import 'tela_evolucao.dart';

/// Abre o N3 Pesagem salva (celebração de M8), com o layout da tela 20.
Future<void> abrirPesagemSalva(BuildContext context, {required String celebracao}) {
  return mostrarPaDialogo<void>(context, builder: (_) => DialogoPesagemSalva(celebracao: celebracao));
}

class DialogoPesagemSalva extends StatelessWidget {
  const DialogoPesagemSalva({super.key, required this.celebracao});

  /// "Luna chegou 100 g mais perto do peso ideal!"
  final String celebracao;

  @override
  Widget build(BuildContext context) {
    return PaDialogo(
      titulo: TextosPesagemSalva.titulo,
      subtitulo: TextosPesagemSalva.subtitulo,
      campos: [
        const Align(alignment: Alignment.centerLeft, child: PaGatoSorrindo()),
        Semantics(
          liveRegion: true,
          child: Text('$celebracao\n$textoContinueNoSeuRitmo', style: PaTexto.corpo),
        ),
      ],
      botoes: [
        PaBotao.primario(
          texto: 'Ver evolução',
          aoTocar: () {
            final roteador = GoRouter.maybeOf(context);
            Navigator.of(context).pop();
            roteador?.go(Rotas.evolucao);
            WidgetsBinding.instance.addPostFrameCallback((_) => TelaEvolucao.rolarAteGrafico());
          },
        ),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
