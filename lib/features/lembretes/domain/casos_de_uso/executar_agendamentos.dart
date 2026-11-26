/// Tenta todos os avisos antes de informar uma falha. Um erro do Android
/// não pode impedir os horários seguintes nem os lembretes de outro pet.
Future<void> executarAgendamentos(
  Iterable<Future<void> Function()> operacoes,
) async {
  var pendente = false;
  for (final operacao in operacoes) {
    try {
      await operacao();
    } catch (_) {
      pendente = true;
    }
  }
  if (pendente) throw const AgendamentoPendente();
}

/// O banco continua íntegro; uma nova tentativa deve usar os mesmos ids.
final class AgendamentoPendente implements Exception {
  const AgendamentoPendente();
}
