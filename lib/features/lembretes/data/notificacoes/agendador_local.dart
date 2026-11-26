import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/services.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entidades/lembrete.dart';
import '../../domain/repositorios/agendador_notificacoes.dart';

typedef PermissoesLembretes = ({bool notificacoes, bool horarioExato});

final class AgendadorLocal implements AgendadorNotificacoes {
  AgendadorLocal({
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? relogio,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _relogio = relogio ?? DateTime.now;
  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _relogio;
  static const _permissoes = MethodChannel('br.com.petamigo/permissoes');

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<PermissoesLembretes> permissoes() async => (
    notificacoes: await _android?.areNotificationsEnabled() ?? false,
    horarioExato: await _android?.canScheduleExactNotifications() ?? false,
  );

  Future<void> pedirNotificacoes() async {
    if (await _android?.areNotificationsEnabled() ?? false) return;
    final permanente = await _permissoes.invokeMethod<bool>('notificacoesNegadasPermanentemente') ?? false;
    if (permanente) {
      await _plugin.openAppNotificationSettings();
    } else {
      await _permissoes.invokeMethod<void>('registrarPedidoNotificacoes');
      await _android?.requestNotificationsPermission();
    }
  }

  Future<void> pedirHorarioExato() async {
    await _android?.requestExactAlarmsPermission();
  }

  @override
  Future<void> agendarDiario(Lembrete l, {required String nomePet}) async {
    if (!l.ativo) return cancelar(l.notificacaoId);
    final exato = await _android?.canScheduleExactNotifications() ?? false;
    Future<void> agendar(AndroidScheduleMode modo) => _plugin.zonedSchedule(
      id: l.notificacaoId,
      title: tituloNotificacao(l.tipo, nomePet),
      body: 'Toque para registrar.',
      scheduledDate: proximoHorario(
        tz.TZDateTime.from(_relogio(), tz.local),
        l.horaMinutos,
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'lembretes_petamigo',
          'Lembretes',
          channelDescription: 'Refeições, pesagens e atividades dos pets.',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_notificacao',
        ),
      ),
      androidScheduleMode: modo,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payloadLembrete(l),
    );
    try {
      await agendar(
        exato
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } on Exception {
      // A permissão pode ser revogada entre a consulta e o agendamento.
      if (!exato) rethrow;
      await agendar(AndroidScheduleMode.inexactAllowWhileIdle);
    }
  }

  @override
  Future<void> cancelar(int notificacaoId) => _plugin.cancel(id: notificacaoId);
  @override
  Future<void> cancelarTodos() => _plugin.cancelAll();
}

/// Construção por calendário (não soma 24 h): respeita mudança de fuso/DST.
tz.TZDateTime proximoHorario(tz.TZDateTime agora, int minutos) {
  if (minutos < 0 || minutos >= 1440) throw RangeError.range(minutos, 0, 1439);
  var data = tz.TZDateTime(
    agora.location,
    agora.year,
    agora.month,
    agora.day,
    minutos ~/ 60,
    minutos % 60,
  );
  if (!data.isAfter(agora)) {
    data = tz.TZDateTime(
      agora.location,
      agora.year,
      agora.month,
      agora.day + 1,
      minutos ~/ 60,
      minutos % 60,
    );
  }
  return data;
}
