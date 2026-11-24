import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Inicializa o Firebase **sem rede** (`arquitetura.md` → Firebase).
///
/// - Persistência offline do Firestore desligada: com o cache ligado, o SDK
///   reenviaria gravações sozinho em qualquer rede, inclusive dados móveis
///   (viola RF15/RNF09).
/// - Rede do Firestore desligada: só o motor de sync (P5) chama
///   `enableNetwork()`, e apenas enquanto há Wi-Fi.
///
/// O app é offline-first e funciona inteiro sem o Firebase: se a
/// configuração ainda não existir (falta rodar `flutterfire configure`) ou a
/// inicialização falhar, devolve `false` e o app segue só com o banco local.
Future<bool> inicializarFirebaseSemRede() async {
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final firestore = FirebaseFirestore.instance;
    firestore.settings = const Settings(persistenceEnabled: false);
    await firestore.disableNetwork();
    return true;
  } catch (erro) {
    // Sem dados pessoais no log: só o tipo do erro.
    debugPrint('Firebase indisponível; o app segue só com o banco local (${erro.runtimeType}).');
    return false;
  }
}
