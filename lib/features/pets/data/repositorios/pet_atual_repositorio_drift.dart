import '../../../../core/banco/daos/config_dao.dart';
import '../../domain/repositorios/pet_atual_repositorio.dart';

/// Guarda o pet atual na tabela `config` (chave `petAtualId`). A tabela
/// `config` não é sincronizada, então não passa pela `FilaSync`.
final class PetAtualRepositorioDrift implements PetAtualRepositorio {
  const PetAtualRepositorioDrift(this._config);

  final ConfigDao _config;

  @override
  Stream<String?> observarId() => _config.observar(ChavesConfig.petAtualId);

  @override
  Future<void> definirId(String? petId) => _config.gravar(ChavesConfig.petAtualId, petId);
}
