import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/cores.dart';
import '../../../../app/tema/espacos.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/ui/ui.dart';

/// Tela 26 "Vamos começar?" (`26-vamos-comecar.png`): estado sem pet, fundo
/// `superficie` e **sem navegação**. Bloco com padding de 16, como um
/// diálogo sem véu, em (20, 120) no frame do Figma (y = 120 inclui os 24 da
/// barra de status, que aqui ficam com o `SafeArea`).
class TelaVamosComecar extends StatelessWidget {
  const TelaVamosComecar({super.key, required this.aoCadastrar});

  /// Abre o 05 Dados do pet em modo cadastro. Nulo até a P1-1.3 (botão
  /// desabilitado).
  final VoidCallback? aoCadastrar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PaCores.superficie,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            PaEspaco.margemTela + PaEspaco.paddingDialogo,
            120 - 24 + PaEspaco.paddingDialogo,
            PaEspaco.margemTela + PaEspaco.paddingDialogo,
            PaEspaco.margemTela,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: espacar([
              Semantics(header: true, child: const Text('Vamos começar?', style: PaTexto.titulo)),
              const Text('Cadastre seu cão ou gato.', style: PaTexto.legenda),
              const Text('Não há pet nem registros neste aparelho.', style: PaTexto.corpo),
              PaBotao.primario(texto: 'Cadastrar pet', aoTocar: aoCadastrar),
            ]),
          ),
        ),
      ),
    );
  }
}
