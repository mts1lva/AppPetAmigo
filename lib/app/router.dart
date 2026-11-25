import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/ui/ui.dart';
import '../features/inicio/apresentacao/telas/tela_inicio.dart';
import '../features/atividades/apresentacao/telas/tela_atividades.dart';
import '../features/pets/apresentacao/providers/pet_atual_provider.dart';
import '../features/pets/apresentacao/telas/dialogo_dados_pet.dart';
import '../features/pets/apresentacao/telas/tela_vamos_comecar.dart';
import 'tema/cores.dart';
import 'telas_provisorias.dart';

/// Rotas do app (`docs/specs/comum/navegacao.md`). Só existem as 4 abas e o
/// estado sem pet; todo o resto é diálogo (`PaDialogo`) por cima da aba atual.
abstract final class Rotas {
  static const inicio = '/inicio';
  static const diario = '/diario';
  static const atividades = '/atividades';
  static const evolucao = '/evolucao';

  /// 26 "Vamos começar?": sem pet, sem navegação inferior.
  static const comecar = '/comecar';

  /// Enquanto o banco ainda não respondeu qual é o pet atual.
  static const carregando = '/carregando';

  /// As 4 abas, na ordem da `PaNavegacao`.
  static const abas = [inicio, diario, atividades, evolucao];
}

/// Decide para onde ir conforme o pet atual (U2-10):
/// - ainda carregando → [Rotas.carregando];
/// - sem pet → [Rotas.comecar];
/// - com pet, saindo do 26 ou do carregamento → [Rotas.inicio].
String? redirecionarPorPet(AsyncValue<String?> petAtual, String local) {
  if (!petAtual.hasValue) return local == Rotas.carregando ? null : Rotas.carregando;
  if (petAtual.value == null) return local == Rotas.comecar ? null : Rotas.comecar;
  if (local == Rotas.comecar || local == Rotas.carregando) return Rotas.inicio;
  return null;
}

final roteadorProvider = Provider<GoRouter>((ref) {
  final petAtual = ValueNotifier<AsyncValue<String?>>(ref.read(petAtualIdProvider));
  ref.listen(petAtualIdProvider, (_, proximo) => petAtual.value = proximo);

  final roteador = GoRouter(
    initialLocation: Rotas.inicio,
    refreshListenable: petAtual,
    redirect: (context, state) => redirecionarPorPet(petAtual.value, state.matchedLocation),
    routes: [
      GoRoute(
        path: Rotas.carregando,
        builder: (context, state) => const ColoredBox(color: PaCores.fundo),
      ),
      GoRoute(
        path: Rotas.comecar,
        builder: (context, state) => TelaVamosComecar(aoCadastrar: () => abrirDadosPet(context)),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, abas) => EstruturaAbas(abas: abas),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: Rotas.inicio, builder: (context, state) => const TelaInicio()),
          ]),
          StatefulShellBranch(routes: [
            // TODO(P2-1.5): tela 02 Diário.
            GoRoute(path: Rotas.diario, builder: (context, state) => const TelaProvisoria(titulo: 'Diário')),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: Rotas.atividades,
              builder: (context, state) => const TelaAtividades(),
            ),
          ]),
          StatefulShellBranch(routes: [
            // TODO(P4-1.5): tela 04 Evolução.
            GoRoute(path: Rotas.evolucao, builder: (context, state) => const TelaProvisoria(titulo: 'Evolução')),
          ]),
        ],
      ),
    ],
  );

  ref.onDispose(() {
    roteador.dispose();
    petAtual.dispose();
  });
  return roteador;
});

/// Shell das 4 abas: cada aba guarda a própria pilha e rolagem
/// (`indexedStack`) e a `PaNavegacao` fica fixa embaixo.
///
/// Botão voltar do Android: numa aba ≠ Início, vai para o Início; no Início,
/// sai do app. Diálogos abertos fecham antes (rota do navegador raiz).
class EstruturaAbas extends StatelessWidget {
  const EstruturaAbas({super.key, required this.abas});

  final StatefulNavigationShell abas;

  @override
  Widget build(BuildContext context) {
    final noInicio = abas.currentIndex == 0;
    return PopScope(
      canPop: noInicio,
      onPopInvokedWithResult: (saiu, _) {
        if (!saiu) abas.goBranch(0);
      },
      child: Scaffold(
        backgroundColor: PaCores.fundo,
        body: abas,
        bottomNavigationBar: PaNavegacao(
          indiceAtual: abas.currentIndex,
          // Tocar na aba atual volta à raiz dela.
          aoSelecionar: (i) => abas.goBranch(i, initialLocation: i == abas.currentIndex),
        ),
      ),
    );
  }
}
