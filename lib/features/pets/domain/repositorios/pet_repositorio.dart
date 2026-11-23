import '../entidades/pet.dart';

/// Pets do aparelho (U2-10). Dart puro.
///
/// Toda gravação é **uma transação** que também chama a `FilaSync` e mantém
/// `config.petAtualId` coerente, para nunca sobrar pet sem pet atual (o que
/// levaria ao 26 por engano).
abstract interface class PetRepositorio {
  /// Pets não excluídos, por ordem de cadastro.
  Stream<List<Pet>> observarTodos();

  /// O pet, ou `null` se não existe ou foi excluído.
  Stream<Pet?> observar(String id);

  /// Peso inicial do pet: a **primeira pesagem** (U2-06), ou `null`.
  Stream<double?> observarPesoInicial(String petId);

  /// Grava o pet **e a primeira pesagem** (peso inicial) e torna o pet o
  /// atual, tudo na mesma transação.
  Future<void> cadastrar(Pet pet, {required double pesoInicialKg, required DateTime agora});

  /// Grava as alterações do pet. Com [pesoInicialKg], altera também a
  /// primeira pesagem.
  Future<void> editar(Pet pet, {double? pesoInicialKg, required DateTime agora});

  /// Exclui o pet e, em cascata, todos os registros dele (lápide). Se era o
  /// pet atual, o atual passa a ser o primeiro da lista por ordem de cadastro;
  /// se não sobrar nenhum, fica sem pet atual (tela 26).
  Future<void> excluir(String id, {required DateTime agora});
}
