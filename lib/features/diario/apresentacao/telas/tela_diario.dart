import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/formato/datas.dart';
import '../../../../core/relogio.dart';
import '../../../../core/ui/ui.dart';
import '../../../nutricao/apresentacao/providers/meta_provider.dart';
import '../../../pets/apresentacao/providers/pet_atual_provider.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/entidades/extra.dart';
import '../../domain/entidades/refeicao.dart';
import '../../domain/resumo_do_dia.dart';
import '../../domain/textos_diario.dart';
import '../providers/diario_ui_providers.dart';
import '../providers/repositorios_providers.dart';
import 'dialogo_alimentos.dart';
import 'dialogo_outra_data.dart';
import 'dialogo_petisco.dart';
import 'dialogo_refeicao.dart';

/// Tela 02 Diário (`pacote-2` → 02; P-05 para o título "Diário atualizado").
class TelaDiario extends ConsumerStatefulWidget {
  const TelaDiario({super.key});

  @override
  ConsumerState<TelaDiario> createState() => _TelaDiarioState();
}

class _TelaDiarioState extends ConsumerState<TelaDiario> {
  DateTime? _dia;

  DateTime _hoje() {
    final agora = ref.read(agoraProvider)();
    return DateTime(agora.year, agora.month, agora.day);
  }

  DateTime get dia => _dia ?? _hoje();

  Future<void> _selecionarData() async {
    final hoje = _hoje();
    var inicial = dia;
    if (inicial.isAfter(hoje)) inicial = hoje;
    final escolhida = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2000),
      lastDate: hoje,
    );
    if (escolhida == null || !mounted) return;
    final novo = DateTime(escolhida.year, escolhida.month, escolhida.day);
    setState(() => _dia = novo);
    final petId = ref.read(petAtualIdProvider).value;
    if (petId == null) return;
    final refeicoes = await ref.read(refeicoesDoDiaProvider((petId, novo)).future);
    final extras = await ref.read(extrasDoDiaProvider((petId, novo)).future);
    if (!mounted) return;
    if (refeicoes.isEmpty && extras.isEmpty) {
      final retomar = await abrirOutraData(context, data: novo);
      if (retomar && mounted) setState(() => _dia = _hoje());
    }
  }

  @override
  Widget build(BuildContext context) {
    final petId = ref.watch(petAtualIdProvider).value;
    final pet = petId == null ? null : ref.watch(petProvider(petId)).value;
    final atualizado = ref.watch(diarioAtualizadoProvider);
    final titulo = atualizado ? tituloDiarioAtualizado : tituloDiario;
    if (pet == null) return PaTelaPrincipal(titulo: titulo);

    final d = dia;
    final refeicoes = ref.watch(refeicoesDoDiaProvider((pet.id, d))).value ?? const <Refeicao>[];
    final extras = ref.watch(extrasDoDiaProvider((pet.id, d))).value ?? const <Extra>[];
    final resumo = resumoDoDia(dia: d, refeicoes: refeicoes, extras: extras);
    final meta = ref.watch(metaProvider(pet.id));

    return PaTelaPrincipal(
      titulo: titulo,
      subtitulo: formatarDataExtenso(d),
      filhos: [
        PaCard(
          titulo: tituloDataSelecionada,
          texto: textoCardData,
          filhos: [
            PaBotao.secundario(texto: botaoSelecionarData, aoTocar: _selecionarData),
          ],
        ),
        PaCard(
          titulo: tituloRefeicoes,
          texto: refeicoes.isEmpty ? textoSemRefeicoes : null,
          filhos: [
            if (refeicoes.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final r in refeicoes)
                    PaHistorico(
                      texto: linhaRefeicao(r),
                      rotuloSemantico: rotuloSemanticoRefeicao(r),
                      aoTocar: () => abrirRefeicao(context, petId: pet.id, refeicaoId: r.id),
                    ),
                ],
              ),
            PaBotao.secundario(
              texto: refeicoes.isEmpty ? botaoAdicionarRefeicao : botaoEditarRefeicao,
              aoTocar: () => abrirRefeicao(
                context,
                petId: pet.id,
                refeicaoId: refeicoes.isEmpty ? null : refeicoes.last.id,
                dia: d,
              ),
            ),
          ],
        ),
        PaCard(
          titulo: tituloPetiscos,
          texto: extras.isEmpty ? textoSemPetiscos : null,
          filhos: [
            if (extras.isNotEmpty)
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final e in extras)
                    PaHistorico(
                      texto: linhaExtra(e),
                      rotuloSemantico: rotuloSemanticoExtra(e),
                      aoTocar: () => abrirPetisco(context, petId: pet.id, extraId: e.id),
                    ),
                ],
              ),
            if (extras.isNotEmpty)
              PaBotao.secundario(
                texto: botaoEditarPetisco,
                aoTocar: () => abrirPetisco(context, petId: pet.id, extraId: extras.last.id, dia: d),
              ),
          ],
        ),
        PaCard(
          titulo: tituloResumoDoDia,
          texto: textoResumoDia(resumo, meta),
          filhos: [
            PaBotao.secundario(
              texto: botaoAdicionarPetisco,
              aoTocar: () => abrirPetisco(context, petId: pet.id, dia: d),
            ),
          ],
        ),
        PaCard(
          titulo: tituloAlimentosCard,
          texto: textoAlimentosCard,
          filhos: [
            PaBotao.secundario(
              texto: botaoGerenciarAlimentos,
              aoTocar: () => abrirAlimentos(context, petId: pet.id),
            ),
          ],
        ),
      ],
    );
  }
}
