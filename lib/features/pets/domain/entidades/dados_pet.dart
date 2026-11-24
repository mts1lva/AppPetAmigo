import 'pet.dart';

/// Dados do formulário 05 Dados do pet, como o tutor preencheu (os campos de
/// escolha começam vazios no cadastro). Dart puro.
final class DadosPet {
  const DadosPet({
    this.nome = '',
    this.especie,
    this.sexo,
    this.anos,
    this.meses,
    this.castrado,
    this.nivelAtividade,
    this.pesoInicialKg,
  });

  /// Preenche o formulário de edição com o pet e o peso inicial atuais.
  factory DadosPet.dePet(Pet pet, {required DateTime hoje, double? pesoInicialKg}) {
    final idade = pet.idadeMesesEm(hoje);
    return DadosPet(
      nome: pet.nome,
      especie: pet.especie,
      sexo: pet.sexo,
      anos: idade ~/ 12,
      meses: idade % 12,
      castrado: pet.castrado,
      nivelAtividade: pet.nivelAtividade,
      pesoInicialKg: pesoInicialKg,
    );
  }

  final String nome;
  final Especie? especie;
  final Sexo? sexo;
  final int? anos;
  final int? meses;
  final bool? castrado;
  final NivelAtividade? nivelAtividade;
  final double? pesoInicialKg;

  /// Idade total em meses (`anos × 12 + meses`), ou `null` se faltar parte.
  int? get idadeMeses => (anos == null || meses == null) ? null : anos! * 12 + meses!;
}

/// Campos do formulário 05, na ordem da tela (o foco vai ao primeiro com erro).
enum CampoPet { nome, especie, sexo, idade, castracao, atividade, pesoInicial }

/// Mensagens de R05 (`comum/regras.md`).
abstract final class MensagensPet {
  static const nome = 'Informe o nome.';
  static const idade = 'Informe a idade.';
  static const pesoPositivo = 'O valor precisa ser positivo.';
  static const pesoAcima = 'Confira o valor: acima de 150 kg.';

  /// Escolha obrigatória sem texto em R05 ("—"): o campo só fica com a
  /// borda de erro.
  static const escolha = '';
}

/// Limites técnicos de R05 (P-10). Não são critérios clínicos.
const tamanhoMaximoNome = 40;
const idadeMaximaAnos = 30;
const pesoMaximoKg = 150.0;

/// R05 — valida o formulário 05. Devolve os campos com erro e a mensagem de
/// cada um (vazio = sem erro), na ordem de [CampoPet].
Map<CampoPet, String> validarDadosPet(DadosPet d) {
  final erros = <CampoPet, String>{};
  final nome = d.nome.trim();
  if (nome.isEmpty || nome.length > tamanhoMaximoNome) erros[CampoPet.nome] = MensagensPet.nome;
  if (d.especie == null) erros[CampoPet.especie] = MensagensPet.escolha;
  if (d.sexo == null) erros[CampoPet.sexo] = MensagensPet.escolha;

  final anos = d.anos, meses = d.meses;
  final idadeValida = anos != null &&
      meses != null &&
      anos >= 0 &&
      anos <= idadeMaximaAnos &&
      meses >= 0 &&
      meses <= 11 &&
      anos * 12 + meses >= 1;
  if (!idadeValida) erros[CampoPet.idade] = MensagensPet.idade;

  if (d.castrado == null) erros[CampoPet.castracao] = MensagensPet.escolha;
  if (d.nivelAtividade == null) erros[CampoPet.atividade] = MensagensPet.escolha;

  final peso = d.pesoInicialKg;
  if (peso == null || !peso.isFinite || peso <= 0) {
    erros[CampoPet.pesoInicial] = MensagensPet.pesoPositivo;
  } else if (peso > pesoMaximoKg) {
    erros[CampoPet.pesoInicial] = MensagensPet.pesoAcima;
  }
  return erros;
}
