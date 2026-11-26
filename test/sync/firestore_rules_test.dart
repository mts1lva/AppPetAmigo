import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('firestore.rules existe e restringe acesso a usuarios/{uid}/{colecao}/{docId}', () {
    final arquivo = File('firestore.rules');
    expect(arquivo.existsSync(), isTrue);

    final conteudo = arquivo.readAsStringSync();
    expect(conteudo, contains("rules_version = '2';"));
    expect(conteudo, contains('match /usuarios/{uid}/{colecao}/{docId}'));
    expect(conteudo, contains('request.auth != null && request.auth.uid == uid'));
    expect(conteudo, isNot(contains('if true')));
  });
}
