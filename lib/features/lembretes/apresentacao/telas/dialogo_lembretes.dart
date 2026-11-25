import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/tema/cores.dart';
import '../../../../app/tema/tipografia.dart';
import '../../../../core/formato/datas.dart';
import '../../../../core/relogio.dart';
import '../../../../core/ui/ui.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../../pets/domain/entidades/pet.dart';
import '../../domain/casos_de_uso/gerenciar_lembretes.dart';
import '../../domain/entidades/lembrete.dart';
import '../../domain/repositorios/lembrete_repositorio.dart';
import '../providers/notificacoes_providers.dart';

/// Cada formulário substitui a lista; ao terminar, a lista abre novamente.
Future<void> abrirLembretes(
  BuildContext context, {
  required String petId,
}) async {
  while (context.mounted) {
    final acao = await mostrarPaDialogo<({Lembrete? lembrete, Pet pet})>(
      context,
      builder: (_) => DialogoLembretes(petId: petId),
    );
    if (acao == null || !context.mounted) return;
    await mostrarPaDialogo<void>(
      context,
      builder: (_) => DialogoLembrete(pet: acao.pet, lembrete: acao.lembrete),
    );
  }
}

class DialogoLembretes extends ConsumerStatefulWidget {
  const DialogoLembretes({super.key, required this.petId});
  final String petId;
  @override
  ConsumerState<DialogoLembretes> createState() => _DialogoLembretesState();
}

class _DialogoLembretesState extends ConsumerState<DialogoLembretes> {
  var _ocupado = false;
  String? _falha;

  Future<void> _executar(Future<void> Function() acao) async {
    if (_ocupado) return;
    setState(() {
      _ocupado = true;
      _falha = null;
    });
    try {
      await acao();
    } on AgendamentoPendente {
      if (mounted)
        setState(
          () => _falha =
              'Salvo neste aparelho. O agendamento dos avisos está pendente.',
        );
    } catch (_) {
      if (mounted)
        setState(() => _falha = 'Não foi possível concluir. Tente novamente.');
    } finally {
      if (mounted) {
        ref.invalidate(permissoesLembretesProvider(widget.petId));
        setState(() => _ocupado = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider(widget.petId)).value;
    final lista = ref.watch(lembretesConfiguracaoProvider(widget.petId));
    final lembretes = lista.value ?? [];
    final permissoes = ref
        .watch(permissoesLembretesProvider(widget.petId))
        .value;
    void editar(Lembrete? l) {
      if (pet != null) Navigator.of(context).pop((lembrete: l, pet: pet));
    }

    return PopScope(
      canPop: !_ocupado,
      child: PaDialogo(
        titulo: 'Lembretes de ${pet?.nome ?? ''}',
        subtitulo: 'Avisos neste aparelho, mesmo com o app fechado.',
        campos: [
          if (lista.hasError)
            const Text(
              'Não foi possível carregar. Tente novamente.',
              style: PaTexto.corpo,
            ),
          if (lista.hasValue && lembretes.isEmpty)
            const Text('Nenhum lembrete ainda.', style: PaTexto.corpo),
          if (lembretes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final l in lembretes)
                  PaHistorico(
                    texto:
                        '${formatarMinutosDoDia(l.horaMinutos)} • ${nomeTipoLembrete(l.tipo)}${l.ativo ? '' : ' • pausado'}',
                    rotuloSemantico:
                        'Editar lembrete: ${formatarMinutosDoDia(l.horaMinutos)}, ${nomeTipoLembrete(l.tipo)}${l.ativo ? '' : ', pausado'}',
                    aoTocar: _ocupado ? null : () => editar(l),
                  ),
              ],
            ),
          if (permissoes != null && !permissoes.notificacoes) ...[
            const Text(
              'As notificações estão desligadas para o PetAmigo.',
              style: PaTexto.corpo,
            ),
            PaBotao.primario(
              texto: 'Permitir notificações',
              aoTocar: _ocupado
                  ? null
                  : () => _executar(ref.read(pedirNotificacoesProvider)),
            ),
          ],
          if (permissoes != null && !permissoes.horarioExato) ...[
            const Text(
              'Os avisos podem atrasar alguns minutos.',
              style: PaTexto.corpo,
            ),
            PaBotao.secundario(
              texto: 'Permitir horário exato',
              aoTocar: _ocupado
                  ? null
                  : () => _executar(ref.read(pedirHorarioExatoProvider)),
            ),
          ],
          if (_falha != null)
            Text(_falha!, style: PaTexto.legenda.copyWith(color: PaCores.erro)),
        ],
        botoes: [
          if (lista.hasValue && lembretes.isEmpty)
            PaBotao.primario(
              texto: 'Usar 08:00, 14:00 e 20:00',
              carregando: _ocupado,
              aoTocar: pet == null
                  ? null
                  : () => _executar(() async {
                      await ref.read(pedirNotificacoesProvider)();
                      await ref
                          .read(gerenciarLembretesProvider)
                          .criarSugeridos(
                            pet.id,
                            nomePet: pet.nome,
                            agora: ref.read(agoraProvider)(),
                          );
                    }),
            ),
          PaBotao.primario(
            texto: 'Adicionar lembrete',
            aoTocar: _ocupado || pet == null ? null : () => editar(null),
          ),
          if (_falha != null || lista.hasError)
            PaBotao.primario(
              texto: 'Tentar novamente',
              aoTocar: _ocupado || pet == null
                  ? null
                  : () => _executar(() async {
                      ref.invalidate(lembretesConfiguracaoProvider(pet.id));
                      await ref
                          .read(gerenciarLembretesProvider)
                          .reagendarPet(pet.id, pet.nome);
                    }),
            ),
          PaBotao.secundario(
            texto: 'Voltar',
            aoTocar: _ocupado ? null : () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class DialogoLembrete extends ConsumerStatefulWidget {
  const DialogoLembrete({super.key, required this.pet, this.lembrete});
  final Pet pet;
  final Lembrete? lembrete;
  @override
  ConsumerState<DialogoLembrete> createState() => _DialogoLembreteState();
}

class _DialogoLembreteState extends ConsumerState<DialogoLembrete> {
  late final String _id;
  late TimeOfDay _hora;
  late TipoLembrete _tipo;
  late bool _ativo;
  var _ocupado = false;
  String? _erroHora;
  String? _falha;
  final _chaveHora = GlobalKey();
  @override
  void initState() {
    super.initState();
    final l = widget.lembrete;
    _id = l?.id ?? ref.read(novoIdProvider)();
    _hora = l == null
        ? TimeOfDay.fromDateTime(ref.read(agoraProvider)())
        : TimeOfDay(hour: l.horaMinutos ~/ 60, minute: l.horaMinutos % 60);
    _tipo = l?.tipo ?? TipoLembrete.refeicao;
    _ativo = l?.ativo ?? true;
  }

  Future<void> _salvar() async {
    if (_ocupado) return;
    setState(() {
      _ocupado = true;
      _erroHora = null;
      _falha = null;
    });
    try {
      if (_ativo) await ref.read(pedirNotificacoesProvider)();
      await ref
          .read(gerenciarLembretesProvider)
          .salvar(
            Lembrete(
              id: _id,
              petId: widget.pet.id,
              horaMinutos: _hora.hour * 60 + _hora.minute,
              tipo: _tipo,
              ativo: _ativo,
              notificacaoId: widget.lembrete?.notificacaoId ?? 0,
            ),
            nomePet: widget.pet.nome,
            agora: ref.read(agoraProvider)(),
          );
      if (mounted) Navigator.of(context).pop();
    } on HorarioRepetido {
      if (mounted) {
        setState(() => _erroHora = 'Já existe um lembrete nesse horário.');
        if (_chaveHora.currentContext != null)
          await Scrollable.ensureVisible(_chaveHora.currentContext!);
      }
    } on AgendamentoPendente {
      if (mounted)
        setState(
          () => _falha =
              'Salvo neste aparelho. O agendamento dos avisos está pendente.',
        );
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
          .read(gerenciarLembretesProvider)
          .excluir(widget.lembrete!, agora: ref.read(agoraProvider)());
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
      titulo: 'Lembrete',
      campos: [
        PaCampoHora(
          key: _chaveHora,
          rotulo: 'Horário',
          valor: _hora,
          erro: _erroHora,
          aoEscolher: _ocupado ? null : (h) => setState(() => _hora = h),
        ),
        PaCampoEscolha<TipoLembrete>(
          rotulo: 'Tipo',
          valor: _tipo,
          opcoes: [
            for (final tipo in TipoLembrete.values)
              PaOpcao(valor: tipo, rotulo: nomeTipoLembrete(tipo)),
          ],
          aoEscolher: _ocupado ? null : (t) => setState(() => _tipo = t),
        ),
        PaCampoEscolha<bool>(
          rotulo: 'Ativo',
          valor: _ativo,
          opcoes: const [
            PaOpcao(valor: true, rotulo: 'Sim'),
            PaOpcao(valor: false, rotulo: 'Não'),
          ],
          aoEscolher: _ocupado ? null : (v) => setState(() => _ativo = v),
        ),
        if (_falha != null)
          Text(_falha!, style: PaTexto.legenda.copyWith(color: PaCores.erro)),
      ],
      botoes: [
        PaBotao.primario(
          texto: 'Salvar lembrete',
          aoTocar: _salvar,
          carregando: _ocupado,
        ),
        if (widget.lembrete != null)
          PaBotao.perigo(
            texto: 'Excluir lembrete',
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
