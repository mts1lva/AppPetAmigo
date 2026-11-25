// P2-2.3 — o ambiente local de Firebase do grupo: portas, regras e scripts.
// Não sobe os emuladores (isso é manual / CI de integração).

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, Object?> firebase;

  setUpAll(() {
    firebase = jsonDecode(File('firebase.json').readAsStringSync()) as Map<String, Object?>;
  });

  test('emuladores: Auth 9099, Firestore 8080, UI 4000; sem Storage (P-23)', () {
    final emuladores = firebase['emulators']! as Map<String, Object?>;
    expect((emuladores['auth']! as Map)['port'], 9099);
    expect((emuladores['firestore']! as Map)['port'], 8080);
    expect((emuladores['ui']! as Map)['port'], 4000);
    expect(emuladores.containsKey('storage'), isFalse);
  });

  test('regras apontam para firestore.rules (as do P5)', () {
    expect((firebase['firestore']! as Map)['rules'], 'firestore.rules');
    final regras = File('firestore.rules').readAsStringSync();
    expect(regras, contains("request.auth.uid == uid"));
    expect(regras, contains('match /usuarios/{uid}/{colecao}/{docId}'));
  });

  test('scripts de emulador importam e exportam emulador-dados', () {
    final sh = File('emuladores.sh').readAsStringSync();
    final ps = File('emuladores.ps1').readAsStringSync();
    for (final s in [sh, ps]) {
      expect(s, contains('firebase emulators:start'));
      expect(s, contains('--import'));
      expect(s, contains('--export-on-exit'));
      expect(s, contains('emulador-dados'));
    }
    expect(sh, startsWith('#!/usr/bin/env bash'));
  });

  test('apoio_firebase.dart aponta para as portas locais, não para o projeto real', () {
    final apoio = File('integration_test/apoio_firebase.dart').readAsStringSync();
    expect(apoio, contains('useFirestoreEmulator'));
    expect(apoio, contains('useAuthEmulator'));
    expect(apoio, contains('10.0.2.2'));
    expect(apoio, contains('limparEmuladores'));
    expect(apoio, contains('criarUsuarioDeTeste'));
    expect(apoio, isNot(contains('firebasestorage.app')));
  });
}
