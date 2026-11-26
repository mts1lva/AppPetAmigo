import '../entidades/refeicao.dart';

/// Refeições de um pet. Dart puro. Exclusão vira lápide (`excluido = true`).
abstract interface class RefeicaoRepositorio {
  /// Não excluídas, no intervalo `[inicio, fim)` (fim exclusivo), por horário.
  Stream<List<Refeicao>> observarEntre(String petId, DateTime inicio, DateTime fim);

  Stream<Refeicao?> observar(String id);

  /// A mais recente do pet (qualquer dia), ou `null`.
  Stream<Refeicao?> observarMaisRecente(String petId);

  /// A mais recente do [dia] (00:00–23:59), ou `null`.
  Stream<Refeicao?> observarMaisRecenteDoDia(String petId, DateTime dia);

  Future<void> salvar(Refeicao refeicao, {required DateTime agora});

  Future<void> excluir(String id, {required DateTime agora});
}
