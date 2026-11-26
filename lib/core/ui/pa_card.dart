import 'package:flutter/widgets.dart';

import '../../app/tema/cores.dart';
import '../../app/tema/espacos.dart';
import '../../app/tema/tipografia.dart';
import 'espacar.dart';

enum PaCardVariante {
  /// Fundo `superficie`. Todos os cards.
  padrao,

  /// Fundo `suave`. "Hoje · 30 set." e Sugestões no Início; gráfico na
  /// Evolução.
  destaque,
}

/// Card do design system (`design-system.md` → 3. PaCard).
///
/// Sem borda, raio 16, padding 12, largura total. Coluna com espaço de 12:
/// título (`secao`), texto (`corpo`, opcional) e [filhos] (botões, um
/// `Column` de `PaHistorico` etc.).
class PaCard extends StatelessWidget {
  const PaCard({
    super.key,
    this.titulo,
    this.texto,
    this.filhos = const [],
    this.variante = PaCardVariante.padrao,
  });

  /// Opcional: o card do gráfico da Evolução não tem título (`pacote-4` → 04).
  final String? titulo;
  final String? texto;
  final List<Widget> filhos;
  final PaCardVariante variante;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PaEspaco.paddingCard),
      decoration: BoxDecoration(
        color: variante == PaCardVariante.destaque ? PaCores.suave : PaCores.superficie,
        borderRadius: BorderRadius.circular(PaEspaco.raio),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: espacar([
          if (titulo != null) Semantics(header: true, child: Text(titulo!, style: PaTexto.secao)),
          if (texto != null) Text(texto!, style: PaTexto.corpo),
          ...filhos,
        ]),
      ),
    );
  }
}
