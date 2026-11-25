import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/lembretes/data/notificacoes/agendador_local.dart';
import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';
import 'package:timezone/data/latest_all.dart' as dados;
import 'package:timezone/timezone.dart' as tz;

void main() {
  const canal = MethodChannel('dexterous.com/flutter/local_notifications');
  final chamadas = <MethodCall>[];
  var exato = false;
  var revogar = false;
  setUp(() {
    dados.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Fortaleza'));
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    AndroidFlutterLocalNotificationsPlugin.registerWith();
    chamadas.clear();
    exato = false;
    revogar = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, (chamada) async {
          chamadas.add(chamada);
          if (chamada.method == 'canScheduleExactNotifications') return exato;
          if (chamada.method == 'areNotificationsEnabled') return true;
          if (chamada.method == 'zonedSchedule' && revogar) {
            revogar = false;
            throw PlatformException(code: 'exact_alarms_not_permitted');
          }
          if (chamada.method == 'initialize') return true;
          return null;
        });
  });
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(canal, null);
  });
  const lembrete = Lembrete(
    id: 'l1',
    petId: 'p1',
    horaMinutos: 480,
    tipo: TipoLembrete.refeicao,
    ativo: true,
    notificacaoId: 42,
  );

  test(
    'Android: agenda diário no fuso local e usa alternativa sem alarme exato',
    () async {
      final plugin = FlutterLocalNotificationsPlugin();
      await plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('ic_notificacao'),
        ),
      );
      final agendador = AgendadorLocal(
        plugin: plugin,
        relogio: () => DateTime(2026, 11, 25, 12),
      );
      await agendador.agendarDiario(lembrete, nomePet: 'Luna');
      final args =
          chamadas.singleWhere((c) => c.method == 'zonedSchedule').arguments
              as Map;
      expect(args['id'], 42);
      expect(args['payload'], 'p1|refeicao');
      expect(args['title'], 'Hora da refeição de Luna');
      expect(args['body'], 'Toque para registrar.');
      expect(args['timeZoneName'], 'America/Fortaleza');
      expect(args['matchDateTimeComponents'], DateTimeComponents.time.index);
      expect(args['scheduledDateTime'], contains('08:00'));
    },
  );
  test('permissão revogada durante agendamento tenta o modo inexato', () async {
    exato = true;
    revogar = true;
    await AgendadorLocal(relogio: () => DateTime(2026, 11, 25))
        .agendarDiario(lembrete, nomePet: 'Luna');
    expect(chamadas.where((c) => c.method == 'zonedSchedule'), hasLength(2));
  });
  test('horário seguinte passa para amanhã e mantém hora de parede no DST', () {
    final fuso = tz.getLocation('America/New_York');
    final agora = tz.TZDateTime(fuso, 2026, 3, 7, 9);
    final proximo = proximoHorario(agora, 480);
    expect((proximo.day, proximo.hour), (8, 8));
    expect(proximo.difference(agora).inHours, 22);
  });
}
