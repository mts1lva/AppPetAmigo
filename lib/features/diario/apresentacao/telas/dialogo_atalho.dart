import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/cores.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/formato.dart';
import '../../../../core/relogio.dart';
import '../../../../core/resultado.dart';
import '../../../../core/ui/ui.dart';
import '../../../nutricao/apresentacao/providers/meta_provider.dart';
import '../../../nutricao/domain/meta_diaria.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/energia.dart';
import '../../domain/entidades/alimento.dart';
import '../../domain/entidades/extra.dart';
import '../../domain/entidades/petisco.dart';
import '../../domain/repositorios/alimento_repositorio.dart';
import '../../domain/entidades/refeicao.dart';
import '../../domain/entidades/resumo_dia.dart';
import '../../domain/periodo.dart';
import '../../domain/resumo_do_dia.dart';
import '../../domain/textos_diario.dart';
import '../formulario.dart';
import '../providers/alimento_atalho_provider.dart';
import '../providers/casos_providers.dart';
import '../providers/repositorios_providers.dart';
import 'dialogo_alimentos.dart';
import 'dialogo_petisco.dart';
import 'dialogo_refeicao.dart';
import 'dialogo_refeicao_salva.dart';

enum _PorcaoAtalho { habitual, metade, umaEMeia, outra }

/// Porções do petisco cadastrado no 06 (P-32).
enum _PorcaoPetisco { habitual, uma, outra }

sealed class _SaidaAtalho {
  const _SaidaAtalho();
}

final class _Confirmado extends _SaidaAtalho {
  const _Confirmado(this.antesKcal, this.depois, {this.petisco = false});
  final double antesKcal;
  final ResumoDia depois;

  /// Gravou um petisco (P-32): o 20 abre com o título "Petisco salvo".
  final bool petisco;
}

final class _AlterarPetisco extends _SaidaAtalho {
  const _AlterarPetisco(this.petisco, this.unidades);
  final Petisco petisco;
  final int unidades;
}

final class _OutraQuantidadePetisco extends _SaidaAtalho {
  const _OutraQuantidadePetisco(this.petisco);
  final Petisco petisco;
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
    case _Confirmado(:final antesKcal, :final depois, :final petisco):
      await abrirRefeicaoSalva(
        context,
        antesKcal: antesKcal,
        depois: depois,
        titulo: petisco ? tituloPetiscoSalvo : tituloRefeicaoSalva,
      );
    case _AlterarPetisco(:final petisco, :final unidades):
      await abrirPetisco(context, petId: petId, petiscoId: petisco.id, unidades: unidades);
    case _OutraQuantidadePetisco(:final petisco):
      await abrirPetisco(context, petId: petId, petiscoId: petisco.id, focarUnidades: true);
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
  _PorcaoPetisco _porcaoPetisco = _PorcaoPetisco.habitual;
  var _salvando = false;
  var _inicio = false;
  String? _erroGravacao;

  /// Pré-seleciona o alimento do atalho uma vez só. Espera o
  /// [alimentoAtalhoProvider] responder (valor ou erro): se a lista chegasse
  /// antes, a escolha travaria num alimento que não é o do atalho. Sem
  /// atalho, o último cadastrado, que é o primeiro da lista
  /// ([AlimentoRepositorio.observarDoPet] vem do mais recente ao mais antigo).
  ///
  /// O atalho é sempre uma ração. Só sem nenhuma ração o 06 começa num
  /// petisco cadastrado (P-32), o mais recente.
  void _iniciar(AsyncValue<Alimento?> atalho, List<Alimento>? alimentos, List<Petisco>? petiscos) {
    if (_inicio) return;
    if (alimentos == null || petiscos == null || (!atalho.hasValue && !atalho.hasError)) return;
    final escolhido = atalho.value?.id ??
        (alimentos.isNotEmpty ? alimentos.first.id : (petiscos.isNotEmpty ? petiscos.first.id : null));
    if (escolhido == null) return;
    _inicio = true;
    _alimentoId = escolhido;
  }

  Petisco? _petisco(List<Petisco> petiscos) {
    final id = _alimentoId;
    if (id == null) return null;
    for (final p in petiscos) {
      if (p.id == id) return p;
    }
    return null;
  }

  int _unidades(Petisco p) => switch (_porcaoPetisco) {
        _PorcaoPetisco.uma => 1,
        _PorcaoPetisco.habitual || _PorcaoPetisco.outra => p.unidadesHabituais,
      };

  void _escolherItem(String id) => setState(() {
        _alimentoId = id;
        _porcao = _PorcaoAtalho.habitual;
        _porcaoPetisco = _PorcaoPetisco.habitual;
      });

  /// Rações e, depois, os petiscos cadastrados com "(petisco)" (P-32).
  List<PaOpcao<String>> _itens(List<Alimento> alimentos, List<Petisco> petiscos) => [
        for (final a in alimentos) PaOpcao(valor: a.id, rotulo: a.nome),
        for (final p in petiscos) PaOpcao(valor: p.id, rotulo: rotuloPetiscoNaLista(p.nome)),
      ];

  /// 2º toque com um petisco (P-32): grava um **extra**, não uma refeição.
  Future<void> _confirmarPetisco(Petisco p) async {
    final unidades = _unidades(p);
    final energia = energiaPetisco(unidades, p.kcalPorUnidade);
    if (energia is! Disponivel<double>) return;
    final agora = ref.read(agoraProvider)();
    final hoje = diaDe(agora);
    final fim = somarDias(hoje, 1);

    setState(() {
      _salvando = true;
      _erroGravacao = null;
    });
    try {
      final refeicoes = await ref.read(refeicaoRepositorioProvider).observarEntre(widget.petId, hoje, fim).first;
      final extras = await ref.read(extraRepositorioProvider).observarEntre(widget.petId, hoje, fim).first;
      final antes = resumoDoDia(dia: hoje, refeicoes: refeicoes, extras: extras);
      final novo = Extra(
        id: ref.read(novoIdProvider)(),
        petId: widget.petId,
        descricao: p.nome,
        energiaKcal: energia.valor,
        dataHora: agora,
        alimentoId: p.id,
        unidades: unidades,
      );
      await ref.read(salvarExtraProvider)(novo, agora: agora);
      if (!mounted) return;
      final depois = resumoDoDia(dia: hoje, refeicoes: refeicoes, extras: [...extras, novo]);
      Navigator.of(context).pop(_Confirmado(antes.totalKcal, depois, petisco: true));
    } catch (e) {
      if (mounted) setState(() => _erroGravacao = textoErroGravacao(e));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Widget _construirPetisco(BuildContext context, Petisco p, List<Alimento> alimentos, List<Petisco> petiscos) {
    final agora = ref.watch(agoraProvider)();
    final meta = ref.watch(metaProvider(widget.petId));
    final linhaMeta = textoMetaNoAtalho(meta, null);
    final kcalHab = energiaPetisco(p.unidadesHabituais, p.kcalPorUnidade).valorOuNulo ?? 0;
    final kcalUma = energiaPetisco(1, p.kcalPorUnidade).valorOuNulo ?? 0;

    return PaDialogo(
      titulo: tituloAtalho,
      subtitulo: subtituloAtalho,
      texto: [
        textoEnergiaRotuloPetisco(p.kcalPorUnidade),
        ?linhaMeta,
      ].join('\n'),
      campos: [
        PaCampoEscolha<String>(
          rotulo: rotuloAlimento,
          opcoes: _itens(alimentos, petiscos),
          valor: p.id,
          aoEscolher: _escolherItem,
        ),
        PaCampoEscolha<_PorcaoPetisco>(
          rotulo: rotuloCampoPorcao,
          opcoes: [
            PaOpcao(
              valor: _PorcaoPetisco.habitual,
              rotulo: rotuloPorcaoPetiscoHabitual(p.unidadesHabituais, kcalHab),
            ),
            if (p.unidadesHabituais > 1) PaOpcao(valor: _PorcaoPetisco.uma, rotulo: rotuloPorcaoPetiscoUma(kcalUma)),
            const PaOpcao(valor: _PorcaoPetisco.outra, rotulo: rotuloOutraQuantidade),
          ],
          valor: _porcaoPetisco,
          aoEscolher: (escolha) {
            if (escolha == _PorcaoPetisco.outra) {
              Navigator.of(context).pop(_OutraQuantidadePetisco(p));
              return;
            }
            setState(() => _porcaoPetisco = escolha);
          },
        ),
        PaCampoAcao(
          rotulo: rotuloDataHora,
          valorTexto: '${formatarDataCurta(agora)} • agora',
          aoTocar: null,
        ),
        if (_erroGravacao != null)
          Text(_erroGravacao!, style: PaTexto.corpo.copyWith(color: PaCores.erro)),
      ],
      botoes: [
        PaBotao.primario(
          texto: botaoConfirmarPetisco,
          carregando: _salvando,
          aoTocar: () => _confirmarPetisco(p),
        ),
        PaBotao.primario(
          texto: botaoAlterarDados,
          aoTocar: () => Navigator.of(context).pop(_AlterarPetisco(p, _unidades(p))),
        ),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
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
    final inicio = hoje;
    final fim = somarDias(inicio, 1);

    setState(() {
      _salvando = true;
      _erroGravacao = null;
    });
    try {
      // `.first` espera a primeira emissão. Não usa `.value ?? []` (trataria
      // loading/erro como dia vazio) nem StreamProvider.future (espera o
      // stream fechar e trava o diálogo em "Salvando…").
      final refeicoes =
          await ref.read(refeicaoRepositorioProvider).observarEntre(widget.petId, inicio, fim).first;
      final extras = await ref.read(extraRepositorioProvider).observarEntre(widget.petId, inicio, fim).first;
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
      await ref.read(salvarRefeicaoProvider)(nova, agora: agora);
      if (!mounted) return;
      final depois = resumoDoDia(dia: hoje, refeicoes: [...refeicoes, nova], extras: extras);
      Navigator.of(context).pop(_Confirmado(antes.totalKcal, depois));
    } catch (e) {
      if (mounted) setState(() => _erroGravacao = textoErroGravacao(e));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lista = ref.watch(alimentosDoPetProvider(widget.petId)).value;
    final alimentos = lista ?? const <Alimento>[];
    final listaPetiscos = ref.watch(petiscosDoPetProvider(widget.petId)).value;
    final petiscos = listaPetiscos ?? const <Petisco>[];
    _iniciar(ref.watch(alimentoAtalhoProvider(widget.petId)), lista, listaPetiscos);
    final petisco = _petisco(petiscos);
    if (petisco != null) return _construirPetisco(context, petisco, alimentos, petiscos);
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
          opcoes: _itens(alimentos, petiscos),
          valor: alimento.id,
          aoEscolher: _escolherItem,
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
        if (_erroGravacao != null)
          Text(_erroGravacao!, style: PaTexto.corpo.copyWith(color: PaCores.erro)),
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
