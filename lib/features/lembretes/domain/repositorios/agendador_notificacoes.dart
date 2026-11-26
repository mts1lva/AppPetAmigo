import '../entidades/lembrete.dart';

abstract interface class AgendadorNotificacoes {
  Future<void> agendarDiario(Lembrete lembrete, {required String nomePet});
  Future<void> cancelar(int notificacaoId);
  Future<void> cancelarTodos();
}

String payloadLembrete(Lembrete lembrete) =>
    '${lembrete.petId}|${lembrete.tipo.name}';

String tituloNotificacao(TipoLembrete tipo, String nomePet) => switch (tipo) {
  TipoLembrete.refeicao => 'Hora da refeição de $nomePet',
  TipoLembrete.pesagem => 'Hora de pesar $nomePet',
  TipoLembrete.atividade => 'Hora de brincar com $nomePet',
};

/// Valida payloads recebidos do sistema, inclusive de notificações antigas.
({String petId, TipoLembrete tipo})? lerPayloadLembrete(String? payload) {
  final partes = payload?.split('|');
  if (partes == null || partes.length != 2 || partes.first.isEmpty) return null;
  for (final tipo in TipoLembrete.values) {
    if (tipo.name == partes[1]) return (petId: partes[0], tipo: tipo);
  }
  return null;
}
