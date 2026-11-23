import 'package:flutter/widgets.dart';

import '../../app/tema/espacos.dart';
import '../../app/tema/tipografia.dart';
import 'espacar.dart';

/// Layout das 4 telas principais (`design-system.md` → Layout das telas
/// principais): conteúdo rolável com margem de 20, título (`titulo`),
/// subtítulo (`legenda`) e os cards com espaço de 12. A `PaNavegacao` fica
/// fixa por baixo, no shell das abas (`app/router.dart`).
///
/// No Figma o conteúdo começa em y = 24 por causa da barra de status; aqui
/// isso fica a cargo do `SafeArea`.
class PaTelaPrincipal extends StatelessWidget {
  const PaTelaPrincipal({
    super.key,
    required this.titulo,
    this.subtitulo,
    this.filhos = const [],
  });

  final String titulo;
  final String? subtitulo;
  final List<Widget> filhos;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PaEspaco.margemTela),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: espacar([
            Semantics(header: true, child: Text(titulo, style: PaTexto.titulo)),
            if (subtitulo != null) Text(subtitulo!, style: PaTexto.legenda),
            ...filhos,
          ]),
        ),
      ),
    );
  }
}
