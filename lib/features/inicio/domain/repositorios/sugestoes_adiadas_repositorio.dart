import '../../../../core/sugestao.dart';

/// Sugestões que o tutor adiou com "Agora não" (M8: somem por 7 dias).
abstract interface class SugestoesAdiadasRepositorio {
  /// Tipo → dia em que o tutor tocou "Agora não". Emite a cada mudança.
  Stream<Map<TipoSugestao, DateTime>> observar();

  Future<void> adiar(TipoSugestao tipo, DateTime em);
}
