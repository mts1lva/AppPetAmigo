import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/cores.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/formato.dart';
import '../../../../core/relogio.dart';
import '../../../../core/resultado.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/energia.dart';
import '../../domain/entidades/extra.dart';
import '../../domain/entidades/petisco.dart';
import '../../domain/textos_diario.dart';
import '../formulario.dart';
import '../providers/casos_providers.dart';
import '../providers/repositorios_providers.dart';

/// Valor da opção "Outro petisco…" no campo Petisco (P-32).
const _idOutro = '__outro__';

/// Abre o 08 Petisco ou extra. [petiscoId] e [unidades] vêm do atalho 06
/// (P-32): o formulário abre com esse petisco cadastrado e, com
/// [focarUnidades], o foco no campo Unidades.
Future<void> abrirPetisco(
  BuildContext context, {
  required String petId,
  String? extraId,
  DateTime? dia,
  String? petiscoId,
  int? unidades,
  bool focarUnidades = false,
}) {
  return mostrarPaDialogo<void>(
    context,
    builder: (_) => DialogoPetisco(
      petId: petId,
      extraId: extraId,
      dia: dia,
      petiscoId: petiscoId,
      unidades: unidades,
      focarUnidades: focarUnidades,
    ),
  );
}

/// Tela 08 Petisco ou extra (`pacote-2` → 08). Com petisco cadastrado (P-32),
/// escolhe o petisco e as unidades; com "Outro petisco…", descrição, gramas e
/// energia digitadas, como antes.
class DialogoPetisco extends ConsumerStatefulWidget {
  const DialogoPetisco({
    super.key,
    required this.petId,
    this.extraId,
    this.dia,
    this.petiscoId,
    this.unidades,
    this.focarUnidades = false,
  });

  final String petId;
  final String? extraId;
  final DateTime? dia;
  final String? petiscoId;
  final int? unidades;
  final bool focarUnidades;

  @override
  ConsumerState<DialogoPetisco> createState() => _DialogoPetiscoState();
}

class _DialogoPetiscoState extends ConsumerState<DialogoPetisco> {
  final _descricao = TextEditingController(text: descricaoPetiscoPadrao);
  final _quantidade = TextEditingController();
  final _energia = TextEditingController();
  final _unidades = TextEditingController();
  final _focoEnergia = FocusNode();
  final _focoUnidades = FocusNode();
  final _chaveEnergia = GlobalKey();
  final _chaveUnidades = GlobalKey();
  final _chaveData = GlobalKey();

  DateTime? _data;
  TimeOfDay? _hora;
  String? _erroQuantidade;
  String? _erroEnergia;
  String? _erroUnidades;
  String? _erroData;
  String? _erroGravacao;
  var _salvando = false;
  var _excluindo = false;
  var _inicio = false;
  var _preenchidoEdicao = false;

  /// `null` até a lista de petiscos chegar (registro novo) ou o registro ser
  /// lido (edição).
  String? _petiscoId;

  /// Petisco cadastrado do registro em edição: nome e energia por unidade
  /// **copiados** no registro (R01, P-32). Valem enquanto o tutor não trocar
  /// de petisco.
  ({String id, String nome, double kcalPorUnidade})? _copia;

  bool get _edicao => widget.extraId != null;
  bool get _outro => _petiscoId == null || _petiscoId == _idOutro;

  @override
  void dispose() {
    _descricao.dispose();
    _quantidade.dispose();
    _energia.dispose();
    _unidades.dispose();
    _focoEnergia.dispose();
    _focoUnidades.dispose();
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

  /// Registro novo: o petisco pedido pelo 06, senão o cadastrado mais
  /// recente, senão "Outro petisco…".
  void _escolherInicial(List<Petisco> petiscos) {
    if (_petiscoId != null || _edicao) return;
    Petisco? escolhido;
    for (final p in petiscos) {
      if (p.id == widget.petiscoId) escolhido = p;
    }
    escolhido ??= widget.petiscoId == null && petiscos.isNotEmpty ? petiscos.first : null;
    _petiscoId = escolhido?.id ?? _idOutro;
    if (escolhido != null) _unidades.text = '${widget.unidades ?? escolhido.unidadesHabituais}';
    if (widget.focarUnidades && escolhido != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focoUnidades.requestFocus();
      });
    }
  }

  void _preencher(Extra e) {
    final id = e.alimentoId;
    final kcal = e.kcalPorUnidade;
    if (id != null && kcal != null) {
      _petiscoId = id;
      _copia = (id: id, nome: e.descricao, kcalPorUnidade: kcal);
      _unidades.text = '${e.unidades}';
    } else {
      _petiscoId = _idOutro;
      _descricao.text = e.descricao;
      _quantidade.text = e.quantidadeG == null ? '' : textoNumeroCampo(e.quantidadeG!);
      _energia.text = textoNumeroCampo(e.energiaKcal);
    }
    _data = DateTime(e.dataHora.year, e.dataHora.month, e.dataHora.day);
    _hora = TimeOfDay(hour: e.dataHora.hour, minute: e.dataHora.minute);
    _preenchidoEdicao = true;
  }

  void _escolherPetisco(String id, List<Petisco> petiscos) {
    setState(() {
      _petiscoId = id;
      _erroUnidades = null;
      _erroEnergia = null;
      _erroQuantidade = null;
      if (id == _idOutro || id == _copia?.id) return;
      for (final p in petiscos) {
        if (p.id == id) _unidades.text = '${p.unidadesHabituais}';
      }
    });
  }

  /// Nome e energia por unidade do petisco escolhido: a cópia do registro
  /// (edição) ou o cadastro atual.
  (String, double)? _valores(List<Petisco> petiscos) {
    final id = _petiscoId;
    final copia = _copia;
    if (copia != null && id == copia.id) return (copia.nome, copia.kcalPorUnidade);
    for (final p in petiscos) {
      if (p.id == id) return (p.nome, p.kcalPorUnidade);
    }
    return null;
  }

  String _energiaTexto(List<Petisco> petiscos) {
    final valores = _valores(petiscos);
    final u = lerUnidades(_unidades.text);
    if (valores == null || u == null) return '';
    return switch (energiaPetisco(u, valores.$2)) {
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

  Future<void> _salvar(List<Petisco> petiscos) async {
    final quando = _dataHora;
    final agora = ref.read(agoraProvider)();
    final erroData = quando == null || dataHoraFutura(quando, agora) ? mensagemDataAteHoje : null;

    final Extra extra;
    final id = widget.extraId ?? ref.read(novoIdProvider)();
    if (_outro) {
      final qTexto = _quantidade.text.trim();
      final q = qTexto.isEmpty ? null : lerNumero(_quantidade.text);
      final kcal = lerNumero(_energia.text);
      final erroQuantidade = qTexto.isNotEmpty && (q == null || q <= 0) ? mensagemQuantidadePositiva : null;
      final erroEnergia = kcal == null || kcal <= 0 ? mensagemInformeEnergia : null;
      if (erroQuantidade != null || erroEnergia != null || erroData != null) {
        setState(() {
          _erroQuantidade = erroQuantidade;
          _erroEnergia = erroEnergia;
          _erroData = erroData;
        });
        if (erroEnergia != null) _focar(_chaveEnergia, _focoEnergia);
        return;
      }
      extra = Extra(
        id: id,
        petId: widget.petId,
        descricao: _descricao.text,
        quantidadeG: q,
        energiaKcal: kcal!,
        dataHora: quando!,
      );
    } else {
      final valores = _valores(petiscos);
      final u = lerUnidades(_unidades.text);
      final energia = valores == null || u == null ? null : energiaPetisco(u, valores.$2).valorOuNulo;
      final erroUnidades = u == null ? motivoUnidadesInvalidas : null;
      if (erroUnidades != null || erroData != null || energia == null) {
        setState(() {
          _erroUnidades = erroUnidades ?? (energia == null ? motivoUnidadesInvalidas : null);
          _erroData = erroData;
        });
        if (_erroUnidades != null) _focar(_chaveUnidades, _focoUnidades);
        return;
      }
      extra = Extra(
        id: id,
        petId: widget.petId,
        descricao: valores!.$1,
        energiaKcal: energia,
        dataHora: quando!,
        alimentoId: _petiscoId,
        unidades: u,
      );
    }

    setState(() {
      _salvando = true;
      _erroGravacao = null;
    });
    try {
      await ref.read(salvarExtraProvider)(extra, agora: agora);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _erroGravacao = textoErroGravacao(e));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _focar(GlobalKey chave, FocusNode foco) {
    final ctx = chave.currentContext;
    if (ctx != null) Scrollable.ensureVisible(ctx, duration: const Duration(milliseconds: 200));
    foco.requestFocus();
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
    final lista = ref.watch(petiscosDoPetProvider(widget.petId)).value;
    final petiscos = lista ?? const <Petisco>[];
    if (_edicao && !_preenchidoEdicao) {
      final atual = ref.watch(extraProvider((widget.petId, widget.extraId!))).value;
      if (atual != null) _preencher(atual);
    }
    if (lista != null) _escolherInicial(lista);

    final copia = _copia;
    final opcoes = [
      for (final p in petiscos) PaOpcao(valor: p.id, rotulo: p.nome),
      // Petisco arquivado depois do registro: continua com o nome copiado.
      if (copia != null && !petiscos.any((p) => p.id == copia.id)) PaOpcao(valor: copia.id, rotulo: copia.nome),
      const PaOpcao(valor: _idOutro, rotulo: rotuloOutroPetisco),
    ];

    return PaDialogo(
      titulo: tituloPetisco,
      subtitulo: subtituloPetisco,
      campos: [
        if (_petiscoId != null && (petiscos.isNotEmpty || copia != null))
          PaCampoEscolha<String>(
            rotulo: rotuloPetisco,
            opcoes: opcoes,
            valor: _petiscoId!,
            aoEscolher: (id) => _escolherPetisco(id, petiscos),
          ),
        if (_outro) ...[
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
        ] else ...[
          KeyedSubtree(
            key: _chaveUnidades,
            child: PaCampo.numero(
              rotulo: rotuloUnidades,
              controller: _unidades,
              focusNode: _focoUnidades,
              erro: _erroUnidades,
              aoMudar: (_) => setState(() => _erroUnidades = null),
            ),
          ),
          PaCampoAcao(rotulo: rotuloEnergia, valorTexto: _energiaTexto(petiscos), aoTocar: null),
        ],
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
        PaBotao.primario(texto: botaoSalvarPetisco, carregando: _salvando, aoTocar: () => _salvar(petiscos)),
        if (_edicao)
          PaBotao.perigo(texto: botaoExcluirRegistro, carregando: _excluindo, aoTocar: _excluir),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
