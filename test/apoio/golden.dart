import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show MaterialApp;

/// Infraestrutura dos golden tests (`design-system.md` → Verificação visual).
///
/// Como usar numa tela principal (copie `test/goldens/` como exemplo):
/// ```dart
/// testWidgets('tela 01 igual ao PNG', (tester) async {
///   prepararTelaGolden(tester);
///   await tester.pumpWidget(appDeTeste(const MinhaTela()));
///   await tester.pumpAndSettle();
///   await expectLater(telaInteira, matchesGoldenFile('arquivos/01-inicio.png'));
/// });
/// ```
/// Gere ou atualize as imagens com `flutter test --update-goldens` e compare
/// lado a lado com o PNG de `docs/design/telas/` (mesma resolução: 780 px de
/// largura). Anote as diferenças que continuarem.

/// Tamanho do frame do Figma, em dp.
const tamanhoTela = Size(390, 844);

/// Os PNGs de `docs/design/telas/` foram exportados em 2x.
const densidadeGolden = 2.0;

/// Altura da barra de status no Figma: o conteúdo começa em y = 24.
const barraDeStatus = 24.0;

/// Deixa a tela de teste com 390 × 844 dp em 2x e a barra de status de 24 dp,
/// para o golden sair com 780 × 1688 px, como os PNGs.
void prepararTelaGolden(WidgetTester tester) {
  tester.view
    ..physicalSize = tamanhoTela * densidadeGolden
    ..devicePixelRatio = densidadeGolden
    ..padding = const FakeViewPadding(top: barraDeStatus * densidadeGolden);
  addTearDown(tester.view.reset);
}

/// A tela inteira, em pixels físicos (780 × 1688). Capturar um widget de
/// dentro da tela daria a imagem em 1x e sem o que estiver em volta.
Finder get telaInteira => find.byType(MaterialApp);

/// Carrega a Inter (400 e 700) dos assets do app.
Future<void> carregarFonteInter() async {
  final carregador = FontLoader('Inter')
    ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'))
    ..addFont(rootBundle.load('assets/fonts/Inter-Bold.ttf'));
  await carregador.load();
}

/// Troca o comparador padrão por um que aceita até [tolerancia] (fração dos
/// pixels) de diferença.
void usarComparadorComTolerancia({double tolerancia = 0.005}) {
  final atual = goldenFileComparator;
  if (atual is LocalFileComparator) {
    goldenFileComparator = _ComparadorComTolerancia(
      Uri.parse('${atual.basedir}arquivo_de_teste.dart'),
      tolerancia,
    );
  }
}

class _ComparadorComTolerancia extends LocalFileComparator {
  _ComparadorComTolerancia(super.testFile, this.tolerancia);

  final double tolerancia;

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final resultado = await GoldenFileComparator.compareLists(imageBytes, await getGoldenBytes(golden));
    if (resultado.passed || resultado.diffPercent <= tolerancia) {
      resultado.dispose();
      return true;
    }
    final erro = await generateFailureOutput(resultado, golden, basedir);
    resultado.dispose();
    throw FlutterError(erro);
  }
}
