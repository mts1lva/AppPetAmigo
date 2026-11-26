import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hora atual. As telas leem "hoje" por aqui, para os testes (e os goldens)
/// poderem fixar a data com `agoraProvider.overrideWithValue(...)`.
final agoraProvider = Provider<DateTime Function()>((ref) => DateTime.now);

/// Dia civil de hoje (00:00), que **muda sozinho na virada do dia**. Use no
/// lugar de `agoraProvider` quando o valor depende só da data (janelas de
/// dias, resumo de hoje): assim o app aberto de um dia para o outro passa a
/// contar o dia novo sem reiniciar.
///
/// Confere o relógio a cada minuto em vez de agendar a meia-noite, porque um
/// `Timer` longo atrasa quando o aparelho dorme.
final diaAtualProvider = NotifierProvider<DiaAtual, DateTime>(DiaAtual.new);

class DiaAtual extends Notifier<DateTime> {
  static const intervalo = Duration(minutes: 1);

  @override
  DateTime build() {
    final agora = ref.watch(agoraProvider);
    final timer = Timer.periodic(intervalo, (_) {
      final hoje = _dia(agora());
      if (hoje != state) state = hoje;
    });
    ref.onDispose(timer.cancel);
    return _dia(agora());
  }

  static DateTime _dia(DateTime t) => DateTime(t.year, t.month, t.day);
}
