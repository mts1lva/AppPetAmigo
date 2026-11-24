/// Espaço, raio e borda do design system.
abstract final class PaEspaco {
  /// Token "espaco": entre cards, entre elementos de card e diálogo,
  /// entre título e subtítulo.
  static const s = 12.0;
  static const margemTela = 20.0;
  static const paddingCard = 12.0;
  static const paddingDialogo = 16.0;
  static const raio = 16.0;
  static const bordaLargura = 1.0;
}

/// Medidas mínimas dos componentes. São sempre **mínimas**: com fonte a 200%,
/// tudo cresce em altura (RNF02).
abstract final class PaMedida {
  static const botaoAlturaMin = 52.0;
  static const campoAlturaMin = 64.0;
  static const mensagemAlturaMin = 62.0;
  static const historicoAlturaMin = 48.0;
  static const navegacaoItemAlturaMin = 56.0;
  static const navegacaoAltura = 72.0;
  static const navegacaoPadding = 8.0;
  static const fotoPet = 64.0;
  static const gatoSorrindo = 64.0;
  static const dialogoLarguraMax = 350.0;
}
