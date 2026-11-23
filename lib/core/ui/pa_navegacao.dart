import 'package:material_ui/material_ui.dart';

import '../../app/tema/cores.dart';
import '../../app/tema/espacos.dart';
import '../../app/tema/tipografia.dart';

/// Barra inferior fixa com os 4 destinos (`design-system.md` → 6. PaNavegacao).
///
/// Fundo `superficie`, padding 8, itens com `Expanded` e espaço de 8. Item
/// com altura mínima 56, raio 16, borda `borda`, texto centralizado e **sem
/// ícones**. Ativo: fundo `suave`. Com fonte grande, a barra cresce em altura
/// em vez de cortar o texto.
class PaNavegacao extends StatelessWidget {
  const PaNavegacao({super.key, required this.indiceAtual, required this.aoSelecionar});

  /// Os 4 destinos, nesta ordem (`navegacao.md`).
  static const destinos = ['Início', 'Diário', 'Atividades', 'Evolução'];

  final int indiceAtual;
  final ValueChanged<int> aoSelecionar;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PaCores.superficie,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(PaMedida.navegacaoPadding),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < destinos.length; i++) ...[
                  if (i > 0) const SizedBox(width: PaMedida.navegacaoPadding),
                  Expanded(
                    child: _ItemNavegacao(
                      texto: destinos[i],
                      ativo: i == indiceAtual,
                      aoTocar: () => aoSelecionar(i),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemNavegacao extends StatelessWidget {
  const _ItemNavegacao({required this.texto, required this.ativo, required this.aoTocar});

  final String texto;
  final bool ativo;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      selected: ativo,
      label: texto,
      excludeSemantics: true,
      onTap: aoTocar,
      child: Material(
        color: ativo ? PaCores.suave : PaCores.superficie,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(PaEspaco.raio),
          side: const BorderSide(color: PaCores.borda, width: PaEspaco.bordaLargura),
        ),
        child: InkWell(
          onTap: aoTocar,
          excludeFromSemantics: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: PaMedida.navegacaoItemAlturaMin),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: Center(
                child: Text(texto, style: PaTexto.navegacao, textAlign: TextAlign.center),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
