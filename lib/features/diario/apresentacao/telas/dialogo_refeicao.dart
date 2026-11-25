import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/formato/formato.dart';
import '../../../../core/relogio.dart';
import '../../../../core/resultado.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/energia.dart';
import '../../domain/entidades/alimento.dart';
import '../../domain/entidades/refeicao.dart';
import '../../domain/textos_diario.dart';
import '../formulario.dart';
import '../providers/casos_providers.dart';
import '../providers/repositorios_providers.dart';

/// Abre o 07 Refeição: cadastro quando [refeicaoId] é nulo, edição quando não é.
Future<void> abrirRefeicao(
  BuildContext context, {
  required String petId,
  String? refeicaoId,
  DateTime? dia,
  String? alimentoId,
  double? quantidadeG,
  DateTime? dataHora,
  bool focarQuantidade = false,
}) {
  return mostrarPaDialogo<void>(
    context,
    builder: (_) => DialogoRefeicao(
      petId: petId,
      refeicaoId: refeicaoId,
      dia: dia,
      alimentoId: alimentoId,
      quantidadeG: quantidadeG,
      dataHora: dataHora,
      focarQuantidade: focarQuantidade,
    ),
  );
}

/// Tela 07 Refeição (`pacote-2` → 07).
class DialogoRefeicao extends ConsumerStatefulWidget {
  const DialogoRefeicao({
    super.key,
    required this.petId,
    this.refeicaoId,
    this.dia,
    this.alimentoId,
    this.quantidadeG,
    this.dataHora,
    this.focarQuantidade = false,
  });

  final String petId;
  final String? refeicaoId;
  final DateTime? dia;
  final String? alimentoId;
  final double? quantidadeG;
  final DateTime? dataHora;
  final bool focarQuantidade;

  @override
  ConsumerState<DialogoRefeicao> createState() => _DialogoRefeicaoState();
}

class _DialogoRefeicaoState extends ConsumerState<DialogoRefeicao> {
  final _quantidade = TextEditingController();
  final _focoQuantidade = FocusNode();
  final _chaveAlimento = GlobalKey();
  final _chaveQuantidade = GlobalKey();
  final _chaveData = GlobalKey();

  String? _alimentoId;
  String _alimentoNome = '';
  double _densidade = 0;
  DateTime? _data;
  TimeOfDay? _hora;
  String? _erroAlimento;
  String? _erroQuantidade;
  String? _erroData;
  var _salvando = false;
  var _inicio = false;
  var _preenchidoEdicao = false;

  bool get _edicao => widget.refeicaoId != null;

  @override
  void initState() {
    super.initState();
    if (widget.focarQuantidade) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focoQuantidade.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _quantidade.dispose();
    _focoQuantidade.dispose();
    super.dispose();
  }

  void _iniciar(List<Alimento> alimentos) {
    if (!_inicio) {
      _inicio = true;
      final agora = ref.read(agoraProvider)();
      final base = widget.dataHora ?? widget.dia ?? agora;
      _data = DateTime(base.year, base.month, base.day);
      _hora = widget.dataHora != null
          ? TimeOfDay(hour: widget.dataHora!.hour, minute: widget.dataHora!.minute)
          : TimeOfDay(hour: agora.hour, minute: agora.minute);
      if (widget.quantidadeG != null) _quantidade.text = textoNumeroCampo(widget.quantidadeG!);
      _alimentoId = widget.alimentoId;
    }
    if (_alimentoId != null && _alimentoNome.isEmpty) _aplicarAlimento(_alimentoId!, alimentos);
  }

  void _preencher(Refeicao r) {
    _alimentoId = r.alimentoId;
    _alimentoNome = r.alimentoNome;
    _densidade = r.densidadeKcalPor100g;
    _quantidade.text = textoNumeroCampo(r.quantidadeG);
    _data = DateTime(r.dataHora.year, r.dataHora.month, r.dataHora.day);
    _hora = TimeOfDay(hour: r.dataHora.hour, minute: r.dataHora.minute);
    _preenchidoEdicao = true;
  }

  void _aplicarAlimento(String id, List<Alimento> alimentos) {
    for (final a in alimentos) {
      if (a.id != id) continue;
      _alimentoId = a.id;
      _alimentoNome = a.nome;
      _densidade = a.densidadeKcalPor100g;
      _erroAlimento = null;
      return;
    }
  }

  String get _energiaTexto {
    final q = lerNumero(_quantidade.text);
    final r = energiaRefeicao(q ?? 0, _densidade);
    return switch (r) {
      Disponivel(:final valor) => '${formatarEnergia(valor)} $textoEnergiaRotuloSufixo',
      Indisponivel() => '',
    };
  }

  DateTime? get _dataHora {
    final data = _data;
    final hora = _hora;
    if (data == null || hora == null) return null;
    return juntarDataHora(data, hora);
  }

  Future<void> _salvar() async {
    final q = lerNumero(_quantidade.text);
    final quando = _dataHora;
    final agora = ref.read(agoraProvider)();
    String? erroAlimento;
    String? erroQuantidade;
    String? erroData;
    if (_alimentoId == null || _alimentoNome.isEmpty) erroAlimento = '';
    if (q == null || q <= 0) erroQuantidade = mensagemQuantidadePositiva;
    if (quando == null || dataHoraFutura(quando, agora)) erroData = mensagemDataAteHoje;
    if (erroAlimento != null || erroQuantidade != null || erroData != null) {
      setState(() {
        _erroAlimento = erroAlimento;
        _erroQuantidade = erroQuantidade;
        _erroData = erroData;
      });
      final chave = erroAlimento != null
          ? _chaveAlimento
          : erroQuantidade != null
              ? _chaveQuantidade
              : _chaveData;
      final ctx = chave.currentContext;
      if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 200));
      if (erroQuantidade != null) _focoQuantidade.requestFocus();
      return;
    }

    setState(() => _salvando = true);
    try {
      final id = widget.refeicaoId ?? ref.read(novoIdProvider)();
      await ref.read(salvarRefeicaoProvider)(
        Refeicao(
          id: id,
          petId: widget.petId,
          alimentoId: _alimentoId,
          alimentoNome: _alimentoNome,
          densidadeKcalPor100g: _densidade,
          quantidadeG: q!,
          energiaKcal: 0,
          dataHora: quando!,
        ),
        agora: agora,
      );
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir() async {
    final id = widget.refeicaoId;
    if (id == null) return;
    final nav = Navigator.of(context);
    if (!await confirmarExclusao(context)) return;
    nav.pop();
    await ref.read(excluirRefeicaoProvider)(id, agora: ref.read(agoraProvider)());
  }

  @override
  Widget build(BuildContext context) {
    final alimentos = ref.watch(alimentosDoPetProvider(widget.petId)).value ?? const <Alimento>[];
    _iniciar(alimentos);
    if (_edicao && !_preenchidoEdicao) {
      final atual = ref.watch(refeicaoProvider(widget.refeicaoId!)).value;
      if (atual != null) _preencher(atual);
    }
    final opcoes = [for (final a in alimentos) PaOpcao(valor: a.id, rotulo: a.nome)];
    if (_alimentoId != null && !opcoes.any((o) => o.valor == _alimentoId)) {
      opcoes.insert(0, PaOpcao(valor: _alimentoId!, rotulo: _alimentoNome));
    }

    return PaDialogo(
      titulo: tituloRefeicao,
      subtitulo: subtituloRefeicao,
      campos: [
        KeyedSubtree(
          key: _chaveAlimento,
          child: PaCampoEscolha<String>(
            rotulo: rotuloAlimento,
            opcoes: opcoes,
            valor: _alimentoId,
            erro: _erroAlimento,
            aoEscolher: (id) => setState(() => _aplicarAlimento(id, alimentos)),
          ),
        ),
        KeyedSubtree(
          key: _chaveQuantidade,
          child: PaCampo.numero(
            rotulo: rotuloQuantidade,
            controller: _quantidade,
            focusNode: _focoQuantidade,
            sufixo: sufixoGramas,
            erro: _erroQuantidade,
            aoMudar: (_) => setState(() => _erroQuantidade = null),
          ),
        ),
        PaCampoAcao(rotulo: rotuloEnergia, valorTexto: _energiaTexto, aoTocar: null),
        KeyedSubtree(
          key: _chaveData,
          child: PaCampoData(
            rotulo: rotuloData,
            valor: _data,
            erro: _erroData,
            aoEscolher: (d) => setState(() {
              _data = d;
              _erroData = null;
            }),
          ),
        ),
        PaCampoHora(
          rotulo: rotuloHorario,
          valor: _hora,
          aoEscolher: (h) => setState(() {
            _hora = h;
            _erroData = null;
          }),
        ),
      ],
      botoes: [
        PaBotao.primario(texto: botaoSalvarRefeicao, carregando: _salvando, aoTocar: _salvar),
        if (_edicao) PaBotao.perigo(texto: botaoExcluirRegistro, aoTocar: _excluir),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
