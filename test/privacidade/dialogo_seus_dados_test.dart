import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/inicio/apresentacao/providers/sugestoes_provider.dart';
import 'package:petamigo/features/inicio/apresentacao/telas/tela_inicio.dart';
import 'package:petamigo/features/privacidade/apresentacao/telas/dialogo_seus_dados.dart';

import '../apoio/inicio_falso.dart';
import '../apoio/montar.dart';
import '../apoio/pets_falsos.dart';

void main() {
  testWidgets('"Privacidade e cópia remota" abre a tela 14 com os dados do pet atual e "Voltar" fecha', (tester) async {
    tester.view
      ..physicalSize = const Size(390, 2400)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final pets = PetsFalsos(iniciais: [(luna(), 5.4)]);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...pets.overrides,
          agoraProvider.overrideWithValue(() => DateTime(2026, 9, 30, 9)),
          ultimaPesagemProvider.overrideWith((ref, petId) => Stream.value(null)),
          sugestoesAdiadasRepositorioProvider.overrideWithValue(AdiadasFalsas()),
        ],
        child: appDeTeste(const Scaffold(body: TelaInicio())),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(PaBotao, 'Privacidade e cópia remota'));
    await tester.pumpAndSettle();

    expect(find.byType(DialogoSeusDados), findsOneWidget);
    expect(find.text('Seus dados'), findsOneWidget);
    expect(find.text('O uso essencial funciona sem conta.'), findsOneWidget);
    expect(
      tester.widget<PaDialogo>(find.byType(PaDialogo)).texto,
      'Perfil, foto e registros servem ao acompanhamento de Luna. '
      'Ficam neste aparelho. Você controla a exportação e a exclusão. '
      'Cópia remota é opcional.',
    );

    expect(
      tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Cópia remota opcional')).variante,
      PaBotaoVariante.primario,
    );
    expect(
      tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Exportar dados')).variante,
      PaBotaoVariante.primario,
    );
    expect(
      tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Excluir todos os dados')).variante,
      PaBotaoVariante.perigo,
    );
    expect(
      tester.widget<PaBotao>(find.widgetWithText(PaBotao, 'Voltar')).variante,
      PaBotaoVariante.secundario,
    );

    await tester.tap(find.widgetWithText(PaBotao, 'Voltar'));
    await tester.pumpAndSettle();
    expect(find.byType(DialogoSeusDados), findsNothing);
  });
}
