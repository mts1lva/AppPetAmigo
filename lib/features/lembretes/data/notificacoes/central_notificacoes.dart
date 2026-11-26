import 'package:flutter/foundation.dart';

import '../../domain/entidades/lembrete.dart';
import '../../domain/repositorios/agendador_notificacoes.dart';

/// Conserva o toque recebido antes de o roteador e o banco ficarem prontos.
final centralNotificacoes = CentralNotificacoes();

final class CentralNotificacoes extends ChangeNotifier {
  bool inicializada = false;
  final _pendentes = <({String petId, TipoLembrete tipo})>[];
  ({String petId, TipoLembrete tipo})? get primeiro => _pendentes.firstOrNull;

  void receber(String? payload) {
    final destino = lerPayloadLembrete(payload);
    if (destino == null) return;
    _pendentes.add(destino);
    notifyListeners();
  }

  void concluir() {
    if (_pendentes.isNotEmpty) _pendentes.removeAt(0);
  }
}
