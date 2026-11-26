import '../entidades/lembrete.dart';
import '../repositorios/agendador_notificacoes.dart';
import '../repositorios/lembrete_repositorio.dart';
import 'executar_agendamentos.dart';
import 'serializador_lembretes.dart';

export 'executar_agendamentos.dart' show AgendamentoPendente;

/// O banco confirma primeiro; o sistema operacional recebe o agendamento depois.
final class GerenciarLembretes {
  GerenciarLembretes(
    this._repositorio,
    this._agendador, {
    SerializadorLembretes? serializador,
  }) : _serializador = serializador ?? SerializadorLembretes();
  final SerializadorLembretes _serializador;
  final LembreteRepositorio _repositorio;
  final AgendadorNotificacoes _agendador;

  Future<Lembrete> salvar(
    Lembrete lembrete, {
    required String nomePet,
    required DateTime agora,
  }) => _serializador.executar(() async {
    validarLembrete(lembrete, await _repositorio.listar(lembrete.petId));
    final salvo = await _repositorio.salvar(lembrete, agora: agora);
    await _aplicarTodos([salvo], nomePet);
    return salvo;
  });

  Future<void> criarSugeridos(
    String petId, {
    required String nomePet,
    required DateTime agora,
  }) => _serializador.executar(() async {
    final salvos = await _repositorio.criarSugeridos(petId, agora: agora);
    await _aplicarTodos(salvos, nomePet);
  });

  Future<void> excluir(Lembrete l, {required DateTime agora}) =>
      _serializador.executar(() async {
        await _repositorio.excluir(l.petId, l.id, agora: agora);
        await executarAgendamentos([
          () => _agendador.cancelar(l.notificacaoId),
        ]);
      });

  Future<void> cancelarDoPet(String petId) => _serializador.executar(() async {
    final lembretes = await _repositorio.listar(petId, incluirExcluidos: true);
    await executarAgendamentos([
      for (final l in lembretes) () => _agendador.cancelar(l.notificacaoId),
    ]);
  });

  Future<void> reagendarPet(String petId, String nomePet) =>
      _serializador.executar(() async {
        await _aplicarTodos(await _repositorio.listar(petId), nomePet);
      });

  Future<void> _aplicarTodos(Iterable<Lembrete> lembretes, String nomePet) =>
      executarAgendamentos([
        for (final l in lembretes)
          () => l.ativo
              ? _agendador.agendarDiario(l, nomePet: nomePet)
              : _agendador.cancelar(l.notificacaoId),
      ]);
}
