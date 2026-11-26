import '../repositorios/alimento_repositorio.dart';

/// Arquiva o alimento: some das escolhas, sem alterar refeições antigas.
final class ArquivarAlimento {
  const ArquivarAlimento(this._repositorio);

  final AlimentoRepositorio _repositorio;

  Future<void> call(String id, {required DateTime agora}) => _repositorio.arquivar(id, agora: agora);
}
