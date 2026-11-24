import 'package:flutter/widgets.dart';

import '../core/ui/ui.dart';

/// Tela provisória de uma aba (Fase 0): só o título, no layout das telas
/// principais. Cada pacote troca a sua no `router.dart` quando montar a tela
/// real (Início P1-1.6, Diário P2-1.5, Atividades P3-1.3, Evolução P4-1.5).
class TelaProvisoria extends StatelessWidget {
  const TelaProvisoria({super.key, required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) => PaTelaPrincipal(titulo: titulo);
}
