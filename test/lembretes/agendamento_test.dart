import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/atividades/domain/entidades/atividade.dart';
import 'package:petamigo/features/atividades/domain/gasto_atividade.dart';
import 'package:petamigo/features/atividades/domain/sugestao_exercicios.dart';
import 'package:petamigo/features/lembretes/domain/casos_de_uso/gerenciar_lembretes.dart';
import 'package:petamigo/features/lembretes/domain/casos_de_uso/reagendar_todos.dart';
import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';
import 'package:petamigo/features/lembretes/domain/repositorios/agendador_notificacoes.dart';
import 'package:petamigo/features/lembretes/domain/repositorios/lembrete_repositorio.dart';

import '../apoio/lembretes_falsos.dart';
import '../apoio/pets_falsos.dart';

void main() {
  final hoje = DateTime(2026, 9, 30, 20);
  late LembretesFalsos repo;
  late AgendadorFalso agendador;
  late GerenciarLembretes gerenciar;
  setUp(() {
    repo = LembretesFalsos();
    agendador = AgendadorFalso();
    gerenciar = GerenciarLembretes(repo, agendador);
  });
  tearDown(() => repo.fechar());

  Lembrete alterar(Lembrete l, {bool? ativo, int? hora}) => Lembrete(
    id: l.id,
    petId: l.petId,
    horaMinutos: hora ?? l.horaMinutos,
    tipo: l.tipo,
    ativo: ativo ?? l.ativo,
    notificacaoId: l.notificacaoId,
  );

  test(
    'T3: três horários, pausa, reativação e exclusão isolada por pet',
    () async {
      await gerenciar.criarSugeridos('luna', nomePet: 'Luna', agora: hoje);
      final lembretes = await repo.listar('luna');
      expect(lembretes.map((l) => l.horaMinutos), [480, 840, 1200]);
      expect(lembretes.map((l) => l.notificacaoId).toSet(), hasLength(3));
      expect(
        agendador.agendados.values.map((l) => l.payload),
        everyElement('luna|refeicao'),
      );
      final primeiro = lembretes.first;
      await gerenciar.salvar(
        alterar(primeiro, ativo: false),
        nomePet: 'Luna',
        agora: hoje,
      );
      expect(agendador.cancelados, [primeiro.notificacaoId]);
      expect(agendador.agendados, hasLength(2));
      await gerenciar.salvar(
        alterar(primeiro, ativo: true),
        nomePet: 'Luna',
        agora: hoje,
      );
      expect(agendador.agendados, hasLength(3));
      await gerenciar.criarSugeridos('outro', nomePet: 'Toby', agora: hoje);
      expect(agendador.agendados, hasLength(6));
      for (final l in lembretes) {
        await repo.excluir('luna', l.id, agora: hoje);
      }
      await gerenciar.cancelarDoPet('luna');
      expect(
        agendador.agendados.values.map((v) => v.lembrete.petId),
        everyElement('outro'),
      );
      expect(agendador.agendados, hasLength(3));
      expect(
        agendador.cancelados.toSet(),
        containsAll(lembretes.map((l) => l.notificacaoId)),
      );
    },
  );

  test(
    'T3: ReagendarTodos é idempotente, preserva pausas e atualiza o nome',
    () async {
      await gerenciar.criarSugeridos('luna', nomePet: 'Luna', agora: hoje);
      final primeiro = (await repo.listar('luna')).first;
      await gerenciar.salvar(
        alterar(primeiro, ativo: false),
        nomePet: 'Luna',
        agora: hoje,
      );
      final reagendar = ReagendarTodos(
        agendador,
        carregar: () async => [
          for (final l in await repo.listar('luna'))
            (lembrete: l, nomePet: 'Lua'),
        ],
      );
      await reagendar();
      final antes = Map.of(agendador.agendados);
      await reagendar();
      expect(agendador.agendados, antes);
      expect(agendador.agendados, hasLength(2));
      expect(
        agendador.agendados.values.map((v) => v.nomePet),
        everyElement('Lua'),
      );
    },
  );

  test(
    'R05: duplicação inclui pausados e não confunde pets ou tipos',
    () async {
      await gerenciar.criarSugeridos('luna', nomePet: 'Luna', agora: hoje);
      final primeiro = (await repo.listar('luna')).first;
      await gerenciar.salvar(
        alterar(primeiro, ativo: false),
        nomePet: 'Luna',
        agora: hoje,
      );
      final repetido = Lembrete(
        id: 'novo',
        petId: 'luna',
        horaMinutos: 480,
        tipo: TipoLembrete.refeicao,
        ativo: true,
        notificacaoId: 0,
      );
      await expectLater(
        gerenciar.salvar(repetido, nomePet: 'Luna', agora: hoje),
        throwsA(isA<HorarioRepetido>()),
      );
      expect(agendador.agendados, hasLength(2));
    },
  );

  test(
    'T3/M4: brincadeira de 10 min = 5,166 kcal e duração zero bloqueada',
    () {
      final a = Atividade(
        id: 'a1',
        petId: 'luna',
        tipo: TipoAtividade.brincadeira,
        duracaoMin: 10,
        dataHora: hoje,
      );
      expect(gastoAtividade(a, 247.97).valorOuNulo, closeTo(5.166, .001));
      expect(
        mediaGastoAtividade([a, a, a], 247.97, hoje).valorOuNulo,
        closeTo(1.107, .001),
      );
      final invalida = Atividade(
        id: 'a2',
        petId: 'luna',
        tipo: TipoAtividade.passeio,
        duracaoMin: 0,
        dataHora: hoje,
      );
      expect(
        validarAtividade(invalida, hoje),
        contains(CampoAtividade.duracao),
      );
      expect(gastoAtividade(invalida, 247.97).disponivel, isFalse);
      expect(gastoAtividade(a, double.nan).disponivel, isFalse);
    },
  );

  test('S2: janela de sete dias, objetivo de perda e isolamento por pet', () {
    final pet = luna(id: 'luna');
    final a = Atividade(
      id: 'a1',
      petId: pet.id,
      tipo: TipoAtividade.brincadeira,
      duracaoMin: 70,
      dataHora: hoje,
    );
    final s = sugestaoExercicios(
      pet: pet,
      pesoAtualKg: 5.4,
      pesoIdealKg: 4.5,
      atividades: [a],
      hoje: hoje,
    );
    expect(
      s?.texto,
      'Mais 5 minutos de passeio ou brincadeira por dia ajudam Luna. Veja ideias em Atividades.',
    );
    expect(
      sugestaoExercicios(
        pet: pet,
        pesoAtualKg: 5.4,
        pesoIdealKg: 6,
        atividades: [],
        hoje: hoje,
      ),
      isNull,
    );
  });

  test('R14: payload inválido é ignorado e títulos não expõem valores', () {
    expect(lerPayloadLembrete('luna|atividade'), (
      petId: 'luna',
      tipo: TipoLembrete.atividade,
    ));
    for (final p in [
      null,
      '',
      '|refeicao',
      'luna|outro',
      'luna|pesagem|extra',
    ]) {
      expect(lerPayloadLembrete(p), isNull);
    }
    expect(
      tituloNotificacao(TipoLembrete.refeicao, 'Luna'),
      'Hora da refeição de Luna',
    );
  });

  test('falha no Android preserva o registro e a nova tentativa usa o mesmo id', () async {
    agendador.falhar = true;
    const l = Lembrete(id: 'novo', petId: 'luna', horaMinutos: 480,
      tipo: TipoLembrete.refeicao, ativo: true, notificacaoId: 0);
    await expectLater(gerenciar.salvar(l, nomePet: 'Luna', agora: hoje), throwsA(isA<AgendamentoPendente>()));
    final salvo = (await repo.listar('luna')).single;
    agendador.falhar = false;
    final repetido = await gerenciar.salvar(l, nomePet: 'Luna', agora: hoje);
    expect(repetido.notificacaoId, salvo.notificacaoId);
    expect(await repo.listar('luna'), hasLength(1));
    expect(agendador.agendados, hasLength(1));
  });
}
