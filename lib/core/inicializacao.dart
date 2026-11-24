import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Fuso horário do aparelho para o `zonedSchedule` dos lembretes (U2-09).
/// Sem conseguir ler o fuso, fica em UTC e o app continua.
Future<void> inicializarFusoHorario() async {
  tz.initializeTimeZones();
  try {
    final fuso = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(fuso.identifier));
  } catch (erro) {
    debugPrint('Fuso horário indisponível; usando UTC (${erro.runtimeType}).');
  }
}

/// Plugin de notificações locais (singleton: `FlutterLocalNotificationsPlugin()`
/// devolve sempre a mesma instância). Não pede permissão aqui: o P3 pede ao
/// criar o primeiro lembrete (P3-1.4).
Future<void> inicializarNotificacoes() async {
  try {
    await FlutterLocalNotificationsPlugin().initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      // TODO(P3-1.4): abrir o app no pet do lembrete (payload `petId`) e no
      // diálogo de registro do tipo (06, 11 ou 10).
    );
  } catch (erro) {
    debugPrint('Notificações indisponíveis (${erro.runtimeType}).');
  }
}
