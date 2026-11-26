// Goldens das telas principais do P1 (P1-1.8), com os dados demonstrativos
// da Luna. Gerar/atualizar: `flutter test --update-goldens test/goldens`.
// Comparar lado a lado com docs/design/telas/01-inicio.png e
// 05-dados-do-pet.png; as diferenças que continuam estão em
// test/goldens/diferencas.md.

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
import 'package:petamigo/features/diario/domain/entidades/alimento.dart';
import 'package:petamigo/features/diario/domain/entidades/resumo_dia.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/inicio/apresentacao/providers/sugestoes_provider.dart';
import 'package:petamigo/features/lembretes/apresentacao/providers/lembretes_provider.dart';
import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';

import '../apoio/diario_falso.dart';
import '../apoio/golden.dart';
import '../apoio/inicio_falso.dart';
import '../apoio/pets_falsos.dart';

/// Foto demonstrativa do protótipo (`docs/design/assets/`).
final _foto = File('docs/design/assets/foto-luna.jpg').absolute.path;

/// Monta o app inteiro com a Luna do protótipo: 5,4 kg, 30/09/2026 às 09:00,
/// 108 kcal de ração e 12 de petiscos no dia, Ração habitual (360 kcal/100 g)
/// e lembretes às 08:00, 14:00 e 20:00.
Future<void> montarLuna(WidgetTester tester) async {
  prepararTelaGolden(tester);
  await carregarFotoNoCache(tester);
  final pets = PetsFalsos(iniciais: [(luna().copyWith(fotoArquivo: () => _foto), 5.4)]);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...pets.overrides,
      ...DiarioFalsos().overrides,
      agoraProvider.overrideWithValue(() => DateTime(2026, 9, 30, 9)),
      ultimaPesagemProvider.overrideWith(
        (ref, petId) => Stream.value(Pesagem(id: 'pes1', petId: petId, pesoKg: 5.4, dataHora: DateTime(2026, 9, 1))),
      ),
      resumoDiaProvider.overrideWith(
        (ref, args) => Stream.value(ResumoDia(dia: args.$2, racaoKcal: 108, extrasKcal: 12, registros: 3)),
      ),
      alimentoAtalhoProvider.overrideWith(
        (ref, petId) => Stream.value(
          Alimento(id: 'a1', petId: petId, nome: 'Ração habitual', densidadeKcalPor100g: 360, porcaoPadraoG: 37),
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

/// A foto vem de arquivo, e ler arquivo não anda no relógio falso do teste.
/// Por isso ela é decodificada antes, em tempo real, com a mesma chave que o
/// `FotoPet` usa (`Image.file` com `cacheWidth`); a tela a encontra pronta.
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

void main() {
  testWidgets('01 Início (compare com docs/design/telas/01-inicio.png)', (tester) async {
    await montarLuna(tester);

    await expectLater(telaInteira, matchesGoldenFile('arquivos/01-inicio.png'));
  });

  testWidgets('05 Dados de Luna (compare com docs/design/telas/05-dados-do-pet.png)', (tester) async {
    await montarLuna(tester);
    await tester.tap(find.widgetWithText(PaBotao, 'Editar pet'));
    await tester.pumpAndSettle();

    await expectLater(telaInteira, matchesGoldenFile('arquivos/05-dados-do-pet.png'));
  });
}
