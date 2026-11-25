import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/app.dart';
import 'package:petamigo/app/coordenador_lembretes.dart';
import 'package:petamigo/features/atividades/apresentacao/providers/atividades_providers.dart';
import 'package:petamigo/features/atividades/apresentacao/telas/dialogo_atividade.dart';
import 'package:petamigo/features/lembretes/data/notificacoes/central_notificacoes.dart';
import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';

import '../apoio/inicio_falso.dart';
import '../apoio/pets_falsos.dart';

void main() {
  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter_timezone'), (_) async => 'America/Fortaleza');
    centralNotificacoes.inicializada = false;
    while (centralNotificacoes.primeiro != null) {
      centralNotificacoes.concluir();
    }
  });
  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
    const MethodChannel('flutter_timezone'), null));
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
