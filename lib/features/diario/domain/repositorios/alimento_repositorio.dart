import '../entidades/alimento.dart';

/// Alimentos de um pet. Dart puro.
///
/// Excluir **arquiva** (`arquivado = true`): some das escolhas, mas as
/// refeições antigas guardam nome e densidade copiados (RF04). Não é lápide.
abstract interface class AlimentoRepositorio {
  /// Não arquivados e não excluídos, do mais recente para o mais antigo.
  Stream<List<Alimento>> observarDoPet(String petId);

  /// O alimento, ou `null` se não existe, foi arquivado ou excluído.
  Stream<Alimento?> observar(String id);

  /// Alimento do atalho: o da refeição mais recente ainda não arquivada;
  /// sem refeição (ou com o alimento arquivado), o último cadastrado.
  Stream<Alimento?> observarAtalho(String petId);

  Future<void> salvar(Alimento alimento, {required DateTime agora});

  /// Marca `arquivado = true` e enfileira upsert. Idempotente se já estava
  /// arquivado ou não existe.
  Future<void> arquivar(String id, {required DateTime agora});
}
