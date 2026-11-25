import '../entidades/atividade.dart';
import '../repositorios/atividade_repositorio.dart';

final class SalvarAtividade {
  const SalvarAtividade(this._repositorio);
  final AtividadeRepositorio _repositorio;

  Future<void> call(Atividade atividade, {required DateTime agora}) {
    if (validarAtividade(atividade, agora).isNotEmpty)
      throw ArgumentError('Atividade inválida.');
    return _repositorio.salvar(atividade, agora: agora);
  }
}
