import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../../../core/sync/fila_sync_provider.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../data/notificacoes/agendador_local.dart';
import '../../data/repositorios/lembrete_repositorio_drift.dart';
import '../../domain/casos_de_uso/gerenciar_lembretes.dart';
import '../../domain/casos_de_uso/reagendar_todos.dart';
import '../../domain/casos_de_uso/serializador_lembretes.dart';
import '../../domain/repositorios/agendador_notificacoes.dart';
import '../../domain/repositorios/lembrete_repositorio.dart';

final agendadorLocalProvider = Provider((ref) => AgendadorLocal());
final agendadorNotificacoesProvider = Provider<AgendadorNotificacoes>(
  (ref) => ref.watch(agendadorLocalProvider),
);
final lembreteRepositorioProvider = Provider<LembreteRepositorio>(
  (ref) => LembreteRepositorioDrift(
    ref.watch(bancoProvider),
    ref.watch(filaSyncProvider),
    novoId: ref.watch(novoIdProvider),
  ),
);
final serializadorLembretesProvider = Provider(
  (ref) => SerializadorLembretes(),
);
final gerenciarLembretesProvider = Provider(
  (ref) => GerenciarLembretes(
    ref.watch(lembreteRepositorioProvider),
    ref.watch(agendadorNotificacoesProvider),
    serializador: ref.watch(serializadorLembretesProvider),
  ),
);

final reagendarTodosProvider = Provider((ref) {
  final pets = ref.watch(petRepositorioProvider);
  final lembretes = ref.watch(lembreteRepositorioProvider);
  return ReagendarTodos(
    ref.watch(agendadorNotificacoesProvider),
    serializador: ref.watch(serializadorLembretesProvider),
    carregar: () async => [
      for (final pet in await pets.observarTodos().first)
        for (final l in await lembretes.listar(pet.id))
          (lembrete: l, nomePet: pet.nome),
    ],
  );
});

final permissoesLembretesProvider =
    FutureProvider.family<PermissoesLembretes, String>(
      (ref, petId) => ref.watch(agendadorLocalProvider).permissoes(),
    );
