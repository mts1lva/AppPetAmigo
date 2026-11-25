import 'dart:async';

import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';
import 'package:petamigo/features/lembretes/domain/repositorios/agendador_notificacoes.dart';
import 'package:petamigo/features/lembretes/domain/repositorios/lembrete_repositorio.dart';

final class AgendadorFalso implements AgendadorNotificacoes {
  final agendados =
      <int, ({Lembrete lembrete, String nomePet, String payload})>{};
  final cancelados = <int>[];
  var cancelamentosTotais = 0;

  @override
  Future<void> agendarDiario(Lembrete l, {required String nomePet}) async {
    agendados[l.notificacaoId] = (
      lembrete: l,
      nomePet: nomePet,
      payload: payloadLembrete(l),
    );
  }

  @override
  Future<void> cancelar(int id) async {
    cancelados.add(id);
    agendados.remove(id);
  }

  @override
  Future<void> cancelarTodos() async {
    cancelamentosTotais++;
    agendados.clear();
  }
}

final class LembretesFalsos implements LembreteRepositorio {
  final registros = <String, Lembrete>{};
  final excluidos = <String>{};
  final _mudancas = StreamController<void>.broadcast();
  var _sequencia = 0;

  Future<void> fechar() => _mudancas.close();
  @override
  Future<List<Lembrete>> listar(
    String petId, {
    bool incluirExcluidos = false,
  }) async =>
      registros.values
          .where(
            (l) =>
                l.petId == petId &&
                (incluirExcluidos || !excluidos.contains(l.id)),
          )
          .toList()
        ..sort((a, b) => a.horaMinutos.compareTo(b.horaMinutos));

  @override
  Stream<List<Lembrete>> observar(String petId) => Stream.multi((s) {
    Future<void> emitir() async {
      s.add(await listar(petId));
    }

    emitir();
    final assinatura = _mudancas.stream.listen((_) => emitir());
    s.onCancel = assinatura.cancel;
  });
  @override
  Future<Lembrete> salvar(Lembrete l, {required DateTime agora}) async {
    validarLembrete(l, await listar(l.petId));
    final salvo = Lembrete(
      id: l.id,
      petId: l.petId,
      horaMinutos: l.horaMinutos,
      tipo: l.tipo,
      ativo: l.ativo,
      notificacaoId: registros[l.id]?.notificacaoId ?? ++_sequencia,
    );
    registros[l.id] = salvo;
    _mudancas.add(null);
    return salvo;
  }

  @override
  Future<List<Lembrete>> criarSugeridos(
    String petId, {
    required DateTime agora,
  }) async {
    final lista = <Lembrete>[];
    for (final hora in [480, 840, 1200]) {
      lista.add(
        await salvar(
          Lembrete(
            id: '$petId-$hora',
            petId: petId,
            horaMinutos: hora,
            tipo: TipoLembrete.refeicao,
            ativo: true,
            notificacaoId: 0,
          ),
          agora: agora,
        ),
      );
    }
    return lista;
  }

  @override
  Future<void> excluir(
    String petId,
    String id, {
    required DateTime agora,
  }) async {
    if (registros[id]?.petId != petId) return;
    excluidos.add(id);
    _mudancas.add(null);
  }
}
