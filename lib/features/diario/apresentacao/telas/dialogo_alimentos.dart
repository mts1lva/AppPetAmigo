import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/cores.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/formato.dart';
import '../../../../core/relogio.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/energia.dart';
import '../../domain/entidades/alimento.dart';
import '../../domain/entidades/petisco.dart';
import '../../domain/textos_diario.dart';
import '../formulario.dart';
import '../providers/casos_providers.dart';
import '../providers/repositorios_providers.dart';
import 'dialogo_confira_densidade.dart';

const _idNovo = '__novo__';

/// Estado do formulário 09, para a tela 22 devolver o foco na densidade.
final class RascunhoAlimento {
  const RascunhoAlimento({
    this.id,
    this.nome = '',
    this.densidadeTexto = '',
    this.porcaoTexto = '',
    this.novo = true,
  });

  final String? id;
  final String nome;
  final String densidadeTexto;
  final String porcaoTexto;
  final bool novo;
}

/// Abre o 09 Alimentos e porções. Densidade ≤ 0 abre o 22; "Corrigir valor"
/// reabre o 09 com os campos preservados e foco na densidade.
Future<void> abrirAlimentos(
  BuildContext context, {
  required String petId,
  bool paraAtalho = false,
  RascunhoAlimento? rascunho,
  bool focarDensidade = false,
}) async {
  var atual = rascunho;
  var focar = focarDensidade;
  while (true) {
    if (!context.mounted) return;
    final saida = await mostrarPaDialogo<RascunhoAlimento?>(
      context,
      builder: (_) => DialogoAlimentos(
        petId: petId,
        paraAtalho: paraAtalho,
        rascunho: atual,
        focarDensidade: focar,
      ),
    );
    if (!context.mounted) return;
    if (saida == null) return;
    final corrigir = await mostrarPaDialogo<bool>(
      context,
      builder: (_) => DialogoConfiraDensidade(densidadeTexto: saida.densidadeTexto),
    );
    if (corrigir == true && context.mounted) {
      atual = saida;
      focar = true;
      continue;
    }
    return;
  }
}

/// Tela 09 Alimentos e porções (`pacote-2` → 09).
class DialogoAlimentos extends ConsumerStatefulWidget {
  const DialogoAlimentos({
    super.key,
    required this.petId,
    this.paraAtalho = false,
    this.rascunho,
    this.focarDensidade = false,
  });

  final String petId;
  final bool paraAtalho;
  final RascunhoAlimento? rascunho;
  final bool focarDensidade;

  @override
  ConsumerState<DialogoAlimentos> createState() => _DialogoAlimentosState();
}

class _DialogoAlimentosState extends ConsumerState<DialogoAlimentos> {
  final _nome = TextEditingController();
  final _densidade = TextEditingController();
  final _porcao = TextEditingController();
  final _kcalUnidade = TextEditingController();
  final _unidades = TextEditingController();
  final _focoNome = FocusNode();
  final _focoDensidade = FocusNode();
  final _focoPorcao = FocusNode();
  final _focoKcalUnidade = FocusNode();
  final _focoUnidades = FocusNode();
  final _chaveNome = GlobalKey();
  final _chavePorcao = GlobalKey();
  final _chaveKcalUnidade = GlobalKey();
  final _chaveUnidades = GlobalKey();

  /// Tipo do alimento (P-32). A lista mostra só os do tipo escolhido; trocar
  /// o tipo volta para "Novo alimento…", então um alimento salvo não muda de
  /// tipo.
  var _petisco = false;
  String _idSelecionado = _idNovo;
  String? _erroNome;
  String? _erroPorcao;
  String? _erroKcalUnidade;
  String? _erroUnidades;
  String? _erroGravacao;
  var _salvando = false;
  var _excluindo = false;

  bool get _novo => _idSelecionado == _idNovo;

  @override
  void initState() {
    super.initState();
    final r = widget.rascunho;
    if (r != null) {
      _idSelecionado = r.novo ? _idNovo : (r.id ?? _idNovo);
      _nome.text = r.nome;
      _densidade.text = r.densidadeTexto;
      _porcao.text = r.porcaoTexto;
    }
    if (widget.focarDensidade) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focoDensidade.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _nome.dispose();
    _densidade.dispose();
    _porcao.dispose();
    _kcalUnidade.dispose();
    _unidades.dispose();
    _focoNome.dispose();
    _focoDensidade.dispose();
    _focoPorcao.dispose();
    _focoKcalUnidade.dispose();
    _focoUnidades.dispose();
    super.dispose();
  }

  RascunhoAlimento _rascunho() => RascunhoAlimento(
        id: _novo ? null : _idSelecionado,
        nome: _nome.text,
        densidadeTexto: _densidade.text,
        porcaoTexto: _porcao.text,
        novo: _novo,
      );

  void _escolherTipo(bool petisco) {
    if (petisco == _petisco) return;
    setState(() {
      _petisco = petisco;
      _idSelecionado = _idNovo;
      _erroNome = null;
      _erroPorcao = null;
      _erroKcalUnidade = null;
      _erroUnidades = null;
      _erroGravacao = null;
      for (final c in [_nome, _densidade, _porcao, _kcalUnidade, _unidades]) {
        c.clear();
      }
    });
  }

  void _escolherPetisco(String id, List<Petisco> petiscos) {
    setState(() {
      _idSelecionado = id;
      _erroNome = null;
      if (id == _idNovo) {
        _nome.clear();
        return;
      }
      for (final p in petiscos) {
        if (p.id != id) continue;
        _nome.text = p.nome;
        _kcalUnidade.text = textoNumeroCampo(p.kcalPorUnidade);
        _unidades.text = '${p.unidadesHabituais}';
        return;
      }
    });
  }

  void _escolher(String id, List<Alimento> alimentos) {
    setState(() {
      _idSelecionado = id;
      _erroNome = null;
      if (id == _idNovo) {
        _nome.clear();
        return;
      }
      for (final a in alimentos) {
        if (a.id != id) continue;
        _nome.text = a.nome;
        _densidade.text = textoNumeroCampo(a.densidadeKcalPor100g);
        _porcao.text = textoNumeroCampo(a.porcaoPadraoG);
        return;
      }
    });
  }

  void _focar(GlobalKey chave, FocusNode foco) {
    final ctx = chave.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 200));
    foco.requestFocus();
  }

  /// Petisco (P-32): energia por unidade > 0 e unidades inteiras > 0 (R05).
  /// Sem tela 22, que é só da densidade da ração.
  Future<void> _salvarPetisco() async {
    final nome = _nome.text.trim();
    final kcal = lerNumero(_kcalUnidade.text);
    final unidades = lerUnidades(_unidades.text);
    final erroNome = _novo && nome.isEmpty ? mensagemInformeNome : null;
    final erroKcal = kcal == null || kcal <= 0 ? motivoEnergiaPorUnidadeInvalida : null;
    final erroUnidades = unidades == null ? motivoUnidadesInvalidas : null;
    if (erroNome != null || erroKcal != null || erroUnidades != null) {
      setState(() {
        _erroNome = erroNome;
        _erroKcalUnidade = erroKcal;
        _erroUnidades = erroUnidades;
      });
      if (erroNome != null) {
        _focar(_chaveNome, _focoNome);
      } else if (erroKcal != null) {
        _focar(_chaveKcalUnidade, _focoKcalUnidade);
      } else {
        _focar(_chaveUnidades, _focoUnidades);
      }
      return;
    }

    setState(() {
      _salvando = true;
      _erroGravacao = null;
    });
    try {
      final agora = ref.read(agoraProvider)();
      final id = _novo ? ref.read(novoIdProvider)() : _idSelecionado;
      await ref.read(salvarPetiscoProvider)(
        Petisco(id: id, petId: widget.petId, nome: nome, kcalPorUnidade: kcal!, unidadesHabituais: unidades!),
        agora: agora,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _erroGravacao = textoErroGravacao(e));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _salvar() async {
    if (_petisco) return _salvarPetisco();
    final nome = _nome.text.trim();
    final porcao = lerNumero(_porcao.text);
    String? erroNome;
    String? erroPorcao;
    if (_novo && nome.isEmpty) erroNome = mensagemInformeNome;
    if (porcao == null || porcao <= 0) erroPorcao = mensagemQuantidadePositiva;
    if (erroNome != null || erroPorcao != null) {
      setState(() {
        _erroNome = erroNome;
        _erroPorcao = erroPorcao;
      });
      final primeiro = erroNome != null ? _chaveNome : _chavePorcao;
      final ctx = primeiro.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 200));
      if (erroNome != null) {
        _focoNome.requestFocus();
      } else {
        _focoPorcao.requestFocus();
      }
      return;
    }

    final densidade = lerNumero(_densidade.text);
    if (densidade == null || densidade <= 0) {
      Navigator.of(context).pop(_rascunho());
      return;
    }

    setState(() {
      _salvando = true;
      _erroGravacao = null;
    });
    try {
      final agora = ref.read(agoraProvider)();
      final id = _novo ? ref.read(novoIdProvider)() : _idSelecionado;
      await ref.read(salvarAlimentoProvider)(
        Alimento(
          id: id,
          petId: widget.petId,
          nome: nome,
          densidadeKcalPor100g: densidade,
          porcaoPadraoG: porcao!,
        ),
        agora: agora,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _erroGravacao = textoErroGravacao(e));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir() async {
    if (_novo) return;
    final id = _idSelecionado;
    if (!await confirmarExclusao(context)) return;
    if (!mounted) return;
    setState(() {
      _excluindo = true;
      _erroGravacao = null;
    });
    try {
      final agora = ref.read(agoraProvider)();
      if (_petisco) {
        await ref.read(arquivarPetiscoProvider)(id, agora: agora);
      } else {
        await ref.read(arquivarAlimentoProvider)(id, agora: agora);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _erroGravacao = textoErroGravacao(e));
    } finally {
      if (mounted) setState(() => _excluindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final alimentos = ref.watch(alimentosDoPetProvider(widget.petId)).value ?? const <Alimento>[];
    final petiscos = ref.watch(petiscosDoPetProvider(widget.petId)).value ?? const <Petisco>[];
    final opcoes = [
      const PaOpcao(valor: _idNovo, rotulo: rotuloNovoAlimento),
      if (_petisco)
        for (final p in petiscos) PaOpcao(valor: p.id, rotulo: p.nome)
      else
        for (final a in alimentos) PaOpcao(valor: a.id, rotulo: a.nome),
    ];

    return PaDialogo(
      titulo: tituloAlimentos,
      subtitulo: widget.paraAtalho ? subtituloAlimentosAtalho : subtituloAlimentos,
      texto: textoAlimentosFormulario,
      campos: [
        PaCampoEscolha<bool>(
          rotulo: rotuloTipo,
          opcoes: const [
            PaOpcao(valor: false, rotulo: opcaoTipoRacao),
            PaOpcao(valor: true, rotulo: opcaoTipoPetisco),
          ],
          valor: _petisco,
          aoEscolher: _escolherTipo,
        ),
        PaCampoEscolha<String>(
          rotulo: rotuloAlimento,
          opcoes: opcoes,
          valor: _idSelecionado,
          aoEscolher: (id) => _petisco ? _escolherPetisco(id, petiscos) : _escolher(id, alimentos),
        ),
        if (_novo)
          KeyedSubtree(
            key: _chaveNome,
            child: PaCampo(
              rotulo: rotuloAlimento,
              controller: _nome,
              focusNode: _focoNome,
              erro: _erroNome,
              aoMudar: (_) => setState(() => _erroNome = null),
            ),
          ),
        if (_petisco) ...[
          KeyedSubtree(
            key: _chaveKcalUnidade,
            child: PaCampo.numero(
              rotulo: rotuloEnergiaPorUnidade,
              controller: _kcalUnidade,
              focusNode: _focoKcalUnidade,
              erro: _erroKcalUnidade,
              aoMudar: (_) => setState(() => _erroKcalUnidade = null),
            ),
          ),
          KeyedSubtree(
            key: _chaveUnidades,
            child: PaCampo.numero(
              rotulo: rotuloUnidadesHabituais,
              controller: _unidades,
              focusNode: _focoUnidades,
              acaoTeclado: TextInputAction.done,
              erro: _erroUnidades,
              aoMudar: (_) => setState(() => _erroUnidades = null),
            ),
          ),
        ] else ...[
          PaCampo.numero(
            rotulo: rotuloDensidade,
            controller: _densidade,
            focusNode: _focoDensidade,
            sufixo: sufixoKcalPor100g,
            aoMudar: (_) {},
          ),
          KeyedSubtree(
            key: _chavePorcao,
            child: PaCampo.numero(
              rotulo: rotuloPorcaoReutilizavel,
              controller: _porcao,
              focusNode: _focoPorcao,
              sufixo: sufixoGramas,
              acaoTeclado: TextInputAction.done,
              erro: _erroPorcao,
              aoMudar: (_) => setState(() => _erroPorcao = null),
            ),
          ),
        ],
        if (_erroGravacao != null)
          Text(_erroGravacao!, style: PaTexto.corpo.copyWith(color: PaCores.erro)),
      ],
      botoes: [
        PaBotao.primario(
          texto: botaoSalvarAlimento,
          carregando: _salvando,
          aoTocar: _salvar,
        ),
        if (!_novo)
          PaBotao.perigo(
            texto: botaoExcluirAlimento,
            carregando: _excluindo,
            aoTocar: _excluir,
          ),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
