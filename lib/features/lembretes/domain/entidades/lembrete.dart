/// Lembrete de um pet (`dados-e-sync.md` → tabela `lembretes`). Dart puro.
///
/// Criado pelo P1 na etapa 1, com os campos da tabela, para o card
/// "Lembretes" do Início. O P3 é o dono e completa na etapa 3.
library;

/// O `name` é o valor da coluna `lembretes.tipo`.
enum TipoLembrete { refeicao, pesagem, atividade }

final class Lembrete {
  const Lembrete({
    required this.id,
    required this.petId,
    required this.horaMinutos,
    required this.tipo,
    required this.ativo,
    required this.notificacaoId,
  });

  final String id;
  final String petId;

  /// Minutos desde 00:00 (ex.: 480 = 08:00).
  final int horaMinutos;
  final TipoLembrete tipo;
  final bool ativo;

  /// Id único e estável da notificação agendada.
  final int notificacaoId;

  @override
  bool operator ==(Object other) =>
      other is Lembrete &&
      other.id == id &&
      other.petId == petId &&
      other.horaMinutos == horaMinutos &&
      other.tipo == tipo &&
      other.ativo == ativo &&
      other.notificacaoId == notificacaoId;

  @override
  int get hashCode =>
      Object.hash(id, petId, horaMinutos, tipo, ativo, notificacaoId);
}
