import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/datas.dart';
import '../../../../core/formato/saudacao.dart';
import '../../../../core/relogio.dart';
import '../../../../core/sugestao.dart';
import '../../../../core/ui/ui.dart';
import '../../../diario/apresentacao/providers/alimento_atalho_provider.dart';
import '../../../diario/apresentacao/providers/resumo_dia_provider.dart';
import '../../../diario/apresentacao/telas/dialogo_alimentos.dart';
import '../../../diario/apresentacao/telas/dialogo_atalho.dart';
import '../../../diario/domain/entidades/resumo_dia.dart';
import '../../../evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import '../../../lembretes/apresentacao/providers/lembretes_provider.dart';
import '../../../nutricao/apresentacao/providers/meta_provider.dart';
import '../../../nutricao/apresentacao/telas/dialogo_como_meta.dart';
import '../../../nutricao/domain/descricao_meta.dart';
import '../../../pets/apresentacao/providers/pet_atual_provider.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../../pets/apresentacao/telas/dialogo_dados_pet.dart';
import '../../../pets/apresentacao/telas/dialogo_seus_pets.dart';
import '../../../pets/domain/entidades/pet.dart';
import '../../../privacidade/apresentacao/providers/estado_copia_provider.dart';
import '../../domain/textos_inicio.dart';
import '../providers/sugestoes_provider.dart';
import '../widgets/cabecalho_pet.dart';

/// Tela 01 Início (`pacote-1` → 01; U2-10). Tudo do **pet atual**: trocar de
/// pet no N1 troca a tela inteira.
///
/// Os cards Hoje, Sugestões, Lembretes e Seu controle leem os providers dos
/// outros pacotes, que ainda são stubs; cada dono troca o stub pelo real sem
/// mudar esta tela. Os botões que abrem diálogos de outros pacotes ficam sem
/// ação até o dono ligar (TODO com o código da tarefa).
class TelaInicio extends ConsumerWidget {
  const TelaInicio({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agora = ref.watch(agoraProvider)();
    final petId = ref.watch(petAtualIdProvider).value;
    final pet = petId == null ? null : ref.watch(petProvider(petId)).value;
    final titulo = saudacao(agora);
    // Sem pet atual o roteador leva ao 26; aqui só evita tela quebrada no
    // instante da troca.
    if (pet == null) return PaTelaPrincipal(titulo: titulo, subtitulo: subtituloInicio);

    final hoje = DateTime(agora.year, agora.month, agora.day);
    final variosPets = (ref.watch(petsProvider).value?.length ?? 0) >= 2;

    return PaTelaPrincipal(
      titulo: titulo,
      subtitulo: subtituloInicio,
      filhos: [
        CabecalhoPet(pet: pet, hoje: hoje, variosPets: variosPets, aoTocar: () => abrirSeusPets(context)),
        _CardPerfil(pet: pet, hoje: hoje),
        _CardHoje(petId: pet.id, hoje: hoje),
        _CardSugestoes(petId: pet.id),
        _CardReferencia(pet: pet),
        _CardLembretes(petId: pet.id),
        const _CardSeuControle(),
      ],
    );
  }
}

/// Item 4: card do pet, com "Editar pet" → 05.
class _CardPerfil extends ConsumerWidget {
  const _CardPerfil({required this.pet, required this.hoje});

  final Pet pet;
  final DateTime hoje;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final peso = ref.watch(ultimaPesagemProvider(pet.id)).value?.pesoKg;
    return PaCard(
      titulo: pet.nome,
      texto: textoPerfil(pet, peso, hoje),
      filhos: [
        PaBotao.secundario(
          texto: botaoEditarPet,
          aoTocar: () => abrirDadosPet(context, petId: pet.id),
        ),
      ],
    );
  }
}

/// Item 5: "Hoje · 30 set." (R02), com o atalho "Registrar refeição".
class _CardHoje extends ConsumerWidget {
  const _CardHoje({required this.petId, required this.hoje});

  final String petId;
  final DateTime hoje;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumo = ref.watch(resumoDiaProvider((petId, hoje))).value ?? ResumoDia.vazio(hoje);
    return PaCard(
      variante: PaCardVariante.destaque,
      titulo: formatarHojeCard(hoje),
      texto: textoHoje(resumo, ref.watch(metaProvider(petId))),
      filhos: [
        PaBotao.primario(
          texto: botaoRegistrarRefeicao,
          aoTocar: () {
            final alimento = ref.read(alimentoAtalhoProvider(petId)).value;
            if (alimento == null) {
              abrirAlimentos(context, petId: petId, paraAtalho: true);
              return;
            }
            abrirAtalho(context, petId: petId);
          },
        ),
      ],
    );
  }
}

/// Item 5a: até 2 sugestões (M8). Sem sugestões, o card não aparece.
class _CardSugestoes extends ConsumerWidget {
  const _CardSugestoes({required this.petId});

  final String petId;

  static String _rotaDa(TipoSugestao tipo) => switch (tipo) {
    TipoSugestao.mudarObjetivo => Rotas.evolucao,
    TipoSugestao.reduzirPetiscos => Rotas.diario,
    TipoSugestao.aumentarExercicios => Rotas.atividades,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sugestoes = ref.watch(sugestoesProvider(petId));
    if (sugestoes.isEmpty) return const SizedBox.shrink();
    return PaCard(
      variante: PaCardVariante.destaque,
      titulo: tituloSugestoes,
      filhos: [
        for (final s in sugestoes) ...[
          Text(s.texto, style: PaTexto.corpo),
          PaBotao.secundario(texto: textoAcaoSugestao(s.tipo), aoTocar: () => context.go(_rotaDa(s.tipo))),
          PaBotao.secundario(
            texto: botaoAgoraNao,
            aoTocar: () => ref.read(sugestoesAdiadasRepositorioProvider).adiar(s.tipo, ref.read(agoraProvider)()),
          ),
        ],
      ],
    );
  }
}

/// Item 6: "Referência alimentar" (R03, R04), com "Entender a referência" → 18.
class _CardReferencia extends ConsumerWidget {
  const _CardReferencia({required this.pet});

  final Pet pet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final meta = ref.watch(metaProvider(pet.id));
    final alimento = ref.watch(alimentoAtalhoProvider(pet.id)).value;
    return PaCard(
      titulo: tituloReferenciaAlimentar,
      texto: meta == null
          ? null
          : textoReferenciaAlimentar(
              meta,
              pet,
              alimentoNome: alimento?.nome,
              densidadeKcalPor100g: alimento?.densidadeKcalPor100g,
            ),
      filhos: [
        PaBotao.secundario(
          texto: botaoEntenderReferencia,
          aoTocar: () => abrirComoMetaECalculada(context, pet.id),
        ),
      ],
    );
  }
}

/// Item 6a: horários dos lembretes ativos.
class _CardLembretes extends ConsumerWidget {
  const _CardLembretes({required this.petId});

  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lembretes = ref.watch(lembretesProvider(petId)).value ?? const [];
    return PaCard(
      titulo: tituloLembretes,
      texto: textoLembretes(lembretes),
      filhos: [
        // TODO(P3-2.1): abrir o N2 Lembretes.
        PaBotao.secundario(texto: botaoConfigurarLembretes, aoTocar: () {}),
      ],
    );
  }
}

/// Item 7: "Seu controle", com o estado da cópia remota.
class _CardSeuControle extends ConsumerWidget {
  const _CardSeuControle();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(estadoCopiaProvider).value;
    return PaCard(
      titulo: tituloSeuControle,
      texto: estado == null ? null : textoSeuControle(estado),
      filhos: [
        // TODO(P5-1.1): abrir a tela 14 Seus dados.
        PaBotao.secundario(texto: botaoPrivacidade, aoTocar: () {}),
      ],
    );
  }
}
