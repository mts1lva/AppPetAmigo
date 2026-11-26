/// Petisco ou extra de um pet (`dados-e-sync.md` → tabela `extras`).
/// Categoria separada das refeições: a energia é **informada**, não calculada
/// pelo rótulo. Dart puro.
library;

final class Extra {
  const Extra({
    required this.id,
    required this.petId,
    required this.descricao,
    this.quantidadeG,
    required this.energiaKcal,
    required this.dataHora,
  });

  final String id;
  final String petId;

  /// Texto livre; o padrão do formulário é "Petisco".
  final String descricao;

  /// Gramas, opcional (R05). Sem quantidade, a linha mostra só as kcal.
  final double? quantidadeG;
  final double energiaKcal;
  final DateTime dataHora;

  Extra copyWith({
    String? descricao,
    double? Function()? quantidadeG,
    double? energiaKcal,
    DateTime? dataHora,
  }) {
    return Extra(
      id: id,
      petId: petId,
      descricao: descricao ?? this.descricao,
      quantidadeG: quantidadeG == null ? this.quantidadeG : quantidadeG(),
      energiaKcal: energiaKcal ?? this.energiaKcal,
      dataHora: dataHora ?? this.dataHora,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Extra &&
      other.id == id &&
      other.petId == petId &&
      other.descricao == descricao &&
      other.quantidadeG == quantidadeG &&
      other.energiaKcal == energiaKcal &&
      other.dataHora == dataHora;

  @override
  int get hashCode => Object.hash(id, petId, descricao, quantidadeG, energiaKcal, dataHora);

  /// Sem a descrição (dado do tutor).
  @override
  String toString() => 'Extra($id)';
}
