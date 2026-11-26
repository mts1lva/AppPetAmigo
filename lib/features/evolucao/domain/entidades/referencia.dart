/// ECC e objetivo informados (`dados-e-sync.md` → tabela `referencias`; tela
/// 12). Uma linha vigente por pet. Dart puro.
library;

/// Opções de "Origem" da tela 12 (P-13). O `name` é o valor gravado.
enum OrigemReferencia {
  /// `Veterinário / consulta`.
  veterinario,

  /// `Outro profissional`.
  outroProfissional,

  /// `Tutor`.
  tutor,
}

final class Referencia {
  const Referencia({
    required this.id,
    required this.petId,
    this.ecc,
    this.objetivoKg,
    required this.origem,
    required this.data,
  });

  final String id;
  final String petId;

  /// 1 a 9 (WSAVA, P-03) ou nulo.
  final int? ecc;

  /// Objetivo de peso informado, em kg, ou nulo.
  final double? objetivoKg;

  final OrigemReferencia origem;

  /// Data em que a referência foi informada.
  final DateTime data;

  @override
  bool operator ==(Object other) =>
      other is Referencia &&
      other.id == id &&
      other.petId == petId &&
      other.ecc == ecc &&
      other.objetivoKg == objetivoKg &&
      other.origem == origem &&
      other.data == data;

  @override
  int get hashCode => Object.hash(id, petId, ecc, objetivoKg, origem, data);

  /// Sem ECC nem objetivo: logs nunca expõem valores de registros.
  @override
  String toString() => 'Referencia($id)';
}
