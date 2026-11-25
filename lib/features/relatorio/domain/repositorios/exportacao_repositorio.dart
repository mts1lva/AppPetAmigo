abstract interface class ExportacaoRepositorio {
  /// Snapshot consistente de todos os pets, sem fotos ou controle de sync.
  Future<Map<String, Object?>> carregar();
}
