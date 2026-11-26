import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/formato.dart';
import '../../../../core/relogio.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/entidades/pesagem.dart';
import '../../domain/formularios.dart';
import '../../domain/textos_evolucao.dart';
import '../providers/evolucao_providers.dart';
import 'dialogo_conferir_pesagem.dart';
import 'dialogo_pesagem_salva.dart';

/// Abre a tela 11 Pesagem: em branco sem [pesagemId], edição com ele. Editar
/// a primeira pesagem do pet é editar o **peso inicial** (U2-06), com o
/// título `Peso inicial` e sem "Excluir registro".
Future<void> abrirPesagem(BuildContext context, {required String petId, String? pesagemId}) {
  return mostrarPaDialogo<void>(context, builder: (_) => DialogoPesagem(petId: petId, pesagemId: pesagemId));
}

class DialogoPesagem extends ConsumerStatefulWidget {
  const DialogoPesagem({super.key, required this.petId, this.pesagemId});

  final String petId;
  final String? pesagemId;

  @override
  ConsumerState<DialogoPesagem> createState() => _DialogoPesagemState();
}

class _DialogoPesagemState extends ConsumerState<DialogoPesagem> {
  final _peso = TextEditingController();
  final _focoPeso = FocusNode();

  DateTime? _data;
  TimeOfDay? _hora;
  Map<CampoPesagem, String> _erros = const {};
  var _salvando = false;
  var _preenchido = false;

  bool get _edicao => widget.pesagemId != null;

  @override
  void dispose() {
    _peso.dispose();
    _focoPeso.dispose();
    super.dispose();
  }

  void _preencher(List<Pesagem> pesagens) {
    final id = widget.pesagemId;
    final DateTime quando;
    if (id == null) {
      quando = ref.read(agoraProvider)();
    } else {
      final p = pesagens.where((p) => p.id == id).firstOrNull;
      if (p == null) return;
      _peso.text = textoPesoDigitado(p.pesoKg);
      quando = p.dataHora;
    }
    _data = DateTime(quando.year, quando.month, quando.day);
    _hora = TimeOfDay(hour: quando.hour, minute: quando.minute);
    _preenchido = true;
  }

  DateTime get _dataHora => DateTime(_data!.year, _data!.month, _data!.day, _hora!.hour, _hora!.minute);

  void _alterar(VoidCallback mudanca, CampoPesagem campo) {
    setState(() {
      mudanca();
      if (_erros.containsKey(campo)) _erros = Map.of(_erros)..remove(campo);
    });
  }

  Future<void> _salvar() async {
    final navegador = Navigator.of(context);
    final agora = ref.read(agoraProvider)();
    final pesoKg = lerNumero(_peso.text);
    final dataHora = _dataHora;
    final erros = validarPesagem(pesoKg: pesoKg, dataHora: dataHora, agora: agora);
    if (erros.isNotEmpty) {
      setState(() => _erros = erros);
      // R05: o botão continua habilitado e leva o foco ao primeiro erro.
      if (erros.keys.first == CampoPesagem.peso) {
        _focoPeso.requestFocus();
      } else {
        FocusScope.of(context).unfocus();
      }
      return;
    }

    final salvar = ref.read(salvarPesagemProvider);
    final pesagens = await ref.read(pesagensProvider(widget.petId).future);
    final conferencia = salvar.conferir(
      pesagens: pesagens,
      novoKg: pesoKg!,
      dataHora: dataHora,
      ignorarId: widget.pesagemId,
    );

    var kg = pesoKg;
    var conferida = false;
    if (conferencia.suspeita) {
      if (!mounted) return;
      final escolha = await abrirConferirPesagem(context, informadoKg: pesoKg, conferencia: conferencia);
      switch (escolha) {
        case null:
          return;
        case CorrigirValor():
          _focoPeso.requestFocus();
          return;
        case CorrigirParaSugestao(kg: final sugestao):
          kg = sugestao;
        case ManterValor():
          conferida = true;
      }
    }

    setState(() => _salvando = true);
    try {
      final referencia = await ref.read(referenciaProvider(widget.petId).future);
      final nomePet = ref.read(petProvider(widget.petId)).value?.nome ?? '';
      final texto = await salvar(
        Pesagem(
          id: widget.pesagemId ?? ref.read(novoIdProvider)(),
          petId: widget.petId,
          pesoKg: kg,
          dataHora: dataHora,
          conferida: conferida,
        ),
        pesagensAntes: pesagens,
        referencia: referencia,
        nomePet: nomePet,
        agora: agora,
      );
      // Só fecha depois que a transação terminou (sem UI otimista).
      if (!mounted) return;
      final contextoRaiz = navegador.context;
      navegador.pop();
      if (texto != null && contextoRaiz.mounted) await abrirPesagemSalva(contextoRaiz, celebracao: texto);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _excluir() async {
    final excluir = ref.read(excluirPesagemProvider);
    final agora = ref.read(agoraProvider)();
    final navegador = Navigator.of(context);
    if (!await confirmarExclusao(context)) return;
    // Quem chamou a tela 23 fecha o próprio diálogo e executa a exclusão.
    navegador.pop();
    await excluir(widget.pesagemId!, agora: agora);
  }

  @override
  Widget build(BuildContext context) {
    final pesagens = ref.watch(pesagensProvider(widget.petId));
    // Observados aqui para estarem prontos ao salvar (peso ideal e nome do
    // pet da celebração).
    ref
      ..watch(referenciaProvider(widget.petId))
      ..watch(petProvider(widget.petId));
    if (!_preenchido && pesagens.hasValue) _preencher(pesagens.value!);
    final pesoInicial = _edicao && pesagens.value?.firstOrNull?.id == widget.pesagemId;
    final hoje = ref.watch(agoraProvider)();

    return PaDialogo(
      titulo: pesoInicial ? TextosPesagem.tituloPesoInicial : TextosPesagem.titulo,
      subtitulo: TextosPesagem.subtitulo,
      campos: !_preenchido
          ? const []
          : [
              PaCampo.numero(
                rotulo: 'Peso',
                controller: _peso,
                focusNode: _focoPeso,
                sufixo: 'kg',
                acaoTeclado: TextInputAction.done,
                erro: _erros[CampoPesagem.peso],
                aoMudar: (_) => _alterar(() {}, CampoPesagem.peso),
              ),
              PaCampoData(
                rotulo: 'Data',
                valor: _data,
                ultimaData: DateTime(hoje.year, hoje.month, hoje.day),
                erro: _erros[CampoPesagem.data],
                aoEscolher: (d) => _alterar(() => _data = d, CampoPesagem.data),
              ),
              PaCampoHora(
                rotulo: 'Horário',
                valor: _hora,
                erro: _erros[CampoPesagem.horario],
                aoEscolher: (h) => _alterar(() => _hora = h, CampoPesagem.horario),
              ),
              const Text(TextosPesagem.aviso, style: PaTexto.corpo),
            ],
      botoes: [
        PaBotao.primario(texto: 'Salvar peso', carregando: _salvando, aoTocar: _preenchido ? _salvar : null),
        if (_edicao && _preenchido && !pesoInicial) PaBotao.perigo(texto: 'Excluir registro', aoTocar: _excluir),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
