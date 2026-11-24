import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/ui.dart';
import '../../domain/descricao_pet.dart';
import '../providers/pet_atual_provider.dart';
import '../providers/pets_providers.dart';
import 'dialogo_dados_pet.dart';

/// Abre o N1 Seus pets (`pacote-1` → N1; U2-10), pelo cabeçalho do Início.
Future<void> abrirSeusPets(BuildContext context) {
  return mostrarPaDialogo<void>(context, builder: (_) => const DialogoSeusPets());
}

/// N1 Seus pets: uma linha por pet, por ordem de cadastro, com o atual
/// marcado. Tocar num pet o torna o atual e fecha o diálogo.
class DialogoSeusPets extends ConsumerWidget {
  const DialogoSeusPets({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pets = ref.watch(petsProvider).value ?? const [];
    final atualId = ref.watch(petAtualIdProvider).value;
    final hoje = DateTime.now();

    return PaDialogo(
      titulo: 'Seus pets',
      subtitulo: 'Cada pet tem histórico, metas e lembretes próprios.',
      campos: [
        if (pets.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final pet in pets)
                PaHistorico(
                  texto: '${pet.nome} • ${linhaEspecieIdade(pet, hoje)}${pet.id == atualId ? ' • atual' : ''}',
                  aoTocar: () async {
                    final navegador = Navigator.of(context);
                    await ref.read(trocarPetAtualProvider)(pet.id);
                    navegador.pop();
                  },
                ),
            ],
          ),
      ],
      botoes: [
        PaBotao.primario(
          texto: 'Cadastrar outro pet',
          aoTocar: () {
            // Um diálogo aberto a partir de outro substitui o anterior
            // (navegacao.md): fecha o N1 e abre o 05 em modo cadastro.
            final contextoRaiz = Navigator.of(context, rootNavigator: true).context;
            Navigator.of(context).pop();
            abrirDadosPet(contextoRaiz);
          },
        ),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
