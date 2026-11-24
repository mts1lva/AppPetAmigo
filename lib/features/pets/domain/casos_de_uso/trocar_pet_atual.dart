import '../repositorios/pet_atual_repositorio.dart';

/// Troca o pet atual (N1 Seus pets). As 4 abas passam a mostrar os dados dele.
final class TrocarPetAtual {
  const TrocarPetAtual(this._petAtual);

  final PetAtualRepositorio _petAtual;

  Future<void> call(String petId) => _petAtual.definirId(petId);
}
