import 'package:flutter_test/flutter_test.dart';

import '../apoio/golden.dart';
import '../atividades/tela_atividades_test.dart' show montarAtividades;

void main() {
  testWidgets('03 Atividades com os dados do protótipo', (tester) async {
    prepararTelaGolden(tester);
    await montarAtividades(tester);
    await expectLater(telaInteira, matchesGoldenFile('arquivos/03-atividades.png'));
  });
  testWidgets('03 Atividades com fonte em 200%', (tester) async {
    prepararTelaGolden(tester);
    await montarAtividades(tester, escala: 2);
    await expectLater(telaInteira, matchesGoldenFile('arquivos/03-atividades-fonte-200.png'));
  });
}
