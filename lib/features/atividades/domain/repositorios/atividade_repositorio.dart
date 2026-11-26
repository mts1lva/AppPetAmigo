import '../entidades/atividade.dart';

abstract interface class AtividadeRepositorio {
  Stream<List<Atividade>> observar(
    String petId, {
    required DateTime inicio,
    required DateTime fim,
  });
  Future<void> salvar(Atividade atividade, {required DateTime agora});
  Future<void> excluir(String petId, String id, {required DateTime agora});
}
