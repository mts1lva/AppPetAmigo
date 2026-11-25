/// Refeição de um pet (`dados-e-sync.md` → tabela `refeicoes`). Dart puro.
///
/// Nome e densidade são **cópias** do alimento no momento do registro
/// (RF04): editar ou arquivar o alimento depois não altera esta linha.
library;

final class Refeicao {
  const Refeicao({
    required this.id,
    required this.petId,
    this.alimentoId,
    required this.alimentoNome,
    required this.densidadeKcalPor100g,
    required this.quantidadeG,
    required this.energiaKcal,
    required this.dataHora,
  });

  final String id;
  final String petId;

  /// Alimento de origem, ou `null` se foi apagado do cadastro.
  final String? alimentoId;

  /// Cópia do nome na ocasião.
  final String alimentoNome;

  /// Cópia da densidade do rótulo (kcal/100 g) na ocasião.
  final double densidadeKcalPor100g;
  final double quantidadeG;

  /// Energia calculada por R01 com [quantidadeG] e [densidadeKcalPor100g].
  final double energiaKcal;
  final DateTime dataHora;

  Refeicao copyWith({
    String? Function()? alimentoId,
    String? alimentoNome,
    double? densidadeKcalPor100g,
    double? quantidadeG,
    double? energiaKcal,
    DateTime? dataHora,
  }) {
    return Refeicao(
      id: id,
      petId: petId,
      alimentoId: alimentoId == null ? this.alimentoId : alimentoId(),
      alimentoNome: alimentoNome ?? this.alimentoNome,
      densidadeKcalPor100g: densidadeKcalPor100g ?? this.densidadeKcalPor100g,
      quantidadeG: quantidadeG ?? this.quantidadeG,
      energiaKcal: energiaKcal ?? this.energiaKcal,
      dataHora: dataHora ?? this.dataHora,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Refeicao &&
      other.id == id &&
      other.petId == petId &&
      other.alimentoId == alimentoId &&
      other.alimentoNome == alimentoNome &&
      other.densidadeKcalPor100g == densidadeKcalPor100g &&
      other.quantidadeG == quantidadeG &&
      other.energiaKcal == energiaKcal &&
      other.dataHora == dataHora;

  @override
  int get hashCode => Object.hash(
        id,
        petId,
        alimentoId,
        alimentoNome,
        densidadeKcalPor100g,
        quantidadeG,
        energiaKcal,
        dataHora,
      );

  /// Sem o nome do alimento (dado do tutor).
  @override
  String toString() => 'Refeicao($id)';
}
