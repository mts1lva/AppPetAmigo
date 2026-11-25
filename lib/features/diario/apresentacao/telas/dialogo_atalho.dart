import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/formato/formato.dart';
import '../../../../core/relogio.dart';
import '../../../../core/resultado.dart';
import '../../../../core/ui/ui.dart';
import '../../../nutricao/apresentacao/providers/meta_provider.dart';
import '../../../nutricao/domain/meta_diaria.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/energia.dart';
import '../../domain/entidades/alimento.dart';
import '../../domain/entidades/refeicao.dart';
import '../../domain/entidades/resumo_dia.dart';
import '../../domain/periodo.dart';
import '../../domain/resumo_do_dia.dart';
import '../../domain/textos_diario.dart';
import '../providers/alimento_atalho_provider.dart';
import '../providers/casos_providers.dart';
import '../providers/repositorios_providers.dart';
import 'dialogo_alimentos.dart';
import 'dialogo_refeicao.dart';
import 'dialogo_refeicao_salva.dart';

enum _PorcaoAtalho { habitual, metade, umaEMeia, outra }

sealed class _SaidaAtalho {
  const _SaidaAtalho();
}

final class _Confirmado extends _SaidaAtalho {
  const _Confirmado(this.antesKcal, this.depois);
  final double antesKcal;
  final ResumoDia depois;
}

final class _Alterar extends _SaidaAtalho {
  const _Alterar(this.alimento, this.quantidadeG);
  final Alimento alimento;
  final double quantidadeG;
}

final class _OutraQuantidade extends _SaidaAtalho {
  const _OutraQuantidade(this.alimento);
  final Alimento alimento;
}

final class _CadastrarAlimento extends _SaidaAtalho {
  const _CadastrarAlimento();
}

/// Abre o 06 Registrar refeição. Sem alimento, abre o 09.
Future<void> abrirAtalho(BuildContext context, {required String petId}) async {
  final saida = await mostrarPaDialogo<_SaidaAtalho>(
    context,
    builder: (_) => DialogoAtalho(petId: petId),
  );
  if (!context.mounted || saida == null) return;
  switch (saida) {
    case _Confirmado(:final antesKcal, :final depois):
      await abrirRefeicaoSalva(context, antesKcal: antesKcal, depois: depois);
    case _Alterar(:final alimento, :final quantidadeG):
      await abrirRefeicao(context, petId: petId, alimentoId: alimento.id, quantidadeG: quantidadeG);
    case _OutraQuantidade(:final alimento):
      await abrirRefeicao(
        context,
        petId: petId,
        alimentoId: alimento.id,
        quantidadeG: alimento.porcaoPadraoG,
        focarQuantidade: true,
      );
    case _CadastrarAlimento():
      await abrirAlimentos(context, petId: petId, paraAtalho: true);
  }
}

/// Tela 06 Registrar refeição (`pacote-2` → 06; briefing B-b).
class DialogoAtalho extends ConsumerStatefulWidget {
  const DialogoAtalho({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<DialogoAtalho> createState() => _DialogoAtalhoState();
}

class _DialogoAtalhoState extends ConsumerState<DialogoAtalho> {
  String? _alimentoId;
  _PorcaoAtalho _porcao = _PorcaoAtalho.habitual;
  var _salvando = false;
  var _inicio = false;

  void _iniciar(Alimento? atalho, List<Alimento> alimentos) {
    if (_inicio) return;
    if (atalho == null && alimentos.isEmpty) return;
    _inicio = true;
    _alimentoId = atalho?.id ?? alimentos.last.id;
  }

  Alimento? _alimento(List<Alimento> alimentos) {
    final id = _alimentoId;
    if (id == null) return null;
    for (final a in alimentos) {
      if (a.id == id) return a;
    }
    return null;
  }

  double _gramas(Alimento a) => switch (_porcao) {
        _PorcaoAtalho.habitual => a.porcaoPadraoG,
        _PorcaoAtalho.metade => a.porcaoPadraoG / 2,
        _PorcaoAtalho.umaEMeia => a.porcaoPadraoG * 1.5,
        _PorcaoAtalho.outra => a.porcaoPadraoG,
      };

  Future<void> _confirmar(Alimento a) async {
    final q = _gramas(a);
    final energia = energiaRefeicao(q, a.densidadeKcalPor100g);
    if (energia is! Disponivel<double>) return;
    final agora = ref.read(agoraProvider)();
    final hoje = diaDe(agora);
    final refeicoes = ref.read(refeicoesDoDiaProvider((widget.petId, hoje))).value ?? const [];
    final extras = ref.read(extrasDoDiaProvider((widget.petId, hoje))).value ?? const [];
    final antes = resumoDoDia(dia: hoje, refeicoes: refeicoes, extras: extras);
    final nova = Refeicao(
      id: ref.read(novoIdProvider)(),
      petId: widget.petId,
      alimentoId: a.id,
      alimentoNome: a.nome,
      densidadeKcalPor100g: a.densidadeKcalPor100g,
      quantidadeG: q,
      energiaKcal: energia.valor,
      dataHora: agora,
    );

    setState(() => _salvando = true);
    try {
      await ref.read(salvarRefeicaoProvider)(nova, agora: agora);
      if (!mounted) return;
      final depois = resumoDoDia(dia: hoje, refeicoes: [...refeicoes, nova], extras: extras);
      Navigator.of(context).pop(_Confirmado(antes.totalKcal, depois));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alimentos = ref.watch(alimentosDoPetProvider(widget.petId)).value ?? const <Alimento>[];
    final atalho = ref.watch(alimentoAtalhoProvider(widget.petId)).value;
    _iniciar(atalho, alimentos);
    final alimento = _alimento(alimentos);
    if (alimento == null) {
      return PaDialogo(
        titulo: tituloAtalho,
        subtitulo: subtituloAlimentosAtalho,
        texto: textoAlimentosFormulario,
        botoes: [
          PaBotao.primario(
            texto: botaoGerenciarAlimentos,
            aoTocar: () => Navigator.of(context).pop(const _CadastrarAlimento()),
          ),
          PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
        ],
      );
    }

    final agora = ref.watch(agoraProvider)();
    final meta = ref.watch(metaProvider(widget.petId));
    final gramasDaMeta = switch (meta) {
      Disponivel(:final valor) => gramas(valor.mer, alimento.densidadeKcalPor100g),
      _ => null,
    };
    final linhaMeta = textoMetaNoAtalho(meta, gramasDaMeta);
    final kcalHab = energiaRefeicao(alimento.porcaoPadraoG, alimento.densidadeKcalPor100g).valorOuNulo ?? 0;
    final kcalMetade = energiaRefeicao(alimento.porcaoPadraoG / 2, alimento.densidadeKcalPor100g).valorOuNulo ?? 0;
    final kcalUma = energiaRefeicao(alimento.porcaoPadraoG * 1.5, alimento.densidadeKcalPor100g).valorOuNulo ?? 0;

    return PaDialogo(
      titulo: tituloAtalho,
      subtitulo: subtituloAtalho,
      texto: [
        textoEnergiaRotulo(alimento.densidadeKcalPor100g),
        ?linhaMeta,
      ].join('\n'),
      campos: [
        PaCampoEscolha<String>(
          rotulo: rotuloAlimento,
          opcoes: [for (final a in alimentos) PaOpcao(valor: a.id, rotulo: a.nome)],
          valor: alimento.id,
          aoEscolher: (id) => setState(() {
            _alimentoId = id;
            _porcao = _PorcaoAtalho.habitual;
          }),
        ),
        PaCampoEscolha<_PorcaoAtalho>(
          rotulo: rotuloCampoPorcao,
          opcoes: [
            PaOpcao(
              valor: _PorcaoAtalho.habitual,
              rotulo: rotuloPorcao(rotuloPorcaoHabitual, alimento.porcaoPadraoG, kcalHab),
            ),
            PaOpcao(
              valor: _PorcaoAtalho.metade,
              rotulo: rotuloPorcao(rotuloPorcaoMetade, alimento.porcaoPadraoG / 2, kcalMetade),
            ),
            PaOpcao(
              valor: _PorcaoAtalho.umaEMeia,
              rotulo: rotuloPorcao(rotuloPorcaoUmaEMeia, alimento.porcaoPadraoG * 1.5, kcalUma),
            ),
            const PaOpcao(valor: _PorcaoAtalho.outra, rotulo: rotuloOutraQuantidade),
          ],
          valor: _porcao,
          aoEscolher: (p) {
            if (p == _PorcaoAtalho.outra) {
              Navigator.of(context).pop(_OutraQuantidade(alimento));
              return;
            }
            setState(() => _porcao = p);
          },
        ),
        PaCampoAcao(
          rotulo: rotuloDataHora,
          valorTexto: '${formatarDataCurta(agora)} • agora',
          aoTocar: null,
        ),
      ],
      botoes: [
        PaBotao.primario(
          texto: botaoConfirmarRefeicao,
          carregando: _salvando,
          aoTocar: () => _confirmar(alimento),
        ),
        PaBotao.primario(
          texto: botaoAlterarDados,
          aoTocar: () => Navigator.of(context).pop(_Alterar(alimento, _gramas(alimento))),
        ),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
