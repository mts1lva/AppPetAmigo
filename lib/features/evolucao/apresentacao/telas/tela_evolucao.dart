import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/tipografia.dart';
import '../../../../core/resultado.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pet_atual_provider.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/entidades/pesagem.dart';
import '../../domain/grafico_dados.dart';
import '../../domain/modelos_do_pet.dart';
import '../../domain/textos_tela_evolucao.dart';
import '../providers/evolucao_providers.dart';
import '../widgets/grafico_evolucao.dart';
import 'dialogo_ecc_objetivo.dart';
import 'dialogo_pesagem.dart';

/// Tela 04 Evolução (`pacote-4` → 04) do **pet atual**. Tudo vem do
/// `modelosProvider` (M9): uma pesagem, referência, refeição ou atividade
/// gravada recalcula a tela sozinha, sem botão "atualizar" (U2-05).
class TelaEvolucao extends ConsumerStatefulWidget {
  const TelaEvolucao({super.key});

  /// Card do gráfico, para o "Ver evolução" do N3 rolar até ele.
  static final chaveGrafico = GlobalKey(debugLabel: 'grafico-evolucao');

  /// Rola até o card do gráfico, se a tela estiver montada.
  static void rolarAteGrafico() {
    final contexto = chaveGrafico.currentContext;
    if (contexto != null) Scrollable.ensureVisible(contexto, duration: const Duration(milliseconds: 300));
  }

  @override
  ConsumerState<TelaEvolucao> createState() => _TelaEvolucaoState();
}

class _TelaEvolucaoState extends ConsumerState<TelaEvolucao> {
  /// Quantas pesagens anteriores aparecem ("Ver mais" soma mais 10).
  var _mostrar = pesagensPorPagina;

  @override
  Widget build(BuildContext context) {
    final petId = ref.watch(petAtualIdProvider).value;
    final pet = petId == null ? null : ref.watch(petProvider(petId)).value;
    final modelos = petId == null ? null : ref.watch(modelosProvider(petId));
    if (petId == null || pet == null || modelos == null) {
      return const PaTelaPrincipal(titulo: TextosEvolucao.titulo, subtitulo: TextosEvolucao.subtitulo);
    }
    final referencia = ref.watch(referenciaProvider(petId)).value;
    final grafico = ref.watch(graficoProvider(petId));

    void registrarPeso() => abrirPesagem(context, petId: petId);
    void editarPesagem(Pesagem p) => abrirPesagem(context, petId: petId, pesagemId: p.id);

    return PaTelaPrincipal(
      titulo: TextosEvolucao.titulo,
      subtitulo: TextosEvolucao.subtitulo,
      filhos: [
        PaCard(
          key: TelaEvolucao.chaveGrafico,
          variante: PaCardVariante.destaque,
          filhos: [
            switch (grafico) {
              Disponivel(:final valor) => GraficoEvolucao(
                  dados: valor,
                  textoAlternativo: textoAlternativoGrafico(valor, previsao: modelos.previsao.texto),
                ),
              _ => GraficoVazio(nomePet: pet.nome, aoRegistrarPeso: registrarPeso),
            },
          ],
        ),
        _CardIndicadores(modelos: modelos),
        PaCard(
          titulo: TextosEvolucao.tituloUltimaPesagem,
          texto: textoUltimaPesagem(modelos.pesagens),
          filhos: [
            if (modelos.pesoAtual case final ultima?)
              PaBotao.secundario(texto: 'Editar pesagem', aoTocar: () => editarPesagem(ultima)),
          ],
        ),
        if (pesagensAnteriores(modelos.pesagens) case final anteriores when anteriores.isNotEmpty)
          PaCard(
            titulo: TextosEvolucao.tituloPesagensAnteriores,
            filhos: [
              Column(
                children: [
                  for (final p in anteriores.take(_mostrar))
                    PaHistorico(
                      texto: linhaPesagemAnterior(p, pesoInicial: p.id == modelos.pesoInicial?.id),
                      aoTocar: () => editarPesagem(p),
                    ),
                  if (anteriores.length > _mostrar)
                    PaHistorico(
                      texto: TextosEvolucao.verMais,
                      aoTocar: () => setState(() => _mostrar += pesagensPorPagina),
                    ),
                ],
              ),
            ],
          ),
        PaCard(
          titulo: TextosEvolucao.tituloAcompanhar,
          texto: TextosEvolucao.textoAcompanhar,
          filhos: [PaBotao.secundario(texto: 'Registrar peso', aoTocar: registrarPeso)],
        ),
        PaCard(
          titulo: TextosEvolucao.tituloEccObjetivo,
          texto: textoEccObjetivo(referencia),
          filhos: [
            PaBotao.secundario(
              texto: 'Atualizar referências',
              aoTocar: () => abrirEccObjetivo(context, petId: petId),
            ),
          ],
        ),
        const PaCard(
          titulo: TextosEvolucao.tituloResumo,
          texto: TextosEvolucao.textoResumo,
          // TODO(P4-2.2): abrir a tela 13 do P3 (P3-1.7) quando ela existir.
          filhos: [PaBotao.secundario(texto: 'Compartilhar resumo', aoTocar: null)],
        ),
      ],
    );
  }
}

class _CardIndicadores extends StatelessWidget {
  const _CardIndicadores({required this.modelos});

  final ModelosDoPet modelos;

  @override
  Widget build(BuildContext context) {
    return PaCard(
      titulo: TextosEvolucao.tituloIndicadores,
      texto: linhasIndicadores(modelos).join('\n'),
      filhos: const [Text(avisoIndicadores, style: PaTexto.legenda)],
    );
  }
}
