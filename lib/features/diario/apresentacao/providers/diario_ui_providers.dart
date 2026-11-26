import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sinal do 20 "Consultar diário atualizado": o título vira `Diário atualizado`
/// até o tutor sair da aba (P-05), e a aba abre no [dia] da refeição salva.
final class SinalDiarioAtualizado {
  const SinalDiarioAtualizado({this.atualizado = false, this.dia, this.geracao = 0});

  final bool atualizado;
  final DateTime? dia;
  final int geracao;
}

final class DiarioAtualizado extends Notifier<SinalDiarioAtualizado> {
  @override
  SinalDiarioAtualizado build() => const SinalDiarioAtualizado();

  void marcar({DateTime? dia}) => state = SinalDiarioAtualizado(
        atualizado: true,
        dia: dia,
        geracao: state.geracao + 1,
      );

  void limpar() => state = SinalDiarioAtualizado(geracao: state.geracao);
}

final diarioAtualizadoProvider = NotifierProvider<DiarioAtualizado, SinalDiarioAtualizado>(
  DiarioAtualizado.new,
);
