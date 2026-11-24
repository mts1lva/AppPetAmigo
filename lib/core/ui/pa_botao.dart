import 'package:material_ui/material_ui.dart';

import '../../app/tema/cores.dart';
import '../../app/tema/espacos.dart';
import '../../app/tema/tipografia.dart';

enum PaBotaoVariante {
  /// Fundo `verde`, texto branco. Nos diálogos: todas as ações exceto voltar,
  /// cancelar e excluir. Nos cards: só "Registrar refeição".
  primario,

  /// Fundo `superficie`, borda `borda`. Os outros botões de card e
  /// "Voltar"/"Cancelar" nos diálogos.
  secundario,

  /// Fundo `superficie`, borda `erro`. Ações de exclusão.
  perigo,
}

/// Botão do design system (`design-system.md` → 1. PaBotao).
///
/// Largura total, altura **mínima** 52, texto `corpo` alinhado à esquerda,
/// sem ícones. Desabilitado ([aoTocar] nulo): 40% de opacidade. Em
/// [carregando]: mostra "Salvando…" e bloqueia novo toque (sem spinner).
class PaBotao extends StatelessWidget {
  const PaBotao({
    super.key,
    required this.texto,
    required this.aoTocar,
    required this.variante,
    this.carregando = false,
  });

  const PaBotao.primario({super.key, required this.texto, required this.aoTocar, this.carregando = false})
      : variante = PaBotaoVariante.primario;

  const PaBotao.secundario({super.key, required this.texto, required this.aoTocar, this.carregando = false})
      : variante = PaBotaoVariante.secundario;

  const PaBotao.perigo({super.key, required this.texto, required this.aoTocar, this.carregando = false})
      : variante = PaBotaoVariante.perigo;

  static const textoCarregando = 'Salvando…';

  final String texto;
  final VoidCallback? aoTocar;
  final PaBotaoVariante variante;
  final bool carregando;

  @override
  Widget build(BuildContext context) {
    final habilitado = aoTocar != null && !carregando;
    final (fundo, corBorda, corTexto) = switch (variante) {
      PaBotaoVariante.primario => (PaCores.verde, PaCores.verde, PaCores.superficie),
      PaBotaoVariante.secundario => (PaCores.superficie, PaCores.borda, PaCores.texto),
      PaBotaoVariante.perigo => (PaCores.superficie, PaCores.erro, PaCores.texto),
    };
    final rotulo = carregando ? textoCarregando : texto;

    return Semantics(
      container: true,
      button: true,
      enabled: habilitado,
      label: rotulo,
      excludeSemantics: true,
      onTap: habilitado ? aoTocar : null,
      child: Opacity(
        opacity: aoTocar == null ? 0.4 : 1,
        child: Material(
          color: fundo,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PaEspaco.raio),
            side: BorderSide(color: corBorda, width: PaEspaco.bordaLargura),
          ),
          child: InkWell(
            onTap: habilitado ? aoTocar : null,
            excludeFromSemantics: true,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: PaMedida.botaoAlturaMin,
                minWidth: double.infinity,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(rotulo, style: PaTexto.corpo.copyWith(color: corTexto)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
