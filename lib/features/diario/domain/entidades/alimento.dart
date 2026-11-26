import 'alimento_cadastrado.dart';

/// Alimento cadastrado de um pet (`dados-e-sync.md` → tabela `alimentos`).
/// Dart puro.
///
/// Criado pelo P1 na etapa 1, com os campos da tabela, para o card
/// "Referência alimentar" do Início converter a meta em gramas (R04). O P2 é
/// o dono e completa na etapa 2.
final class Alimento implements AlimentoCadastrado {
  const Alimento({
    required this.id,
    required this.petId,
    required this.nome,
    required this.densidadeKcalPor100g,
    required this.porcaoPadraoG,
    this.arquivado = false,
  });

  @override
  final String id;
  @override
  final String petId;
  @override
  final String nome;

  /// Energia do rótulo, em kcal por 100 g.
  final double densidadeKcalPor100g;

  /// Porção habitual, em gramas.
  final double porcaoPadraoG;
  @override
  final bool arquivado;

  Alimento copyWith({
    String? nome,
    double? densidadeKcalPor100g,
    double? porcaoPadraoG,
    bool? arquivado,
  }) {
    return Alimento(
      id: id,
      petId: petId,
      nome: nome ?? this.nome,
      densidadeKcalPor100g: densidadeKcalPor100g ?? this.densidadeKcalPor100g,
      porcaoPadraoG: porcaoPadraoG ?? this.porcaoPadraoG,
      arquivado: arquivado ?? this.arquivado,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Alimento &&
      other.id == id &&
      other.petId == petId &&
      other.nome == nome &&
      other.densidadeKcalPor100g == densidadeKcalPor100g &&
      other.porcaoPadraoG == porcaoPadraoG &&
      other.arquivado == arquivado;

  @override
  int get hashCode => Object.hash(id, petId, nome, densidadeKcalPor100g, porcaoPadraoG, arquivado);

  /// Sem o nome, que é dado do tutor (logs não expõem dados pessoais).
  @override
  String toString() => 'Alimento($id)';
}
