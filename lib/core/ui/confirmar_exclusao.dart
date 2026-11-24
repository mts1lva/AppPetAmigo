import 'package:material_ui/material_ui.dart';

import 'pa_botao.dart';
import 'pa_dialogo.dart';

/// Tela 23 "Confirmar exclusão", compartilhada por todos os pacotes.
///
/// Abre por cima do formulário que chamou. Devolve `true` ao confirmar; quem
/// chamou fecha o próprio diálogo e executa a exclusão. "Cancelar", o véu e o
/// botão voltar do Android devolvem `false`.
///
/// "Cancelar" é `secundario` (no PNG está verde; decisão P-06).
Future<bool> confirmarExclusao(BuildContext c, {bool integral = false}) async {
  final confirmou = await mostrarPaDialogo<bool>(
    c,
    builder: (contexto) => PaDialogo(
      titulo: 'Confirmar exclusão',
      subtitulo: integral ? 'Ação sobre todos os dados.' : 'Ação sobre o item selecionado.',
      texto: integral
          ? 'Remove pet, foto, metas e todos os registros deste aparelho. '
              'A remoção da cópia remota pode ficar pendente até o próximo Wi-Fi.'
          : 'Exclui apenas o item escolhido e atualiza os totais.',
      botoes: [
        PaBotao.primario(
          texto: 'Confirmar exclusão',
          aoTocar: () => Navigator.of(contexto).pop(true),
        ),
        PaBotao.secundario(
          texto: 'Cancelar',
          aoTocar: () => Navigator.of(contexto).pop(false),
        ),
      ],
    ),
  );
  return confirmou ?? false;
}
