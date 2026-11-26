// Goldens da tela 04 Evolução (P4-1.7) com 0, 1 e 3 pesagens da Luna.
// Gerar/atualizar: `flutter test --update-goldens test/goldens`.
// Comparar lado a lado com docs/design/telas/04-evolucao.png; as diferenças
// que continuam estão em test/goldens/diferencas.md.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petamigo/app/tema/cores.dart';
import 'package:petamigo/core/ui/ui.dart';
import 'package:petamigo/features/evolucao/apresentacao/telas/tela_evolucao.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/pets/apresentacao/providers/pet_atual_provider.dart';

import '../apoio/evolucao_falsa.dart';
import '../apoio/golden.dart';
import '../apoio/montar.dart';

final hoje = DateTime(2026, 9, 30, 9);

Pesagem pesagem(String id, double kg, DateTime data) => Pesagem(id: id, petId: 'p1', pesoKg: kg, dataHora: data);

/// 5,6 (16/09), 5,5 (23/09), 5,4 (30/09), como no protótipo, sem ECC nem
/// objetivo (o PNG mostra "objetivo não informado").
final pesagensLuna = [
  pesagem('w1', 5.6, DateTime(2026, 9, 16, 8)),
  pesagem('w2', 5.5, DateTime(2026, 9, 23, 8)),
  pesagem('w3', 5.4, DateTime(2026, 9, 30, 8)),
];

/// A aba Evolução como no app: a tela e a navegação inferior fixa.
Future<void> montarEvolucao(WidgetTester tester, List<Pesagem> pesagens) async {
  prepararTelaGolden(tester);
  await tester.pumpWidget(ProviderScope(
    overrides: [
      ...EvolucaoFalsa(pesagens: pesagens, agora: hoje).overrides,
      petAtualIdProvider.overrideWith((ref) => Stream.value('p1')),
    ],
    child: appDeTeste(Scaffold(
      backgroundColor: PaCores.fundo,
      body: const TelaEvolucao(),
      bottomNavigationBar: PaNavegacao(indiceAtual: 3, aoSelecionar: (_) {}),
    )),
  ));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('04 Evolução com 3 pesagens (compare com docs/design/telas/04-evolucao.png)', (tester) async {
    await montarEvolucao(tester, pesagensLuna);
    await expectLater(telaInteira, matchesGoldenFile('arquivos/04-evolucao.png'));
  });

  testWidgets('04 Evolução com 1 pesagem: só o ponto', (tester) async {
    await montarEvolucao(tester, [pesagensLuna.last]);
    await expectLater(telaInteira, matchesGoldenFile('arquivos/04-evolucao-1-pesagem.png'));
  });

  testWidgets('04 Evolução sem pesagens: estado vazio (M10)', (tester) async {
    await montarEvolucao(tester, const []);
    await expectLater(telaInteira, matchesGoldenFile('arquivos/04-evolucao-vazia.png'));
  });
}
