import '../entidades/petisco.dart';
import '../energia.dart';
import '../repositorios/petisco_repositorio.dart';

/// Grava o petisco cadastrado (P-32). A tela valida antes; chamar com valor
/// inválido é erro de programação.
final class SalvarPetisco {
  const SalvarPetisco(this._repositorio);

  final PetiscoRepositorio _repositorio;

  Future<void> call(Petisco petisco, {required DateTime agora}) {
    if (!petisco.kcalPorUnidade.isFinite || petisco.kcalPorUnidade <= 0) {
      throw ArgumentError(motivoEnergiaPorUnidadeInvalida);
    }
    if (petisco.unidadesHabituais <= 0) {
      throw ArgumentError(motivoUnidadesInvalidas);
    }
    if (petisco.nome.trim().isEmpty) {
      throw ArgumentError('Informe o nome.');
    }
    return _repositorio.salvar(petisco.copyWith(nome: petisco.nome.trim()), agora: agora);
  }
}
