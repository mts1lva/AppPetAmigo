// P5-3.6 (parcial) — testa as regras de segurança (`firestore.rules`) no
// Firebase Emulator Suite: usuário A lê e grava apenas os próprios documentos;
// usuário B não lê nem grava os dados de A; acesso sem login é recusado.
//
// Roda na CI e localmente via:
//   firebase emulators:exec --only auth,firestore --project pet-amigo-bac9e \
//     "flutter test integration_test/firestore_rules_test.dart"

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:petamigo/firebase_options.dart';

import 'apoio_firebase.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
    }
    await usarEmuladores();
  });

  setUp(() async {
    await FirebaseAuth.instance.signOut();
    await limparEmuladores();
  });

  test('usuário A lê e grava os próprios dados; usuário B é bloqueado em usuarios/{uidA}', () async {
    final db = FirebaseFirestore.instance;

    // Usuário A cria e lê um pet e uma foto próprios.
    final usuarioA = await criarUsuarioDeTeste('regras-a');
    final petA = db.collection('usuarios').doc(usuarioA.uid).collection('pets').doc('p1');
    final fotoA = db.collection('usuarios').doc(usuarioA.uid).collection('fotos').doc('p1');

    await petA.set({'nome': 'Luna', 'versao': 1, 'excluido': false});
    await fotoA.set({'petId': 'p1', 'versao': 1, 'excluido': false});

    expect((await petA.get()).data()?['nome'], 'Luna');
    expect((await fotoA.get()).data()?['petId'], 'p1');

    // Usuário B não pode ler nem gravar nos documentos de A.
    final usuarioB = await criarUsuarioDeTeste('regras-b');
    expect(usuarioB.uid, isNot(usuarioA.uid));

    await expectLater(
      petA.get(),
      throwsA(isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied')),
    );
    await expectLater(
      petA.set({'nome': 'Invadido', 'versao': 2, 'excluido': false}),
      throwsA(isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied')),
    );
    await expectLater(
      fotoA.get(),
      throwsA(isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied')),
    );

    // Usuário B consegue gravar nos próprios documentos.
    final petB = db.collection('usuarios').doc(usuarioB.uid).collection('pets').doc('p2');
    await petB.set({'nome': 'Thor', 'versao': 1, 'excluido': false});
    expect((await petB.get()).data()?['nome'], 'Thor');
  });

  test('acesso sem autenticação é recusado em usuarios/{uid}', () async {
    final db = FirebaseFirestore.instance;
    final usuarioA = await criarUsuarioDeTeste('regras-sem-auth');
    final doc = db.collection('usuarios').doc(usuarioA.uid).collection('pets').doc('p1');
    await doc.set({'nome': 'Luna', 'versao': 1, 'excluido': false});

    await FirebaseAuth.instance.signOut();

    await expectLater(
      doc.get(),
      throwsA(isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied')),
    );
    await expectLater(
      doc.set({'nome': 'Anonimo', 'versao': 2, 'excluido': false}),
      throwsA(isA<FirebaseException>().having((e) => e.code, 'code', 'permission-denied')),
    );
  });
}
