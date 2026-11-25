import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'app/coordenador_lembretes.dart';
import 'core/formato/datas.dart';
import 'core/inicializacao.dart';
import 'core/sync/firebase_inicializacao.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // R10: datas e números em pt-BR.
  await initializeDateFormatting(localeApp);
  // Lembretes (P3): fuso horário e plugin de notificações.
  await inicializarFusoHorario();
  await inicializarNotificacoes();
  // Cópia remota opcional: Firebase inicializado com a rede desligada.
  await inicializarFirebaseSemRede();

  // O banco local (drift) abre na primeira leitura do `bancoProvider`.
  runApp(
    const ProviderScope(child: CoordenadorLembretes(child: PetAmigoApp())),
  );
}
