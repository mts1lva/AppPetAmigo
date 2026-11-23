import '../repositorios/pet_repositorio.dart';

/// Exclui um pet e todos os registros dele (`dados-e-sync.md` → Vários pets).
/// Quem chama confirma antes com `confirmarExclusao()` (tela 23).
final class ExcluirPet {
  const ExcluirPet(this._repositorio);

  final PetRepositorio _repositorio;

  Future<void> call(String petId, {required DateTime agora}) async {
    await _repositorio.excluir(petId, agora: agora);
    // TODO(P3): cancelar as notificações agendadas dos lembretes deste pet
    // (`AgendadorNotificacoes`, etapa 3).
  }
}
