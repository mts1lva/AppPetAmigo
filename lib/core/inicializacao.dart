import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../features/lembretes/data/notificacoes/central_notificacoes.dart';

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
        android: AndroidInitializationSettings('ic_notificacao'),
      ),
      onDidReceiveNotificationResponse: (resposta) =>
          centralNotificacoes.receber(resposta.payload),
    );
    centralNotificacoes.inicializada = true;
    final abertura = await FlutterLocalNotificationsPlugin()
        .getNotificationAppLaunchDetails();
    if (abertura?.didNotificationLaunchApp ?? false) {
      centralNotificacoes.receber(abertura?.notificationResponse?.payload);
    }
  } catch (erro) {
    debugPrint('Notificações indisponíveis (${erro.runtimeType}).');
  }
}
