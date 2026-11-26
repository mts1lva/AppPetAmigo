import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/lembretes/domain/casos_de_uso/gerenciar_lembretes.dart';
import 'package:petamigo/features/lembretes/domain/casos_de_uso/reagendar_todos.dart';

import '../apoio/lembretes_falsos.dart';

void main() {
  final hoje = DateTime(2026, 11, 26, 8);
  late LembretesFalsos repo;
  late AgendadorFalso agendador;
  late GerenciarLembretes gerenciar;
  setUp(() {
    repo = LembretesFalsos();
    agendador = AgendadorFalso();
    gerenciar = GerenciarLembretes(repo, agendador);
  });
  tearDown(() => repo.fechar());

  test(
    'falha em um horário sugerido não impede agendar os outros dois',
    () async {
      agendador.idsComFalha.add(1);
      await expectLater(
        gerenciar.criarSugeridos('luna', nomePet: 'Luna', agora: hoje),
        throwsA(isA<AgendamentoPendente>()),
      );
      expect(await repo.listar('luna'), hasLength(3));
      expect(agendador.tentativas, [1, 2, 3]);
      expect(agendador.agendados.keys, unorderedEquals([2, 3]));
    },
  );

  test(
    'reagendamento continua nos outros pets e permite recuperar a falha',
    () async {
      await repo.criarSugeridos('luna', agora: hoje);
      await repo.criarSugeridos('toby', agora: hoje);
      final reagendar = ReagendarTodos(
        agendador,
        carregar: () async => [
          for (final petId in ['luna', 'toby'])
            for (final l in await repo.listar(petId))
              (lembrete: l, nomePet: petId),
        ],
      );
      agendador.idsComFalha.add(1);
      await expectLater(reagendar(), throwsA(isA<AgendamentoPendente>()));
      expect(agendador.tentativas, [1, 2, 3, 4, 5, 6]);
      expect(agendador.agendados, hasLength(5));
      expect(
        agendador.agendados.values.where((a) => a.lembrete.petId == 'toby'),
        hasLength(3),
      );
      agendador.idsComFalha.clear();
      await reagendar();
      expect(agendador.agendados, hasLength(6));
    },
  );

  test(
    'cancelamento de um pet tenta todos os ids mesmo se um falhar',
    () async {
      await gerenciar.criarSugeridos('luna', nomePet: 'Luna', agora: hoje);
      await gerenciar.criarSugeridos('toby', nomePet: 'Toby', agora: hoje);
      agendador.idsComFalhaNoCancelamento.add(1);
      await expectLater(
        gerenciar.cancelarDoPet('luna'),
        throwsA(isA<AgendamentoPendente>()),
      );
      expect(agendador.cancelados, [1, 2, 3]);
      expect(agendador.agendados.keys, unorderedEquals([1, 4, 5, 6]));
    },
  );

  test(
    'falha na leitura não cancela os avisos que já estão no aparelho',
    () async {
      await gerenciar.criarSugeridos('luna', nomePet: 'Luna', agora: hoje);
      final reagendar = ReagendarTodos(
        agendador,
        carregar: () async => throw StateError('Falha na leitura.'),
      );
      await expectLater(reagendar(), throwsStateError);
      expect(agendador.cancelamentosTotais, 0);
      expect(agendador.agendados, hasLength(3));
    },
  );
}
