import '../entidades/lembrete.dart';

abstract interface class LembreteRepositorio {
  Stream<List<Lembrete>> observar(String petId);
  Future<List<Lembrete>> listar(String petId, {bool incluirExcluidos = false});
  Future<Lembrete> salvar(Lembrete lembrete, {required DateTime agora});
  Future<List<Lembrete>> criarSugeridos(
    String petId, {
    required DateTime agora,
  });
  Future<void> excluir(String petId, String id, {required DateTime agora});
}

/// R05: horários repetidos são rejeitados também com o lembrete pausado.
void validarLembrete(Lembrete lembrete, Iterable<Lembrete> existentes) {
  if (lembrete.horaMinutos < 0 || lembrete.horaMinutos >= 1440) {
    throw ArgumentError('Horário de lembrete inválido.');
  }
  if (existentes.any(
    (l) =>
        l.id != lembrete.id &&
        l.petId == lembrete.petId &&
        l.horaMinutos == lembrete.horaMinutos &&
        l.tipo == lembrete.tipo,
  )) {
    throw const HorarioRepetido();
  }
}

final class HorarioRepetido implements Exception {
  const HorarioRepetido();
  @override
  String toString() => 'Já existe um lembrete nesse horário.';
}
