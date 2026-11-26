import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/inicializacao.dart';
import '../core/relogio.dart';
import '../features/atividades/apresentacao/telas/dialogo_atividade.dart';
import '../features/lembretes/apresentacao/providers/notificacoes_providers.dart';
import '../features/lembretes/data/notificacoes/central_notificacoes.dart';
import '../features/lembretes/domain/entidades/lembrete.dart';
import '../features/pets/apresentacao/providers/pets_providers.dart';
import 'router.dart';

typedef DestinoLembrete = ({String petId, TipoLembrete tipo});
typedef AbrirRegistroLembrete = Future<void> Function(
  BuildContext context,
  String petId,
);

/// Contratos para os formulários dos pacotes seguintes. P2 e P4 registram
/// seus abridores mantendo o destino pendente até seus diálogos existirem.
final abridoresLembreteProvider =
    Provider<Map<TipoLembrete, AbrirRegistroLembrete>>(
      (ref) => {
        TipoLembrete.atividade: (context, petId) =>
            abrirAtividade(context, petId: petId),
      },
    );
final registroLembretePendenteProvider =
    NotifierProvider<RegistroLembretePendente, DestinoLembrete?>(
      RegistroLembretePendente.new,
    );

class RegistroLembretePendente extends Notifier<DestinoLembrete?> {
  @override
  DestinoLembrete? build() => null;
  void definir(DestinoLembrete? destino) => state = destino;
}

/// Montado no main, depois de inicializar os plugins; não interfere nos
/// testes que montam apenas o app sem um sistema Android disponível.
class CoordenadorLembretes extends ConsumerStatefulWidget {
  const CoordenadorLembretes({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<CoordenadorLembretes> createState() =>
      _CoordenadorLembretesState();
}

class _CoordenadorLembretesState extends ConsumerState<CoordenadorLembretes>
    with WidgetsBindingObserver {
  Timer? _viradaDoDia;
  var _abrindo = false;
  var _ultimaAbertura = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    centralNotificacoes.addListener(_consumir);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_consumir());
      unawaited(_retomar());
    });
  }

  Future<void> _reagendar() async {
    if (!mounted || !centralNotificacoes.inicializada) return;
    try {
      await ref.read(reagendarTodosProvider)();
    } catch (erro) {
      debugPrint('Reagendamento pendente (${erro.runtimeType}).');
    }
  }

  Future<void> _retomar() async {
    if (!mounted) return;
    await inicializarFusoHorario();
    if (!mounted) return;
    ref.invalidate(agoraProvider);
    ref.invalidate(permissoesLembretesProvider);
    _viradaDoDia?.cancel();
    final agora = DateTime.now();
    _viradaDoDia = Timer(
      DateTime(agora.year, agora.month, agora.day + 1).difference(agora),
      _retomar,
    );
    await _reagendar();
    if (mounted) await _consumir();
  }

  Future<void> _consumir() async {
    if (_abrindo || !mounted) return;
    _abrindo = true;
    try {
      while (mounted && centralNotificacoes.primeiro != null) {
        final destino = centralNotificacoes.primeiro!;
        final pets = ref.read(petsProvider);
        if (!pets.hasValue) return;
        final pet = pets.value!.where((p) => p.id == destino.petId).firstOrNull;
        if (pet == null) {
          centralNotificacoes.concluir();
          continue;
        }
        await ref.read(trocarPetAtualProvider)(pet.id);
        if (!mounted) return;
        final roteador = ref.read(roteadorProvider);
        final navegador = ref.read(chaveNavegadorProvider).currentState;
        navegador?.popUntil((rota) => rota.isFirst);
        roteador.go(switch (destino.tipo) {
          TipoLembrete.refeicao => Rotas.diario,
          TipoLembrete.pesagem => Rotas.evolucao,
          TipoLembrete.atividade => Rotas.atividades,
        });
        ref.read(registroLembretePendenteProvider.notifier).definir(destino);
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        final contexto = ref
            .read(chaveNavegadorProvider)
            .currentState
            ?.overlay
            ?.context;
        final abrir = ref.read(abridoresLembreteProvider)[destino.tipo];
        final aberturaAtual = ++_ultimaAbertura;
        centralNotificacoes.concluir();
        if (contexto != null && contexto.mounted && abrir != null) {
          ref.read(registroLembretePendenteProvider.notifier).definir(null);
          // O Future do diálogo só termina ao fechá-lo. A fila precisa poder
          // tratar outro toque e substituir esse formulário imediatamente.
          unawaited(
            Future<void>.sync(() => abrir(contexto, destino.petId))
                .onError((erro, stack) {
                  if (mounted && aberturaAtual == _ultimaAbertura) {
                    ref
                        .read(registroLembretePendenteProvider.notifier)
                        .definir(destino);
                  }
                  debugPrint(
                    'Abertura do lembrete pendente (${erro.runtimeType}).',
                  );
                }),
          );
        }
      }
    } catch (erro) {
      debugPrint('Abertura do lembrete pendente (${erro.runtimeType}).');
    } finally {
      _abrindo = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_retomar());
  }

  @override
  void dispose() {
    _viradaDoDia?.cancel();
    centralNotificacoes.removeListener(_consumir);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(petsProvider, (_, proximo) {
      if (proximo.hasValue) {
        unawaited(_consumir());
        if (centralNotificacoes.inicializada) unawaited(_reagendar());
      }
    });
    return widget.child;
  }
}
