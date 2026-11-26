import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/router.dart';
import '../../../../core/ui/ui.dart';
import '../../domain/entidades/resumo_dia.dart';
import '../../domain/textos_diario.dart';
import '../providers/diario_ui_providers.dart';

/// Abre o 20 Refeição salva, só depois da transação ter gravado.
Future<void> abrirRefeicaoSalva(
  BuildContext context, {
  required double antesKcal,
  required ResumoDia depois,
  String titulo = tituloRefeicaoSalva,
}) {
  return mostrarPaDialogo<void>(
    context,
    builder: (_) => DialogoRefeicaoSalva(antesKcal: antesKcal, depois: depois, titulo: titulo),
  );
}

/// Tela 20 Refeição salva (`pacote-2` → 20; R08).
class DialogoRefeicaoSalva extends ConsumerWidget {
  const DialogoRefeicaoSalva({
    super.key,
    required this.antesKcal,
    required this.depois,
    this.titulo = tituloRefeicaoSalva,
  });

  final double antesKcal;
  final ResumoDia depois;

  /// `Refeição salva`; depois de um petisco pelo 06, `Petisco salvo` (P-32).
  final String titulo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PaDialogo(
      titulo: titulo,
      subtitulo: subtituloRefeicaoSalva,
      texto: textoRefeicaoSalva(antesKcal: antesKcal, depois: depois),
      botoes: [
        PaBotao.primario(
          texto: botaoConsultarDiarioAtualizado,
          aoTocar: () {
            final roteador = GoRouter.of(context);
            ref.read(diarioAtualizadoProvider.notifier).marcar(dia: depois.dia);
            Navigator.of(context).pop();
            roteador.go(Rotas.diario);
          },
        ),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
