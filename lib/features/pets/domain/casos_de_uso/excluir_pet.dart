import '../entidades/pet.dart';
import '../repositorios/fotos_pet.dart';
import '../repositorios/pet_repositorio.dart';

/// Exclui um pet, todos os registros dele e a foto
/// (`dados-e-sync.md` → Vários pets). Quem chama confirma antes com
/// `confirmarExclusao()` (tela 23).
final class ExcluirPet {
  const ExcluirPet(this._repositorio, this._fotos, {this.cancelarLembretes});
  final Future<void> Function(String petId)? cancelarLembretes;

  final PetRepositorio _repositorio;
  final ArmazenamentoFotos _fotos;

  Future<void> call(Pet pet, {required DateTime agora}) async {
    await _repositorio.excluir(pet.id, agora: agora);
    await cancelarLembretes?.call(pet.id);
    final foto = pet.fotoArquivo;
    if (foto != null) await _fotos.apagar(foto);
  }
}
