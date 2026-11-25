import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Quando o tutor chega pelo 20 "Consultar diário atualizado", o título do
/// Diário vira `Diário atualizado` até ele sair da aba (P-05).
final class DiarioAtualizado extends Notifier<bool> {
  @override
  bool build() => false;

  void marcar() => state = true;

  void limpar() => state = false;
}

final diarioAtualizadoProvider = NotifierProvider<DiarioAtualizado, bool>(DiarioAtualizado.new);
