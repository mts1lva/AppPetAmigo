import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/atividades/apresentacao/providers/atividades_providers.dart';
import 'package:petamigo/features/atividades/apresentacao/telas/dialogo_atividade.dart';
import 'package:petamigo/features/atividades/domain/entidades/atividade.dart';
import 'package:petamigo/features/atividades/domain/repositorios/atividade_repositorio.dart';

import '../apoio/montar.dart';

final class AtividadesFalsas implements AtividadeRepositorio {
  final salvas = <Atividade>[];
  final excluidas = <(String, String)>[];
  bool falhar = false;
  @override
  Stream<List<Atividade>> observar(
    String petId, {
    required DateTime inicio,
    required DateTime fim,
  }) => Stream.value(
    salvas
        .where(
          (a) =>
              a.petId == petId &&
              !a.dataHora.isBefore(inicio) &&
              a.dataHora.isBefore(fim),
        )
        .toList(),
  );
  @override
  Future<void> salvar(Atividade a, {required DateTime agora}) async {
    if (falhar) throw StateError('falha simulada');
    salvas.add(a);
  }

  @override
  Future<void> excluir(
    String petId,
    String id, {
    required DateTime agora,
  }) async {
    excluidas.add((petId, id));
  }
}

void main() {
  final agora = DateTime(2026, 9, 30, 18);
  Future<void> montar(
    WidgetTester t,
    AtividadesFalsas repo, {
    Atividade? atividade,
  }) async {
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          atividadeRepositorioProvider.overrideWithValue(repo),
          agoraProvider.overrideWithValue(() => agora),
        ],
        child: appDeTeste(
          Scaffold(
            body: Builder(
              builder: (c) => PaBotao.primario(
                texto: 'Abrir',
                aoTocar: () =>
                    abrirAtividade(c, petId: 'p1', atividade: atividade),
              ),
            ),
          ),
        ),
      ),
    );
    await t.tap(find.text('Abrir'));
    await t.pumpAndSettle();
  }

  Future<void> tocar(WidgetTester t, String texto) async {
    await t.ensureVisible(find.widgetWithText(PaBotao, texto));
    await t.tap(find.widgetWithText(PaBotao, texto));
    await t.pumpAndSettle();
  }

  testWidgets(
    'R05: duração inválida mantém o formulário aberto; grava somente depois de corrigir',
    (t) async {
      final repo = AtividadesFalsas();
      await montar(t, repo);
      await tocar(t, 'Salvar atividade');
      expect(find.text('Informe a duração em minutos.'), findsOneWidget);
      expect(repo.salvas, isEmpty);
      await t.enterText(find.byType(TextField), '10');
      await tocar(t, 'Salvar atividade');
      expect(repo.salvas.single.petId, 'p1');
      expect(repo.salvas.single.duracaoMin, 10);
      expect(find.byType(DialogoAtividade), findsNothing);
    },
  );
  testWidgets('falha ao salvar mantém os dados e permite tentar novamente', (
    t,
  ) async {
    final repo = AtividadesFalsas()..falhar = true;
    await montar(t, repo);
    await t.enterText(find.byType(TextField), '20');
    await tocar(t, 'Salvar atividade');
    expect(
      find.text('Não foi possível salvar. Tente novamente.'),
      findsOneWidget,
    );
    expect(find.byType(DialogoAtividade), findsOneWidget);
    repo.falhar = false;
    await tocar(t, 'Salvar atividade');
    expect(repo.salvas.single.duracaoMin, 20);
  });
  testWidgets(
    'exclusão cancelada preserva; confirmada exclui somente o pet do formulário',
    (t) async {
      final repo = AtividadesFalsas();
      final a = Atividade(
        id: 'a1',
        petId: 'p1',
        tipo: TipoAtividade.brincadeira,
        duracaoMin: 10,
        dataHora: agora,
      );
      await montar(t, repo, atividade: a);
      await tocar(t, 'Excluir registro');
      await tocar(t, 'Cancelar');
      expect(repo.excluidas, isEmpty);
      await tocar(t, 'Excluir registro');
      await tocar(t, 'Confirmar exclusão');
      expect(repo.excluidas, [('p1', 'a1')]);
      expect(find.byType(DialogoAtividade), findsNothing);
    },
  );
}
