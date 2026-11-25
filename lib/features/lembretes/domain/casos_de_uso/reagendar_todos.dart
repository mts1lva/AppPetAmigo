import '../entidades/lembrete.dart';
import '../repositorios/agendador_notificacoes.dart';
import 'serializador_lembretes.dart';

typedef LembreteDoPet = ({Lembrete lembrete, String nomePet});

/// Carrega todos os pets, não apenas o atual. Disponível para a restauração do P5.
final class ReagendarTodos {
  ReagendarTodos(
    this._agendador, {
    required this.carregar,
    SerializadorLembretes? serializador,
  }) : _serializador = serializador ?? SerializadorLembretes();
  final SerializadorLembretes _serializador;
  final AgendadorNotificacoes _agendador;
  final Future<List<LembreteDoPet>> Function() carregar;

  Future<void> call() => _serializador.executar(() async {
    // Não cancela alarmes válidos se a leitura do banco falhar.
    final lembretes = await carregar();
    await _agendador.cancelarTodos();
    for (final item in lembretes) {
      if (item.lembrete.ativo) {
        await _agendador.agendarDiario(item.lembrete, nomePet: item.nomePet);
      }
    }
  });
}
