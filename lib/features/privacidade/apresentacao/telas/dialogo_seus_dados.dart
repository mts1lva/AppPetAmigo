import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pet_atual_provider.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';

/// Abre a tela 14 "Seus dados", a partir do card "Seu controle" do Início.
Future<void> abrirSeusDados(BuildContext context) {
  return mostrarPaDialogo<void>(context, builder: (_) => const DialogoSeusDados());
}

/// Texto explicativo da tela 14 (`pacote-5` → 14).
String textoSeusDados(String nomePet) =>
    'Perfil, foto e registros servem ao acompanhamento de $nomePet. '
    'Ficam neste aparelho. Você controla a exportação e a exclusão. '
    'Cópia remota é opcional.';

/// Tela 14 "Seus dados" (`pacote-5` → 14; RF14, RF15, RF16, RF17).
///
/// Os botões "Cópia remota opcional", "Exportar dados" e "Excluir todos os
/// dados" ficam ligados conforme as dependências (P5-1.2, P5-2.2, P5-3.2)
/// forem liberadas.
class DialogoSeusDados extends ConsumerWidget {
  const DialogoSeusDados({
    super.key,
    this.aoAbrirCopiaRemota,
    this.aoExportarDados,
    this.aoExcluirTodosOsDados,
  });

  static const tituloSeusDados = 'Seus dados';
  static const subtituloSeusDados = 'O uso essencial funciona sem conta.';
  static const botaoCopiaRemota = 'Cópia remota opcional';
  static const botaoExportarDados = 'Exportar dados';
  static const botaoExcluirTodos = 'Excluir todos os dados';
  static const botaoVoltar = 'Voltar';

  final VoidCallback? aoAbrirCopiaRemota;
  final VoidCallback? aoExportarDados;
  final VoidCallback? aoExcluirTodosOsDados;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petId = ref.watch(petAtualIdProvider).value;
    final pet = petId == null ? null : ref.watch(petProvider(petId)).value;
    final nomePet = pet?.nome ?? 'seu pet';

    return PaDialogo(
      titulo: tituloSeusDados,
      subtitulo: subtituloSeusDados,
      texto: textoSeusDados(nomePet),
      botoes: [
        // TODO(P5-3.2): abrir a tela 15 (desligada) ou 16 (ligada).
        PaBotao.primario(
          texto: botaoCopiaRemota,
          aoTocar: aoAbrirCopiaRemota ?? () {},
        ),
        // TODO(P5-2.2): exportar dados com GeradorExportacao e share_plus.
        PaBotao.primario(
          texto: botaoExportarDados,
          aoTocar: aoExportarDados ?? () {},
        ),
        // TODO(P5-1.2): abrir confirmarExclusao(integral: true) e executar RF17.
        PaBotao.perigo(
          texto: botaoExcluirTodos,
          aoTocar: aoExcluirTodosOsDados ?? () {},
        ),
        PaBotao.secundario(
          texto: botaoVoltar,
          aoTocar: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
