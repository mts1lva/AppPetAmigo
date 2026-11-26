// Goldens do Diário e do atalho (P2-1.7). Gerar: `flutter test --update-goldens test/goldens/telas_p2_golden_test.dart`.
// Compare com docs/design/telas/02-diario.png e 06-registrar-refeicao.png.

import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/app.dart';
import 'package:petamigo/app/tema/espacos.dart';
import 'package:petamigo/core/relogio.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/diario/apresentacao/providers/alimento_atalho_provider.dart';
import 'package:petamigo/features/diario/apresentacao/providers/resumo_dia_provider.dart';
import 'package:petamigo/features/diario/apresentacao/telas/dialogo_atalho.dart';
import 'package:petamigo/features/diario/domain/entidades/alimento.dart';
import 'package:petamigo/features/diario/domain/entidades/resumo_dia.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/inicio/apresentacao/providers/sugestoes_provider.dart';
import 'package:petamigo/features/inicio/apresentacao/telas/tela_inicio.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/lembretes_provider.dart';
import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';

import '../apoio/diario_falso.dart';
import '../apoio/golden.dart';
import '../apoio/inicio_falso.dart';
import '../apoio/pets_falsos.dart';

final _foto = File('docs/design/assets/foto-luna.jpg').absolute.path;

Future<void> carregarFotoNoCache(WidgetTester tester) async {
  await tester.runAsync(() async {
    final imagem = ResizeImage.resizeIfNeeded((PaMedida.fotoPet * 3).round(), null, FileImage(File(_foto)));
    final pronta = Completer<void>();
    final fluxo = imagem.resolve(ImageConfiguration.empty);
    late final ImageStreamListener ouvinte;
    ouvinte = ImageStreamListener(
      (_, _) {
        fluxo.removeListener(ouvinte);
        pronta.complete();
      },
      onError: (erro, pilha) => pronta.completeError(erro, pilha),
    );
    fluxo.addListener(ouvinte);
    await pronta.future;
  });
}

Future<void> montarLuna(WidgetTester tester) async {
  prepararTelaGolden(tester);
  await carregarFotoNoCache(tester);
  final pets = PetsFalsos(iniciais: [(luna().copyWith(fotoArquivo: () => _foto), 5.4)]);
  final diario = DiarioFalsos(
    alimentos: [racaoHabitual()],
    refeicoes: [refeicaoHabitual()],
    extras: [extraHabitual()],
  );
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...pets.overrides,
      ...diario.overrides,
      agoraProvider.overrideWithValue(() => DateTime(2026, 9, 30, 9)),
      ultimaPesagemProvider.overrideWith(
        (ref, petId) => Stream.value(Pesagem(id: 'pes1', petId: petId, pesoKg: 5.4, dataHora: DateTime(2026, 9, 1))),
      ),
      resumoDiaProvider.overrideWith(
        (ref, args) => Stream.value(ResumoDia(dia: args.$2, racaoKcal: 108, extrasKcal: 12, registros: 3)),
      ),
      alimentoAtalhoProvider.overrideWith(
        (ref, petId) => Stream.value(
          Alimento(id: 'a1', petId: petId, nome: 'Ração habitual', densidadeKcalPor100g: 360, porcaoPadraoG: 30),
        ),
      ),
      lembretesProvider.overrideWith(
        (ref, petId) => Stream.value([
          for (final (i, minutos) in [480, 840, 1200].indexed)
            Lembrete(id: 'l$i', petId: petId, horaMinutos: minutos, tipo: TipoLembrete.refeicao, ativo: true, notificacaoId: i),
        ]),
      ),
      sugestoesAdiadasRepositorioProvider.overrideWithValue(AdiadasFalsas()),
    ],
    child: const PetAmigoApp(),
  ));
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(() => usarComparadorComTolerancia(tolerancia: 0.03));

  testWidgets('02 Diário (compare com docs/design/telas/02-diario.png)', (tester) async {
    await montarLuna(tester);
    await tester.tap(find.descendant(of: find.byType(PaNavegacao), matching: find.text('Diário')));
    await tester.pumpAndSettle();
    await expectLater(telaInteira, matchesGoldenFile('arquivos/02-diario.png'));
  });

  testWidgets('06 Registrar refeição (compare com docs/design/telas/06-registrar-refeicao.png)', (tester) async {
    await montarLuna(tester);
    final contexto = tester.element(find.byType(TelaInicio));
    abrirAtalho(contexto, petId: 'p1');
    await tester.pumpAndSettle();
    await expectLater(telaInteira, matchesGoldenFile('arquivos/06-registrar-refeicao.png'));
  });
}
