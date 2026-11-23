// Regra de ouro 3 (`arquitetura.md`): o domínio é Dart puro e nunca importa
// Flutter, drift nem Firebase. Vale para todas as funcionalidades e para os
// tipos de domínio compartilhados em `lib/core/`.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final _proibidos = RegExp(
  r'''^\s*(import|export)\s+['"]package:(flutter|flutter_riverpod|riverpod|material_ui|cupertino_ui|drift|drift_flutter|firebase_\w+|cloud_firestore|sqlite3)[/:]''',
  multiLine: true,
);

List<File> _dart(String pasta) => Directory(pasta)
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

void main() {
  test('nenhum arquivo de features/*/domain importa Flutter, drift ou Firebase', () {
    final domains = Directory('lib/features')
        .listSync()
        .whereType<Directory>()
        .map((d) => Directory('${d.path}/domain'))
        .where((d) => d.existsSync());

    final violacoes = [
      for (final pasta in domains)
        for (final arquivo in _dart(pasta.path))
          if (_proibidos.hasMatch(arquivo.readAsStringSync())) arquivo.path,
    ];
    expect(violacoes, isEmpty);
  });

  test('tipos de domínio compartilhados em core também são Dart puro', () {
    for (final caminho in ['lib/core/resultado.dart', 'lib/core/sugestao.dart', ..._dart('lib/core/formato').map((f) => f.path)]) {
      expect(_proibidos.hasMatch(File(caminho).readAsStringSync()), isFalse, reason: caminho);
    }
  });

  test('o domínio não depende das camadas de fora (data, apresentacao)', () {
    final violacoes = [
      for (final arquivo in _dart('lib/features'))
        if (arquivo.path.replaceAll(r'\', '/').contains('/domain/') &&
            RegExp(r'''import\s+['"][^'"]*/(data|apresentacao)/''').hasMatch(arquivo.readAsStringSync()))
          arquivo.path,
    ];
    expect(violacoes, isEmpty);
  });
}
