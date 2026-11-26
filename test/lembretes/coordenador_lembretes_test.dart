import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/app.dart';
import 'package:petamigo/app/coordenador_lembretes.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/atividades/apresentacao/providers/atividades_providers.dart';
import 'package:petamigo/features/atividades/apresentacao/telas/dialogo_atividade.dart';
import 'package:petamigo/features/lembretes/data/notificacoes/central_notificacoes.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/notificacoes_providers.dart';
import 'package:petamigo/features/lembretes/apresentacao/telas/dialogo_lembretes.dart';
import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';

import '../apoio/inicio_falso.dart';
import '../apoio/pets_falsos.dart';
import '../apoio/lembretes_falsos.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_timezone'),
          (_) async => 'America/Fortaleza',
        );
    centralNotificacoes.inicializada = false;
    while (centralNotificacoes.primeiro != null) {
      centralNotificacoes.concluir();
    }
  });
  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('flutter_timezone'),
          null,
        ),
  );
  testWidgets(
    'toque recebido antes da abertura troca o pet e abre o registro de atividade',
    (t) async {
      final pets = PetsFalsos(
        iniciais: [
          (luna(id: 'p1'), 5.4),
          (luna(id: 'p2', nome: 'Lua'), 4.5),
        ],
      );
      await pets.definirId('p1');
      centralNotificacoes.receber('p2|atividade');
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            ...overridesSemBanco(pets),
            atividadesProvider.overrideWith((ref, id) => const AsyncData([])),
            dicasProvider.overrideWith((ref) async => []),
          ],
          child: const CoordenadorLembretes(child: PetAmigoApp()),
        ),
      );
      await t.pumpAndSettle();
      expect(pets.atual, 'p2');
      expect(find.byType(DialogoAtividade), findsOneWidget);
      expect(
        t.widget<DialogoAtividade>(find.byType(DialogoAtividade)).petId,
        'p2',
      );
      expect(centralNotificacoes.primeiro, isNull);
      await t.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'outro toque troca o pet mesmo com o formulário anterior aberto',
    (t) async {
      final pets = PetsFalsos(
        iniciais: [
          (luna(id: 'p1'), 5.4),
          (luna(id: 'p2', nome: 'Lua'), 4.5),
        ],
      );
      await pets.definirId('p1');
      centralNotificacoes.receber('p1|atividade');
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            ...overridesSemBanco(pets),
            atividadesProvider.overrideWith((ref, id) => const AsyncData([])),
            dicasProvider.overrideWith((ref) async => []),
          ],
          child: const CoordenadorLembretes(child: PetAmigoApp()),
        ),
      );
      await t.pumpAndSettle();
      expect(
        t.widget<DialogoAtividade>(find.byType(DialogoAtividade)).petId,
        'p1',
      );
      centralNotificacoes.receber('p2|atividade');
      await t.pumpAndSettle();
      expect(pets.atual, 'p2');
      expect(find.byType(DialogoAtividade), findsOneWidget);
      expect(
        t.widget<DialogoAtividade>(find.byType(DialogoAtividade)).petId,
        'p2',
      );
      await t.pumpWidget(const SizedBox());
    },
  );
  testWidgets('notificação de outro pet não reabre a configuração anterior', (
    t,
  ) async {
    final pets = PetsFalsos(
      iniciais: [
        (luna(id: 'p1'), 5.4),
        (luna(id: 'p2', nome: 'Lua'), 4.5),
      ],
    );
    final lembretes = LembretesFalsos();
    addTearDown(lembretes.fechar);
    await pets.definirId('p1');
    await t.pumpWidget(
      ProviderScope(
        overrides: [
          ...overridesSemBanco(pets),
          atividadesProvider.overrideWith((ref, id) => const AsyncData([])),
          dicasProvider.overrideWith((ref) async => []),
          lembreteRepositorioProvider.overrideWithValue(lembretes),
          permissoesLembretesProvider.overrideWith(
            (ref, id) async => (notificacoes: true, horarioExato: true),
          ),
        ],
        child: const CoordenadorLembretes(child: PetAmigoApp()),
      ),
    );
    await t.pumpAndSettle();
    final configurar = find.widgetWithText(PaBotao, 'Configurar lembretes');
    await t.ensureVisible(configurar);
    await t.tap(configurar);
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(PaBotao, 'Adicionar lembrete'));
    await t.pumpAndSettle();
    expect(find.byType(DialogoLembrete), findsOneWidget);
    centralNotificacoes.receber('p2|atividade');
    await t.pumpAndSettle();
    expect(pets.atual, 'p2');
    expect(find.byType(DialogoLembretes), findsNothing);
    expect(find.byType(DialogoLembrete), findsNothing);
    expect(find.byType(DialogoAtividade), findsOneWidget);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets(
    'falha ao abrir formulário conserva o destino sem erro assíncrono solto',
    (t) async {
      final pets = PetsFalsos(iniciais: [(luna(), 5.4)]);
      centralNotificacoes.receber('p1|atividade');
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            ...overridesSemBanco(pets),
            atividadesProvider.overrideWith((ref, id) => const AsyncData([])),
            dicasProvider.overrideWith((ref) async => []),
            abridoresLembreteProvider.overrideWithValue({
              TipoLembrete.atividade: (context, id) async =>
                  throw StateError('Falha no formulário.'),
            }),
          ],
          child: const CoordenadorLembretes(child: PetAmigoApp()),
        ),
      );
      await t.pumpAndSettle();
      final c = ProviderScope.containerOf(t.element(find.byType(PetAmigoApp)));
      expect(c.read(registroLembretePendenteProvider), (
        petId: 'p1',
        tipo: TipoLembrete.atividade,
      ));
      expect(t.takeException(), isNull);
      await t.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'destino do pacote seguinte conserva pet e tipo sem criar formulário fictício',
    (t) async {
      final pets = PetsFalsos(iniciais: [(luna(), 5.4)]);
      centralNotificacoes.receber('p1|pesagem');
      await t.pumpWidget(
        ProviderScope(
          overrides: [...overridesSemBanco(pets)],
          child: const CoordenadorLembretes(child: PetAmigoApp()),
        ),
      );
      await t.pumpAndSettle();
      final c = ProviderScope.containerOf(t.element(find.byType(PetAmigoApp)));
      expect(c.read(registroLembretePendenteProvider), (
        petId: 'p1',
        tipo: TipoLembrete.pesagem,
      ));
      expect(find.text('Evolução'), findsWidgets);
      await t.pumpWidget(const SizedBox());
    },
  );
}
