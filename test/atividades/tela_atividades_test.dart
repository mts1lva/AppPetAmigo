import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/atividades/apresentacao/providers/atividades_providers.dart';
import 'package:petamigo/features/atividades/apresentacao/telas/tela_atividades.dart';
import 'package:petamigo/features/atividades/domain/entidades/atividade.dart';
import 'package:petamigo/features/atividades/domain/entidades/dica.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pets_providers.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

Future<void> montarAtividades(
  WidgetTester t, {
  double escala = 1,
  List<Atividade>? atividades,
}) async {
  final pet = luna();
  await t.pumpWidget(
    ProviderScope(
      overrides: [
        petAtualProvider.overrideWithValue(pet),
        agoraProvider.overrideWithValue(() => DateTime(2026, 9, 30, 20)),
        atividadesProvider.overrideWith(
          (ref, petId) => AsyncData(
            atividades ??
                [
                  Atividade(
                    id: 'a1',
                    petId: 'p1',
                    tipo: TipoAtividade.brincadeira,
                    duracaoMin: 10,
                    dataHora: DateTime(2026, 9, 30, 18),
                  ),
                ],
          ),
        ),
        dicasProvider.overrideWith(
          (ref) async => [
            Dica(
              id: 'd1',
              especie: Especie.gato,
              texto: 'Reserve um momento de brincadeira.',
              fonte: 'pesquisa do projeto',
              revisadoEm: DateTime(2026, 9),
              emRevisao: true,
            ),
          ],
        ),
      ],
      child: appDeTeste(
        Scaffold(
          body: const TelaAtividades(),
          bottomNavigationBar: PaNavegacao(
            indiceAtual: 2,
            aoSelecionar: (_) {},
          ),
        ),
        escalaTexto: escala,
      ),
    ),
  );
  await t.pumpAndSettle();
}

void main() {
  testWidgets('hoje, anteriores e estado vazio respeitam a janela e o pet', (
    t,
  ) async {
    await montarAtividades(
      t,
      atividades: [
        Atividade(
          id: 'antiga',
          petId: 'p1',
          tipo: TipoAtividade.passeio,
          duracaoMin: 11,
          dataHora: DateTime(2026, 9, 29, 18),
        ),
        Atividade(
          id: 'fora',
          petId: 'p1',
          tipo: TipoAtividade.passeio,
          duracaoMin: 12,
          dataHora: DateTime(2026, 9, 1, 18),
        ),
        Atividade(
          id: 'outro',
          petId: 'p2',
          tipo: TipoAtividade.passeio,
          duracaoMin: 13,
          dataHora: DateTime(2026, 9, 30, 18),
        ),
      ],
    );
    expect(find.text('Nenhuma atividade hoje.'), findsOneWidget);
    expect(find.text('Anteriores'), findsOneWidget);
    expect(find.textContaining('11 min'), findsOneWidget);
    expect(find.textContaining('12 min'), findsNothing);
    expect(find.textContaining('13 min'), findsNothing);
    expect(find.text('Editar atividade'), findsNothing);
  });
  testWidgets(
    'fonte 200% mantém conteúdo rolável e os quatro destinos acessíveis',
    (t) async {
      t.view.physicalSize = const Size(780, 1688);
      t.view.devicePixelRatio = 2;
      addTearDown(t.view.reset);
      await montarAtividades(t, escala: 2);
      await t.ensureVisible(find.text('Registrar atividade'));
      expect(t.takeException(), isNull);
      expect(find.text('Evolução'), findsOneWidget);
    },
  );
}
