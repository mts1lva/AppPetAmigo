/// Petisco cadastrado de um pet (P-32). Dart puro.
///
/// Fica na tabela `alimentos` com `tipo = petisco`, mas é uma entidade à
/// parte: a energia é **por unidade**, não por 100 g, e o registro vira um
/// [Extra], não uma refeição.
final class Petisco {
  const Petisco({
    required this.id,
    required this.petId,
    required this.nome,
    required this.kcalPorUnidade,
    required this.unidadesHabituais,
    this.arquivado = false,
  });

  final String id;
  final String petId;
  final String nome;

  /// Energia do rótulo por unidade, em kcal.
  final double kcalPorUnidade;

  /// Quantas unidades costuma dar de uma vez.
  final int unidadesHabituais;
  final bool arquivado;

  Petisco copyWith({String? nome, double? kcalPorUnidade, int? unidadesHabituais, bool? arquivado}) {
    return Petisco(
      id: id,
      petId: petId,
      nome: nome ?? this.nome,
      kcalPorUnidade: kcalPorUnidade ?? this.kcalPorUnidade,
      unidadesHabituais: unidadesHabituais ?? this.unidadesHabituais,
      arquivado: arquivado ?? this.arquivado,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Petisco &&
      other.id == id &&
      other.petId == petId &&
      other.nome == nome &&
      other.kcalPorUnidade == kcalPorUnidade &&
      other.unidadesHabituais == unidadesHabituais &&
      other.arquivado == arquivado;

  @override
  int get hashCode => Object.hash(id, petId, nome, kcalPorUnidade, unidadesHabituais, arquivado);

  /// Sem o nome, que é dado do tutor.
  @override
  String toString() => 'Petisco($id)';
}
