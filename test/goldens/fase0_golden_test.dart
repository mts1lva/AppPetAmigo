// Exemplo de golden test para os colegas copiarem (P1-0.5).
//
// Gerar/atualizar as imagens: `flutter test --update-goldens test/goldens`.
// Depois, abrir `test/goldens/arquivos/*.png` lado a lado com o PNG de
// `docs/design/telas/` (mesmo tamanho: 780 × 1688 px) e anotar as diferenças
// que continuarem.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/app/app.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pet_atual_provider.dart';
import 'package:petamigo/features/pets/apresentacao/telas/tela_vamos_comecar.dart';

import '../apoio/golden.dart';
import '../apoio/inicio_falso.dart';
import '../apoio/montar.dart';

void main() {
  testWidgets('26 Vamos começar? (compare com docs/design/telas/26-vamos-comecar.png)', (tester) async {
    prepararTelaGolden(tester);
    await tester.pumpWidget(appDeTeste(TelaVamosComecar(aoCadastrar: () {})));
    await tester.pumpAndSettle();

    // Diferença esperada (Unidade II): subtítulo "Cadastre seu cão ou gato."
    await expectLater(telaInteira, matchesGoldenFile('arquivos/26-vamos-comecar.png'));
  });

  // A aba Início já é a tela real (golden próprio na P1-1.8); este exemplo
  // mostra uma aba ainda provisória com a navegação inferior.
  testWidgets('Fase 0: aba provisória (Diário) com a navegação inferior', (tester) async {
    prepararTelaGolden(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [petAtualIdProvider.overrideWith((ref) => Stream.value('pet-demo')), ...overridesSemBanco()],
        child: const PetAmigoApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byType(PaNavegacao), matching: find.text('Diário')));
    await tester.pumpAndSettle();

    await expectLater(telaInteira, matchesGoldenFile('arquivos/fase0-abas.png'));
  });
}
