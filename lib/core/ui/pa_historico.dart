import 'package:material_ui/material_ui.dart';

import '../../app/tema/espacos.dart';
import '../../app/tema/tipografia.dart';

/// Linha de registro dentro de um card (`design-system.md` → 7. PaHistorico),
/// ex.: `08:00 • Ração habitual • 30 g • 108 kcal`.
///
/// Altura mínima 48, toque em toda a largura, sem divisórias. Várias linhas
/// ficam empilhadas sem espaço extra: passe-as num `Column` como um único
/// filho do `PaCard`.
class PaHistorico extends StatelessWidget {
  const PaHistorico({
    super.key,
    required this.texto,
    required this.aoTocar,
    this.rotuloSemantico,
  });

  final String texto;
  final VoidCallback? aoTocar;

  /// Texto lido pelo leitor de tela, por extenso, ex.:
  /// `Editar registro: 08:00, Ração habitual, 30 gramas, 108 quilocalorias`.
  /// Sem ele, lê o [texto].
  final String? rotuloSemantico;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      button: true,
      enabled: aoTocar != null,
      label: rotuloSemantico ?? texto,
      excludeSemantics: true,
      onTap: aoTocar,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: aoTocar,
          excludeFromSemantics: true,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: PaMedida.historicoAlturaMin,
              minWidth: double.infinity,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(texto, style: PaTexto.corpo),
            ),
          ),
        ),
      ),
    );
  }
}
