/// R05 para os formulários da Evolução (telas 11 e 12). Dart puro.
library;

import '../../pets/domain/entidades/dados_pet.dart' show MensagensPet, pesoMaximoKg;

/// Campos da tela 11, na ordem da tela (o foco vai ao primeiro com erro).
enum CampoPesagem { peso, data, horario }

/// Campos da tela 12, na ordem da tela.
enum CampoReferencia { ecc, objetivo, origem, data }

/// Mensagens de R05 (`comum/regras.md`).
abstract final class MensagensEvolucao {
  static const pesoPositivo = MensagensPet.pesoPositivo;
  static const pesoAcima = MensagensPet.pesoAcima;
  static const dataFutura = 'Escolha uma data até hoje.';
}

/// R05 — Peso `> 0` e `≤ 150 kg`; data e hora não podem ser futuras. A hora
/// futura de hoje marca o campo Horário.
Map<CampoPesagem, String> validarPesagem({
  required double? pesoKg,
  required DateTime dataHora,
  required DateTime agora,
}) {
  final erros = <CampoPesagem, String>{};
  if (pesoKg == null || !pesoKg.isFinite || pesoKg <= 0) {
    erros[CampoPesagem.peso] = MensagensEvolucao.pesoPositivo;
  } else if (pesoKg > pesoMaximoKg) {
    erros[CampoPesagem.peso] = MensagensEvolucao.pesoAcima;
  }
  if (dataHora.isAfter(agora)) {
    final mesmoDia = dataHora.year == agora.year && dataHora.month == agora.month && dataHora.day == agora.day;
    erros[mesmoDia ? CampoPesagem.horario : CampoPesagem.data] = MensagensEvolucao.dataFutura;
  }
  return erros;
}

/// R05 — Objetivo vazio ou `> 0` e `≤ 150`, com uma só mensagem; a data não
/// pode ser futura. [objetivoTexto] vazio é "não informado"; texto que não
/// é número ([objetivoKg] nulo) é erro.
Map<CampoReferencia, String> validarReferencia({
  required String objetivoTexto,
  required double? objetivoKg,
  required DateTime data,
  required DateTime agora,
}) {
  final erros = <CampoReferencia, String>{};
  if (objetivoTexto.trim().isNotEmpty) {
    final kg = objetivoKg;
    if (kg == null || !kg.isFinite || kg <= 0 || kg > pesoMaximoKg) {
      erros[CampoReferencia.objetivo] = MensagensEvolucao.pesoPositivo;
    }
  }
  if (data.isAfter(agora)) erros[CampoReferencia.data] = MensagensEvolucao.dataFutura;
  return erros;
}
