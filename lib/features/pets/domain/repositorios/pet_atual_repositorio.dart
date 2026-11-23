/// Qual pet aparece nas telas (`config.petAtualId`, U2-10). Dart puro.
///
/// Fica separado do `PetRepositorio` (cadastro, edição e exclusão, P1-1.1)
/// porque o roteador e todos os pacotes dependem só disto.
abstract interface class PetAtualRepositorio {
  /// Emite o id do pet atual e cada troca; `null` quando não há pet.
  Stream<String?> observarId();

  /// Define o pet atual; `null` limpa (último pet excluído).
  Future<void> definirId(String? petId);
}
