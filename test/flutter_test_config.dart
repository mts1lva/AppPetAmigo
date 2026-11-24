import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'apoio/golden.dart';

/// Configuração aplicada pelo `flutter test` a todos os arquivos desta pasta:
/// datas em pt-BR, fonte Inter carregada (sem ela, os textos viram blocos)
/// e comparador de golden com uma pequena tolerância, porque o
/// antisserrilhado do texto muda um pouco entre Windows, macOS e Linux.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');
  await carregarFonteInter();
  usarComparadorComTolerancia();
  await testMain();
}
