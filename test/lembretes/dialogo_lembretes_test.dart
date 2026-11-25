import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/notificacoes_providers.dart';
import 'package:petamigo/features/lembretes/apresentacao/telas/dialogo_lembretes.dart';


import '../apoio/lembretes_falsos.dart';
import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

void main() {
  late LembretesFalsos repo;
  late AgendadorFalso agendador;
  setUp(() {
    repo = LembretesFalsos();
    agendador = AgendadorFalso();
  });
  tearDown(() => repo.fechar());
  Future<void> montar(WidgetTester t, {double escala = 1}) async {
    final pets = PetsFalsos(iniciais: [(luna(), 5.4)]);
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          ...pets.overrides,
          lembreteRepositorioProvider.overrideWithValue(repo),
          agendadorNotificacoesProvider.overrideWithValue(agendador),
          permissoesLembretesProvider.overrideWith(
            (ref, petId) async => (notificacoes: true, horarioExato: false),
          ),
          pedirNotificacoesProvider.overrideWithValue(() async {}),
          agoraProvider.overrideWithValue(() => DateTime(2026, 9, 30, 8)),
        ],
        child: appDeTeste(
          Scaffold(
            body: Builder(
              builder: (context) => PaBotao.primario(
                texto: 'Abrir',
                aoTocar: () => abrirLembretes(context, petId: 'p1'),
              ),
            ),
          ),
          escalaTexto: escala,
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

  testWidgets('cria horários sugeridos e edita sem empilhar dois diálogos', (
    t,
  ) async {
    await montar(t);
    expect(find.text('Nenhum lembrete ainda.'), findsOneWidget);
    expect(
      find.text('Os avisos podem atrasar alguns minutos.'),
      findsOneWidget,
    );
    await tocar(t, 'Usar 08:00, 14:00 e 20:00');
    expect(await repo.listar('p1'), hasLength(3));
    expect(agendador.agendados, hasLength(3));
    await t.ensureVisible(find.text('08:00 • Refeição'));
    await t.tap(find.text('08:00 • Refeição'));
    await t.pumpAndSettle();
    expect(find.byType(DialogoLembrete), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    await tocar(t, 'Excluir lembrete');
    await tocar(t, 'Confirmar exclusão');
    expect(await repo.listar('p1'), hasLength(2));
    expect(agendador.agendados, hasLength(2));
    expect(find.byType(DialogoLembretes), findsOneWidget);
  });
  testWidgets(
    'horário repetido mantém o formulário com erro e fonte 200% funciona',
    (t) async {
      await repo.criarSugeridos('p1', agora: DateTime(2026, 9, 30));
      await montar(t, escala: 2);
      await tocar(t, 'Adicionar lembrete');
      await tocar(t, 'Salvar lembrete');
      expect(find.text('Já existe um lembrete nesse horário.'), findsOneWidget);
      expect(await repo.listar('p1'), hasLength(3));
      expect(t.takeException(), isNull);
    },
  );
}
