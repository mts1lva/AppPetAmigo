// O app aberto de um dia para o outro: o "hoje" anda sozinho (diaAtualProvider)
// e a janela de 14 dias da aderência e da S1 passa a incluir o dia novo.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/features/diario/apresentacao/providers/resumo_dia_provider.dart';

import '../apoio/diario_falso.dart';

/// Deixa os streams falsos (que emitem depois de um `Duration.zero`) e o
/// Riverpod entregarem o valor.
Future<void> assentar(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 1));
  }
}

void main() {
  testWidgets('diaAtualProvider muda sozinho na virada do dia', (tester) async {
    var agora = DateTime(2026, 9, 30, 23, 59, 30);
    final c = ProviderContainer(overrides: [agoraProvider.overrideWithValue(() => agora)]);
    final sub = c.listen(diaAtualProvider, (_, _) {});

    expect(c.read(diaAtualProvider), DateTime(2026, 9, 30));
    agora = DateTime(2026, 10, 1, 0, 0, 30);
    await tester.pump(DiaAtual.intervalo);
    expect(c.read(diaAtualProvider), DateTime(2026, 10, 1));

    sub.close();
    c.dispose();
  });

  testWidgets('a janela de 14 dias anda junto e conta a refeição do dia novo', (tester) async {
    var agora = DateTime(2026, 9, 30, 23, 59, 30);
    final diario = DiarioFalsos(refeicoes: [refeicaoHabitual(quando: DateTime(2026, 10, 1, 0, 0, 10))]);
    final c = ProviderContainer(overrides: [
      ...diario.overrides,
      agoraProvider.overrideWithValue(() => agora),
    ]);
    final sub = c.listen(resumosJanelaProvider('p1'), (_, _) {});
    await assentar(tester);

    var dias = c.read(resumosJanelaProvider('p1')).value!;
    expect((dias.first.dia, dias.last.dia), (DateTime(2026, 9, 17), DateTime(2026, 9, 30)));
    expect(dias.any((d) => d.temRegistros), isFalse);

    agora = DateTime(2026, 10, 1, 0, 0, 30);
    await tester.pump(DiaAtual.intervalo);
    await assentar(tester);

    dias = c.read(resumosJanelaProvider('p1')).value!;
    expect(dias, hasLength(14));
    expect((dias.first.dia, dias.last.dia), (DateTime(2026, 9, 18), DateTime(2026, 10, 1)));
    expect(dias.last.totalKcal, 108);

    sub.close();
    c.dispose();
  });
}
