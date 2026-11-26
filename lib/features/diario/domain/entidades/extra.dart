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
    this.alimentoId,
    this.unidades,
  });

  final String id;
  final String petId;

  /// Texto livre; o padrão do formulário é "Petisco".
  final String descricao;

  /// Gramas, opcional (R05). Sem quantidade, a linha mostra só as kcal.
  final double? quantidadeG;
  final double energiaKcal;
  final DateTime dataHora;

  /// Petisco cadastrado usado (P-32); `null` no petisco digitado na hora.
  /// A descrição e a energia são cópias do petisco na ocasião (RF04).
  final String? alimentoId;

  /// Unidades do petisco cadastrado (P-32); `null` no petisco digitado.
  final int? unidades;

  /// Energia por unidade copiada no registro (R01, P-32), para recalcular ao
  /// editar as unidades. `null` sem unidades.
  double? get kcalPorUnidade {
    final u = unidades;
    return u == null || u <= 0 ? null : energiaKcal / u;
  }

  Extra copyWith({
    String? descricao,
    double? Function()? quantidadeG,
    double? energiaKcal,
    DateTime? dataHora,
    String? Function()? alimentoId,
    int? Function()? unidades,
  }) {
    return Extra(
      id: id,
      petId: petId,
      descricao: descricao ?? this.descricao,
      quantidadeG: quantidadeG == null ? this.quantidadeG : quantidadeG(),
      energiaKcal: energiaKcal ?? this.energiaKcal,
      dataHora: dataHora ?? this.dataHora,
      alimentoId: alimentoId == null ? this.alimentoId : alimentoId(),
      unidades: unidades == null ? this.unidades : unidades(),
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
      other.dataHora == dataHora &&
      other.alimentoId == alimentoId &&
      other.unidades == unidades;

  @override
  int get hashCode => Object.hash(id, petId, descricao, quantidadeG, energiaKcal, dataHora, alimentoId, unidades);

  /// Sem a descrição (dado do tutor).
  @override
  String toString() => 'Extra($id)';
}
