import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/formato/formato.dart';
import '../../../../core/relogio.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/entidades/alimento.dart';
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
  final _focoNome = FocusNode();
  final _focoDensidade = FocusNode();
  final _focoPorcao = FocusNode();
  final _chaveNome = GlobalKey();
  final _chavePorcao = GlobalKey();

  String _idSelecionado = _idNovo;
  String? _erroNome;
  String? _erroPorcao;
  var _salvando = false;

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
    _focoNome.dispose();
    _focoDensidade.dispose();
    _focoPorcao.dispose();
    super.dispose();
  }

  RascunhoAlimento _rascunho() => RascunhoAlimento(
        id: _novo ? null : _idSelecionado,
        nome: _nome.text,
        densidadeTexto: _densidade.text,
        porcaoTexto: _porcao.text,
        novo: _novo,
      );

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

  Future<void> _salvar() async {
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

    setState(() => _salvando = true);
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
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir() async {
    if (_novo) return;
    final id = _idSelecionado;
    final nav = Navigator.of(context);
    if (!await confirmarExclusao(context)) return;
    nav.pop();
    await ref.read(arquivarAlimentoProvider)(id, agora: ref.read(agoraProvider)());
  }

  @override
  Widget build(BuildContext context) {
    final alimentos = ref.watch(alimentosDoPetProvider(widget.petId)).value ?? const <Alimento>[];
    final opcoes = [
      const PaOpcao(valor: _idNovo, rotulo: rotuloNovoAlimento),
      for (final a in alimentos) PaOpcao(valor: a.id, rotulo: a.nome),
    ];

    return PaDialogo(
      titulo: tituloAlimentos,
      subtitulo: widget.paraAtalho ? subtituloAlimentosAtalho : subtituloAlimentos,
      texto: textoAlimentosFormulario,
      campos: [
        PaCampoEscolha<String>(
          rotulo: rotuloAlimento,
          opcoes: opcoes,
          valor: _idSelecionado,
          aoEscolher: (id) => _escolher(id, alimentos),
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
      botoes: [
        PaBotao.primario(
          texto: botaoSalvarAlimento,
          carregando: _salvando,
          aoTocar: _salvar,
        ),
        if (!_novo) PaBotao.perigo(texto: botaoExcluirAlimento, aoTocar: _excluir),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
