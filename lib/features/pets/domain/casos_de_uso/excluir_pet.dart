import '../entidades/pet.dart';
import '../repositorios/fotos_pet.dart';
import '../repositorios/pet_repositorio.dart';

/// Exclui um pet, todos os registros dele e a foto
/// (`dados-e-sync.md` → Vários pets). Quem chama confirma antes com
/// `confirmarExclusao()` (tela 23).
final class ExcluirPet {
  const ExcluirPet(this._repositorio, this._fotos);

  final PetRepositorio _repositorio;
  final ArmazenamentoFotos _fotos;

  Future<void> call(Pet pet, {required DateTime agora}) async {
    await _repositorio.excluir(pet.id, agora: agora);
    final foto = pet.fotoArquivo;
    if (foto != null) await _fotos.apagar(foto);
    // TODO(P3): cancelar as notificações agendadas dos lembretes deste pet
    // (`AgendadorNotificacoes`, etapa 3).
  }
}
