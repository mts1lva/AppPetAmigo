/// Apoio dos testes de integração no Firebase Emulator Suite (P2-2.3).
///
/// Todos os pacotes chamam [usarEmuladores] **antes** de qualquer leitura ou
/// gravação: Auth e Firestore passam a falar com `localhost` (ou `10.0.2.2`
/// no emulador Android), nunca com o projeto real `pet-amigo-bac9e`.
library;

import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:petamigo/firebase_options.dart';

/// Porta do emulador de Cloud Firestore (`firebase.json`).
const portaFirestoreEmulador = 8080;

/// Porta do emulador de Authentication (`firebase.json`).
const portaAuthEmulador = 9099;

/// `10.0.2.2` é a máquina host vista pelo emulador Android. No host (CI,
/// `flutter test` desktop) é `127.0.0.1`.
String hostEmulador() => Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';

String get _projetoId => DefaultFirebaseOptions.android.projectId;

/// Aponta Auth e Firestore para os emuladores locais. Nada vai para o
/// projeto real depois desta chamada.
///
/// Precisa de [Firebase.initializeApp] já feito. Liga a rede do Firestore
/// (no app ela fica desligada) só para falar com o emulador.
Future<void> usarEmuladores({String? host}) async {
  final h = host ?? hostEmulador();
  FirebaseFirestore.instance.useFirestoreEmulator(h, portaFirestoreEmulador);
  await FirebaseAuth.instance.useAuthEmulator(h, portaAuthEmulador);
  await FirebaseFirestore.instance.enableNetwork();
  debugPrint('Firestore e Auth apontam para o emulador em $h (projeto real isolado).');
}

/// Apaga contas e documentos do emulador (endpoints REST oficiais).
Future<void> limparEmuladores({String? host}) async {
  final h = host ?? hostEmulador();
  final cliente = HttpClient();
  try {
    await _delete(
      cliente,
      Uri.parse('http://$h:$portaAuthEmulador/emulator/v1/projects/$_projetoId/accounts'),
    );
    await _delete(
      cliente,
      Uri.parse(
        'http://$h:$portaFirestoreEmulador/emulator/v1/projects/$_projetoId/databases/(default)/documents',
      ),
    );
  } finally {
    cliente.close();
  }
}

Future<void> _delete(HttpClient cliente, Uri uri) async {
  final pedido = await cliente.deleteUrl(uri);
  final resposta = await pedido.close();
  await resposta.drain<void>();
  if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
    throw HttpException('limparEmuladores: ${resposta.statusCode} em ${uri.path}', uri: uri);
  }
}

/// Cria um usuário só no emulador. [sufixo] distingue os testes; o e-mail
/// não é de ninguém real.
Future<User> criarUsuarioDeTeste(String sufixo) async {
  final email = 'teste.$sufixo@petamigo.invalid';
  const senha = 'senha-teste-123456';
  final credencial = await FirebaseAuth.instance.createUserWithEmailAndPassword(
    email: email,
    password: senha,
  );
  final usuario = credencial.user;
  if (usuario == null) {
    throw StateError('criarUsuarioDeTeste: o emulador não devolveu User');
  }
  return usuario;
}

/// Corpo da resposta de um GET no emulador, para testes que leem o REST.
Future<Map<String, Object?>> getJsonEmulador(Uri uri) async {
  final cliente = HttpClient();
  try {
    final resposta = await (await cliente.getUrl(uri)).close();
    final texto = await utf8.decodeStream(resposta);
    if (resposta.statusCode < 200 || resposta.statusCode >= 300) {
      throw HttpException('GET ${resposta.statusCode}: $texto', uri: uri);
    }
    return jsonDecode(texto) as Map<String, Object?>;
  } finally {
    cliente.close();
  }
}
