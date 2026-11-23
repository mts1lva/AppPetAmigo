import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'database.dart';

/// Banco local único do app. Nos testes, troque por um banco em memória:
/// `bancoProvider.overrideWithValue(BancoLocal(NativeDatabase.memory()))`.
final bancoProvider = Provider<BancoLocal>((ref) {
  final banco = BancoLocal.abrir();
  ref.onDispose(banco.close);
  return banco;
});
