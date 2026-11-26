import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/cores.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/numeros.dart';
import '../../../../core/relogio.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/entidades/extra.dart';
import '../../domain/textos_diario.dart';
import '../formulario.dart';
import '../providers/casos_providers.dart';
import '../providers/repositorios_providers.dart';

/// Abre o 08 Petisco ou extra.
Future<void> abrirPetisco(
  BuildContext context, {
  required String petId,
  String? extraId,
  DateTime? dia,
}) {
  return mostrarPaDialogo<void>(
    context,
    builder: (_) => DialogoPetisco(petId: petId, extraId: extraId, dia: dia),
  );
}

/// Tela 08 Petisco ou extra (`pacote-2` → 08).
class DialogoPetisco extends ConsumerStatefulWidget {
  const DialogoPetisco({super.key, required this.petId, this.extraId, this.dia});

  final String petId;
  final String? extraId;
  final DateTime? dia;

  @override
  ConsumerState<DialogoPetisco> createState() => _DialogoPetiscoState();
}

class _DialogoPetiscoState extends ConsumerState<DialogoPetisco> {
  final _descricao = TextEditingController(text: descricaoPetiscoPadrao);
  final _quantidade = TextEditingController();
  final _energia = TextEditingController();
  final _focoEnergia = FocusNode();
  final _chaveEnergia = GlobalKey();
  final _chaveData = GlobalKey();

  DateTime? _data;
  TimeOfDay? _hora;
  String? _erroQuantidade;
  String? _erroEnergia;
  String? _erroData;
  String? _erroGravacao;
  var _salvando = false;
  var _excluindo = false;
  var _inicio = false;
  var _preenchidoEdicao = false;

  bool get _edicao => widget.extraId != null;

  @override
  void dispose() {
    _descricao.dispose();
    _quantidade.dispose();
    _energia.dispose();
    _focoEnergia.dispose();
    super.dispose();
  }

  void _iniciar() {
    if (_inicio) return;
    _inicio = true;
    final agora = ref.read(agoraProvider)();
    final base = widget.dia ?? agora;
    _data = DateTime(base.year, base.month, base.day);
    _hora = TimeOfDay(hour: agora.hour, minute: agora.minute);
  }

  void _preencher(Extra e) {
    _descricao.text = e.descricao;
    _quantidade.text = e.quantidadeG == null ? '' : textoNumeroCampo(e.quantidadeG!);
    _energia.text = textoNumeroCampo(e.energiaKcal);
    _data = DateTime(e.dataHora.year, e.dataHora.month, e.dataHora.day);
    _hora = TimeOfDay(hour: e.dataHora.hour, minute: e.dataHora.minute);
    _preenchidoEdicao = true;
  }

  DateTime? get _dataHora {
    final data = _data;
    final hora = _hora;
    if (data == null || hora == null) return null;
    return juntarDataHora(data, hora);
  }

  Future<void> _salvar() async {
    final qTexto = _quantidade.text.trim();
    final q = qTexto.isEmpty ? null : lerNumero(_quantidade.text);
    final kcal = lerNumero(_energia.text);
    final quando = _dataHora;
    final agora = ref.read(agoraProvider)();
    String? erroQuantidade;
    String? erroEnergia;
    String? erroData;
    if (qTexto.isNotEmpty && (q == null || q <= 0)) erroQuantidade = mensagemQuantidadePositiva;
    if (kcal == null || kcal <= 0) erroEnergia = mensagemInformeEnergia;
    if (quando == null || dataHoraFutura(quando, agora)) erroData = mensagemDataAteHoje;
    if (erroQuantidade != null || erroEnergia != null || erroData != null) {
      setState(() {
        _erroQuantidade = erroQuantidade;
        _erroEnergia = erroEnergia;
        _erroData = erroData;
      });
      if (erroEnergia != null) {
        final ctx = _chaveEnergia.currentContext;
        if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 200));
        _focoEnergia.requestFocus();
      }
      return;
    }

    setState(() {
      _salvando = true;
      _erroGravacao = null;
    });
    try {
      final id = widget.extraId ?? ref.read(novoIdProvider)();
      await ref.read(salvarExtraProvider)(
        Extra(
          id: id,
          petId: widget.petId,
          descricao: _descricao.text,
          quantidadeG: q,
          energiaKcal: kcal!,
          dataHora: quando!,
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
    final id = widget.extraId;
    if (id == null) return;
    if (!await confirmarExclusao(context)) return;
    if (!mounted) return;
    setState(() {
      _excluindo = true;
      _erroGravacao = null;
    });
    try {
      await ref.read(excluirExtraProvider)(id, agora: ref.read(agoraProvider)());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _erroGravacao = textoErroGravacao(e));
    } finally {
      if (mounted) setState(() => _excluindo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    _iniciar();
    if (_edicao && !_preenchidoEdicao) {
      final atual = ref.watch(extraProvider((widget.petId, widget.extraId!))).value;
      if (atual != null) _preencher(atual);
    }

    return PaDialogo(
      titulo: tituloPetisco,
      subtitulo: subtituloPetisco,
      campos: [
        PaCampo(
          rotulo: rotuloDescricao,
          controller: _descricao,
          aoMudar: (_) {},
        ),
        PaCampo.numero(
          rotulo: rotuloQuantidade,
          controller: _quantidade,
          sufixo: sufixoGramas,
          erro: _erroQuantidade,
          aoMudar: (_) => setState(() => _erroQuantidade = null),
        ),
        KeyedSubtree(
          key: _chaveEnergia,
          child: PaCampo.numero(
            rotulo: rotuloEnergiaInformada,
            controller: _energia,
            focusNode: _focoEnergia,
            sufixo: sufixoKcal,
            erro: _erroEnergia,
            aoMudar: (_) => setState(() => _erroEnergia = null),
          ),
        ),
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
        if (_erroGravacao != null)
          Text(_erroGravacao!, style: PaTexto.corpo.copyWith(color: PaCores.erro)),
      ],
      botoes: [
        PaBotao.primario(texto: botaoSalvarPetisco, carregando: _salvando, aoTocar: _salvar),
        if (_edicao)
          PaBotao.perigo(texto: botaoExcluirRegistro, carregando: _excluindo, aoTocar: _excluir),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
