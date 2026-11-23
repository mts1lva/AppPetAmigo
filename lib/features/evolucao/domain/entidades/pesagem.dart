/// Pesagem de um pet (`dados-e-sync.md` → tabela `pesagens`). Dart puro.
///
/// A primeira pesagem do pet é o "peso inicial" (U2-06). Criada pelo P1 na
/// etapa 1 para o `ultimaPesagemProvider`; o P4 é o dono e completa na etapa 4.
final class Pesagem {
  const Pesagem({
    required this.id,
    required this.petId,
    required this.pesoKg,
    required this.dataHora,
    this.conferida = false,
  });

  final String id;
  final String petId;
  final double pesoKg;
  final DateTime dataHora;

  /// O tutor manteve um valor suspeito (R06).
  final bool conferida;

  @override
  bool operator ==(Object other) =>
      other is Pesagem &&
      other.id == id &&
      other.petId == petId &&
      other.pesoKg == pesoKg &&
      other.dataHora == dataHora &&
      other.conferida == conferida;

  @override
  int get hashCode => Object.hash(id, petId, pesoKg, dataHora, conferida);

  /// Sem o peso: logs nunca expõem valores de registros.
  @override
  String toString() => 'Pesagem($id)';
}
