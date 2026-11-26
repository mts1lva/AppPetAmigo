import '../repositorios/pesagem_repositorio.dart';

/// "Excluir registro" da tela 11, depois da tela 23. O peso inicial não tem
/// esse botão: só pode ser editado (U2-06).
final class ExcluirPesagem {
  const ExcluirPesagem(this._repositorio);

  final PesagemRepositorio _repositorio;

  Future<void> call(String id, {required DateTime agora}) => _repositorio.excluir(id, agora: agora);
}
