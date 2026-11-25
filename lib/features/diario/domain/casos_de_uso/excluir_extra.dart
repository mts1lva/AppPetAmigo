import '../repositorios/extra_repositorio.dart';

final class ExcluirExtra {
  const ExcluirExtra(this._repositorio);

  final ExtraRepositorio _repositorio;

  Future<void> call(String id, {required DateTime agora}) => _repositorio.excluir(id, agora: agora);
}
