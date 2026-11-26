import '../entidades/petisco.dart';

/// Petiscos cadastrados de um pet (P-32). Dart puro.
///
/// Excluir **arquiva**, como no alimento: some das escolhas, e os registros
/// antigos guardam nome e energia copiados (RF04).
abstract interface class PetiscoRepositorio {
  /// Não arquivados e não excluídos, do mais recente para o mais antigo.
  Stream<List<Petisco>> observarDoPet(String petId);

  Future<void> salvar(Petisco petisco, {required DateTime agora});

  /// Marca `arquivado = true` e enfileira upsert. Idempotente se já estava
  /// arquivado ou não existe.
  Future<void> arquivar(String id, {required DateTime agora});
}
