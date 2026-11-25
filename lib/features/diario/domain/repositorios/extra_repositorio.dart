import '../entidades/extra.dart';

/// Petiscos e extras de um pet. Dart puro. Exclusão vira lápide.
abstract interface class ExtraRepositorio {
  /// Não excluídos, no intervalo `[inicio, fim)` (fim exclusivo), por horário.
  Stream<List<Extra>> observarEntre(String petId, DateTime inicio, DateTime fim);

  Stream<Extra?> observar(String id);

  Stream<Extra?> observarMaisRecenteDoDia(String petId, DateTime dia);

  Future<void> salvar(Extra extra, {required DateTime agora});

  Future<void> excluir(String id, {required DateTime agora});
}
