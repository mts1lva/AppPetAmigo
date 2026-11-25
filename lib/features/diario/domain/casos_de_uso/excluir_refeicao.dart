import '../repositorios/refeicao_repositorio.dart';

final class ExcluirRefeicao {
  const ExcluirRefeicao(this._repositorio);

  final RefeicaoRepositorio _repositorio;

  Future<void> call(String id, {required DateTime agora}) => _repositorio.excluir(id, agora: agora);
}
