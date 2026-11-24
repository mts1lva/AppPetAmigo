import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/ui.dart';
import '../../../diario/apresentacao/providers/alimento_atalho_provider.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/descricao_meta.dart';
import '../providers/meta_provider.dart';

/// Abre a tela 18 "Como a meta é calculada" do pet, pelo botão "Entender a
/// referência" do Início.
Future<void> abrirComoMetaECalculada(BuildContext context, String petId) {
  return mostrarPaDialogo<void>(context, builder: (_) => DialogoComoMeta(petId: petId));
}

/// Tela 18 (`pacote-1` → 18; U2-01): explica o cálculo da meta (M1) com os
/// números do pet. Mantém o layout do PNG 18, com os textos novos. Os dois
/// botões fecham o diálogo.
class DialogoComoMeta extends ConsumerWidget {
  const DialogoComoMeta({super.key, required this.petId});

  static const botaoVoltarAoPerfil = 'Voltar ao perfil';
  static const botaoVoltar = 'Voltar';

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petProvider(petId)).value;
    final meta = ref.watch(metaProvider(petId));
    final alimento = ref.watch(alimentoAtalhoProvider(petId)).value;
    void fechar() => Navigator.of(context).pop();

    return PaDialogo(
      titulo: tituloComoMeta,
      subtitulo: subtituloComoMeta,
      texto: pet == null || meta == null
          ? null
          : textoComoMetaECalculada(
              meta,
              pet,
              alimentoNome: alimento?.nome,
              densidadeKcalPor100g: alimento?.densidadeKcalPor100g,
            ),
      botoes: [
        PaBotao.primario(texto: botaoVoltarAoPerfil, aoTocar: fechar),
        PaBotao.secundario(texto: botaoVoltar, aoTocar: fechar),
      ],
    );
  }
}
