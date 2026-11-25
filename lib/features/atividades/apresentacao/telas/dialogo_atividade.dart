import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/cores.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/relogio.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/entidades/atividade.dart';
import '../providers/atividades_providers.dart';

Future<void> abrirAtividade(
  BuildContext context, {
  required String petId,
  Atividade? atividade,
}) => mostrarPaDialogo<void>(
  context,
  builder: (_) => DialogoAtividade(petId: petId, atividade: atividade),
);

class DialogoAtividade extends ConsumerStatefulWidget {
  const DialogoAtividade({super.key, required this.petId, this.atividade});
  final String petId;
  final Atividade? atividade;
  @override
  ConsumerState<DialogoAtividade> createState() => _DialogoAtividadeState();
}

class _DialogoAtividadeState extends ConsumerState<DialogoAtividade> {
  final _duracao = TextEditingController();
  final _focoDuracao = FocusNode();
  final _dataChave = GlobalKey();
  late DateTime _data;
  late TimeOfDay _hora;
  var _tipo = TipoAtividade.passeio;
  var _ocupado = false;
  String? _falha;
  Map<CampoAtividade, String> _erros = {};

  @override
  void initState() {
    super.initState();
    final a = widget.atividade;
    final agora = a?.dataHora ?? ref.read(agoraProvider)();
    _data = DateTime(agora.year, agora.month, agora.day);
    _hora = TimeOfDay.fromDateTime(agora);
    _tipo = a?.tipo ?? TipoAtividade.passeio;
    _duracao.text = a?.duracaoMin.toString() ?? '';
  }

  @override
  void dispose() {
    _duracao.dispose();
    _focoDuracao.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_ocupado) return;
    final agora = ref.read(agoraProvider)();
    final atividade = Atividade(
      id: widget.atividade?.id ?? ref.read(novoIdProvider)(),
      petId: widget.petId,
      tipo: _tipo,
      duracaoMin: int.tryParse(_duracao.text) ?? 0,
      dataHora: DateTime(
        _data.year,
        _data.month,
        _data.day,
        _hora.hour,
        _hora.minute,
      ),
    );
    final erros = validarAtividade(atividade, agora);
    setState(() {
      _erros = erros;
      _falha = null;
    });
    if (erros.isNotEmpty) {
      if (erros.containsKey(CampoAtividade.duracao)) {
        _focoDuracao.requestFocus();
      } else if (_dataChave.currentContext != null) {
        await Scrollable.ensureVisible(_dataChave.currentContext!);
      }
      return;
    }
    setState(() => _ocupado = true);
    try {
      await ref.read(salvarAtividadeProvider)(atividade, agora: agora);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted)
        setState(() => _falha = 'Não foi possível salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  Future<void> _excluir() async {
    if (_ocupado || !await confirmarExclusao(context) || !mounted) return;
    setState(() => _ocupado = true);
    try {
      await ref
          .read(atividadeRepositorioProvider)
          .excluir(
            widget.petId,
            widget.atividade!.id,
            agora: ref.read(agoraProvider)(),
          );
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (mounted)
        setState(() => _falha = 'Não foi possível excluir. Tente novamente.');
    } finally {
      if (mounted) setState(() => _ocupado = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_ocupado,
    child: PaDialogo(
      titulo: 'Passeio ou brincadeira',
      subtitulo: 'Um formulário para criar e editar.',
      texto: 'Atividades não mudam a meta de calorias. Elas entram na projeção de peso.',
      campos: [
        PaCampoEscolha<TipoAtividade>(
          rotulo: 'Tipo',
          valor: _tipo,
          opcoes: [
            for (final t in TipoAtividade.values)
              PaOpcao(valor: t, rotulo: nomeTipoAtividade(t)),
          ],
          aoEscolher: _ocupado ? null : (t) => setState(() => _tipo = t),
        ),
        PaCampo.numero(
          rotulo: 'Duração',
          controller: _duracao,
          sufixo: 'minutos',
          focusNode: _focoDuracao,
          erro: _erros[CampoAtividade.duracao],
        ),
        PaCampoData(
          key: _dataChave,
          rotulo: 'Data',
          valor: _data,
          ultimaData: ref.read(agoraProvider)(),
          erro: _erros[CampoAtividade.dataHora],
          aoEscolher: _ocupado ? null : (d) => setState(() => _data = d),
        ),
        PaCampoHora(
          rotulo: 'Horário',
          valor: _hora,
          aoEscolher: _ocupado ? null : (h) => setState(() => _hora = h),
        ),
        if (_falha != null)
          Text(_falha!, style: PaTexto.legenda.copyWith(color: PaCores.erro)),
      ],
      botoes: [
        PaBotao.primario(
          texto: 'Salvar atividade',
          aoTocar: _salvar,
          carregando: _ocupado,
        ),
        if (widget.atividade != null)
          PaBotao.perigo(
            texto: 'Excluir registro',
            aoTocar: _ocupado ? null : _excluir,
          ),
        PaBotao.secundario(
          texto: 'Voltar',
          aoTocar: _ocupado ? null : () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );
}
