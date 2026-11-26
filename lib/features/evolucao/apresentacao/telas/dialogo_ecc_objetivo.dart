import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/formato.dart';
import '../../../../core/relogio.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/casos_de_uso/referencias.dart';
import '../../domain/entidades/referencia.dart';
import '../../domain/formularios.dart';
import '../../domain/textos_evolucao.dart';
import '../providers/evolucao_providers.dart';

/// Abre a tela 12 ECC e objetivo do pet, preenchida com a referência
/// vigente, se houver.
Future<void> abrirEccObjetivo(BuildContext context, {required String petId}) {
  return mostrarPaDialogo<void>(context, builder: (_) => DialogoEccObjetivo(petId: petId));
}

/// Opções dos campos de escolha da tela 12 (P-03, P-13).
abstract final class OpcoesReferencia {
  static final ecc = <PaOpcao<int?>>[
    const PaOpcao(valor: null, rotulo: TextosReferencias.naoInformado),
    for (var n = 1; n <= 9; n++) PaOpcao(valor: n, rotulo: rotuloEcc(n)),
  ];
  static final origem = [for (final o in OrigemReferencia.values) PaOpcao(valor: o, rotulo: rotuloOrigem(o))];
}

class DialogoEccObjetivo extends ConsumerStatefulWidget {
  const DialogoEccObjetivo({super.key, required this.petId});

  final String petId;

  @override
  ConsumerState<DialogoEccObjetivo> createState() => _DialogoEccObjetivoState();
}

class _DialogoEccObjetivoState extends ConsumerState<DialogoEccObjetivo> {
  final _objetivo = TextEditingController();
  final _focoObjetivo = FocusNode();

  String? _id;
  int? _ecc;
  OrigemReferencia _origem = OrigemReferencia.veterinario;
  DateTime? _data;
  Map<CampoReferencia, String> _erros = const {};
  var _salvando = false;
  var _preenchido = false;

  @override
  void dispose() {
    _objetivo.dispose();
    _focoObjetivo.dispose();
    super.dispose();
  }

  void _preencher(Referencia? r) {
    final agora = ref.read(agoraProvider)();
    _id = r?.id;
    _ecc = r?.ecc;
    final objetivo = r?.objetivoKg;
    _objetivo.text = objetivo == null ? '' : textoPesoDigitado(objetivo);
    _origem = r?.origem ?? OrigemReferencia.veterinario;
    final data = r?.data ?? agora;
    _data = DateTime(data.year, data.month, data.day);
    _preenchido = true;
  }

  void _alterar(VoidCallback mudanca, CampoReferencia campo) {
    setState(() {
      mudanca();
      if (_erros.containsKey(campo)) _erros = Map.of(_erros)..remove(campo);
    });
  }

  double? get _objetivoKg => _objetivo.text.trim().isEmpty ? null : lerNumero(_objetivo.text);

  Future<void> _salvar() async {
    final navegador = Navigator.of(context);
    final agora = ref.read(agoraProvider)();
    final erros = validarReferencia(objetivoTexto: _objetivo.text, objetivoKg: _objetivoKg, data: _data!, agora: agora);
    if (erros.isNotEmpty) {
      setState(() => _erros = erros);
      if (erros.keys.first == CampoReferencia.objetivo) _focoObjetivo.requestFocus();
      return;
    }

    setState(() => _salvando = true);
    try {
      await ref.read(salvarReferenciasProvider)(
        Referencia(
          id: _id ?? ref.read(novoIdProvider)(),
          petId: widget.petId,
          ecc: _ecc,
          objetivoKg: _objetivoKg,
          origem: _origem,
          data: _data!,
        ),
        agora: agora,
      );
      // Só fecha depois que a transação terminou (sem UI otimista).
      if (mounted) navegador.pop();
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _remover() async {
    final remover = ref.read(removerReferenciasProvider);
    final agora = ref.read(agoraProvider)();
    final navegador = Navigator.of(context);
    if (!await confirmarExclusao(context)) return;
    // Quem chamou a tela 23 fecha o próprio diálogo e executa a remoção.
    navegador.pop();
    await remover(widget.petId, agora: agora);
  }

  @override
  Widget build(BuildContext context) {
    final referencia = ref.watch(referenciaProvider(widget.petId));
    final pesagens = ref.watch(pesagensProvider(widget.petId)).value ?? const [];
    if (!_preenchido && referencia.hasValue) _preencher(referencia.value);
    final hoje = ref.watch(agoraProvider)();

    final estimado = !_preenchido
        ? null
        : pesoIdealEstimadoNaTela12(
            petId: widget.petId,
            ecc: _ecc,
            objetivoKg: _objetivo.text.trim().isEmpty ? null : _objetivoKg,
            data: _data!,
            pesagens: pesagens,
          );

    return PaDialogo(
      titulo: TextosReferencias.titulo,
      subtitulo: TextosReferencias.subtitulo,
      campos: !_preenchido
          ? const []
          : [
              PaCampoEscolha<int?>(
                rotulo: 'ECC informado',
                opcoes: OpcoesReferencia.ecc,
                valor: _ecc,
                aoEscolher: (v) => _alterar(() => _ecc = v, CampoReferencia.ecc),
              ),
              PaCampo.numero(
                rotulo: 'Objetivo (kg)',
                controller: _objetivo,
                focusNode: _focoObjetivo,
                dica: TextosReferencias.naoInformado,
                acaoTeclado: TextInputAction.done,
                erro: _erros[CampoReferencia.objetivo],
                aoMudar: (_) => _alterar(() {}, CampoReferencia.objetivo),
              ),
              PaCampoEscolha<OrigemReferencia>(
                rotulo: 'Origem',
                opcoes: OpcoesReferencia.origem,
                valor: _origem,
                aoEscolher: (v) => _alterar(() => _origem = v, CampoReferencia.origem),
              ),
              PaCampoData(
                rotulo: 'Data',
                valor: _data,
                ultimaData: DateTime(hoje.year, hoje.month, hoje.day),
                erro: _erros[CampoReferencia.data],
                aoEscolher: (d) => _alterar(() => _data = d, CampoReferencia.data),
              ),
              Text(
                [
                  TextosReferencias.explicacao,
                  if (estimado != null) TextosReferencias.pesoIdealEstimado(estimado),
                ].join('\n'),
                style: PaTexto.corpo,
              ),
            ],
      botoes: [
        PaBotao.primario(texto: 'Salvar referências', carregando: _salvando, aoTocar: _preenchido ? _salvar : null),
        PaBotao.primario(texto: 'Remover referências', aoTocar: _preenchido ? _remover : null),
        PaBotao.secundario(texto: 'Voltar', aoTocar: () => Navigator.of(context).pop()),
      ],
    );
  }
}
