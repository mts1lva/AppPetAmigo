import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/datas.dart';
import '../../../../core/relogio.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../../pets/domain/entidades/pet.dart';
import '../../domain/entidades/atividade.dart';
import '../../domain/entidades/dica.dart';
import '../providers/atividades_providers.dart';
import 'dialogo_atividade.dart';

class TelaAtividades extends ConsumerWidget {
  const TelaAtividades({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pet = ref.watch(petAtualProvider);
    if (pet == null) {
      return const PaTelaPrincipal(
        titulo: 'Atividades',
        subtitulo: 'Pequenos momentos juntos.',
      );
    }
    final agora = ref.watch(agoraProvider)();
    final hoje = DateTime(agora.year, agora.month, agora.day);
    final semana = DateTime(hoje.year, hoje.month, hoje.day - 7);
    final estado = ref.watch(atividadesProvider(pet.id));
    final atividades =
        (estado.value ?? [])
            .where((a) => a.petId == pet.id && !a.dataHora.isAfter(agora))
            .toList()
          ..sort((a, b) => a.dataHora.compareTo(b.dataHora));
    final atuais = atividades.where((a) => !a.dataHora.isBefore(hoje)).toList();
    final anteriores = atividades
        .where((a) => a.dataHora.isBefore(hoje) && !a.dataHora.isBefore(semana))
        .toList()
        .reversed
        .toList();
    final dica = dicaDoDia(
      ref.watch(dicasProvider).value ?? [],
      pet.especie,
      hoje,
    );

    Widget historico(List<Atividade> lista, {bool comData = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final a in lista)
          PaHistorico(
            texto:
                '${comData ? '${formatarDiaMes(a.dataHora)} • ' : ''}${formatarHora(a.dataHora)} • '
                '${nomeTipoAtividade(a.tipo)} • ${a.duracaoMin} min',
            rotuloSemantico:
                'Editar registro: ${formatarDataCurta(a.dataHora)}, ${formatarHora(a.dataHora)}, '
                '${nomeTipoAtividade(a.tipo)}, ${a.duracaoMin} minutos',
            aoTocar: () => abrirAtividade(context, petId: pet.id, atividade: a),
          ),
      ],
    );

    return PaTelaPrincipal(
      titulo: 'Atividades',
      subtitulo: 'Pequenos momentos juntos.',
      filhos: [
        PaCard(
          titulo: 'Hoje',
          texto: estado.hasError
              ? 'Não foi possível carregar. Tente novamente.'
              : estado.isLoading && !estado.hasValue
              ? null
              : atuais.isEmpty
              ? 'Nenhuma atividade hoje.'
              : null,
          filhos: [
            if (estado.hasError)
              PaBotao.secundario(
                texto: 'Tentar novamente',
                aoTocar: () => ref.invalidate(atividadesPeriodoProvider),
              ),
            if (atuais.isNotEmpty) historico(atuais),
            if (atuais.isNotEmpty)
              PaBotao.secundario(
                texto: 'Editar atividade',
                aoTocar: () => abrirAtividade(
                  context,
                  petId: pet.id,
                  atividade: atuais.last,
                ),
              ),
          ],
        ),
        if (anteriores.isNotEmpty)
          PaCard(
            titulo: 'Anteriores',
            filhos: [historico(anteriores, comData: true)],
          ),
        PaCard(
          titulo: 'Novo momento',
          texto: 'Passeio ou brincadeira, sem GPS.',
          filhos: [
            PaBotao.secundario(
              texto: 'Registrar atividade',
              aoTocar: () => abrirAtividade(context, petId: pet.id),
            ),
          ],
        ),
        if (dica != null)
          PaCard(
            titulo: pet.especie == Especie.gato
                ? 'Dica para gatos'
                : 'Dica para cães',
            filhos: [
              Text(
                '${dica.texto}\n${dica.emRevisao ? 'Conteúdo educativo em revisão.\n' : ''}'
                'Fonte: ${dica.fonte} • ${DateFormat('MMM y', localeApp).format(dica.revisadoEm)}',
                style: PaTexto.corpo,
              ),
            ],
          ),
      ],
    );
  }
}
