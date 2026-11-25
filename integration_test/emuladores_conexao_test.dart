// P2-2.3 — conecta de verdade `usarEmuladores()` a Auth e Firestore locais.
// Precisa de um aparelho/emulador Android (o SDK nativo do Firebase não
// funciona no `flutter-tester`). A CI sobe API 29 e o Firebase Emulator Suite:
//   firebase emulators:exec --only auth,firestore --project pet-amigo-bac9e \
//     "flutter test integration_test/emuladores_conexao_test.dart"

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
    await limparEmuladores();
  });

  test('usarEmuladores aponta Auth e Firestore para o emulador local', () async {
    final host = FirebaseFirestore.instance.settings.host ?? '';
    expect(
      host,
      anyOf(contains(hostEmulador()), contains('127.0.0.1'), contains('localhost')),
      reason: 'o Firestore tem de falar com o emulador, não com o projeto real',
    );

    final usuario = await criarUsuarioDeTeste('conexao');
    expect(usuario.uid, isNotEmpty);
    expect(FirebaseAuth.instance.currentUser?.uid, usuario.uid);

    final ping = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(usuario.uid)
        .collection('refeicoes')
        .doc('ping');
    await ping.set({'ok': true, 'origem': 'emulador'});
    final lido = await ping.get();
    expect(lido.data()?['ok'], true);
    expect(lido.data()?['origem'], 'emulador');

    await limparEmuladores();
    final depois = await ping.get();
    expect(depois.exists, isFalse, reason: 'a limpeza REST só existe no emulador local');
  });
}
