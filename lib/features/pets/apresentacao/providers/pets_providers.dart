import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../../../core/sync/fila_sync_provider.dart';
import '../../../lembretes/apresentacao/providers/notificacoes_providers.dart';
import '../../../lembretes/data/notificacoes/central_notificacoes.dart';
import '../../data/fotos/armazenamento_fotos_local.dart';
import '../../data/fotos/seletor_foto_galeria.dart';
import '../../data/repositorios/pet_repositorio_drift.dart';
import '../../domain/casos_de_uso/cadastrar_pet.dart';
import '../../domain/casos_de_uso/editar_pet.dart';
import '../../domain/casos_de_uso/excluir_pet.dart';
import '../../domain/casos_de_uso/trocar_pet_atual.dart';
import '../../domain/entidades/pet.dart';
import '../../domain/repositorios/fotos_pet.dart';
import '../../domain/repositorios/pet_repositorio.dart';
import 'pet_atual_provider.dart';

/// IDs estáveis (UUID v4), gerados no aparelho e reutilizados no Firestore.
final novoIdProvider = Provider<String Function()>((ref) {
  const uuid = Uuid();
  return uuid.v4;
});

final petRepositorioProvider = Provider<PetRepositorio>(
  (ref) => PetRepositorioDrift(
    ref.watch(bancoProvider),
    ref.watch(filaSyncProvider),
    novoId: ref.watch(novoIdProvider),
  ),
);

/// Fotos na área privada do app (P1-1.4).
final armazenamentoFotosProvider = Provider<ArmazenamentoFotos>((ref) => ArmazenamentoFotosLocal());

/// Seletor nativo da galeria (P1-1.4).
final seletorFotoProvider = Provider<SeletorFoto>((ref) => SeletorFotoGaleria());

/// Pets do aparelho, por ordem de cadastro (N1 Seus pets).
final petsProvider = StreamProvider<List<Pet>>((ref) => ref.watch(petRepositorioProvider).observarTodos());

final petProvider = StreamProvider.family<Pet?, String>(
  (ref, petId) => ref.watch(petRepositorioProvider).observar(petId),
);

/// Peso inicial (primeira pesagem) do pet, para o formulário 05.
final pesoInicialProvider = StreamProvider.family<double?, String>(
  (ref, petId) => ref.watch(petRepositorioProvider).observarPesoInicial(petId),
);

/// O pet atual (U2-10), ou `null` sem pet ou enquanto carrega.
final petAtualProvider = Provider<Pet?>((ref) {
  final petId = ref.watch(petAtualIdProvider).value;
  if (petId == null) return null;
  return ref.watch(petProvider(petId)).value;
});

final cadastrarPetProvider = Provider(
  (ref) => CadastrarPet(
    ref.watch(petRepositorioProvider),
    ref.watch(armazenamentoFotosProvider),
    novoId: ref.watch(novoIdProvider),
  ),
);

final editarPetProvider = Provider(
  (ref) => EditarPet(ref.watch(petRepositorioProvider), ref.watch(armazenamentoFotosProvider),
    reagendarLembretes: (petId, nomePet) async {
      if (centralNotificacoes.inicializada) {
        try { await ref.read(gerenciarLembretesProvider).reagendarPet(petId, nomePet); }
        catch (erro) { debugPrint('Reagendamento pendente (${erro.runtimeType}).'); }
      }
    }),
);

final excluirPetProvider = Provider(
  (ref) => ExcluirPet(ref.watch(petRepositorioProvider), ref.watch(armazenamentoFotosProvider),
    cancelarLembretes: (petId) async {
      if (centralNotificacoes.inicializada) {
        try { await ref.read(gerenciarLembretesProvider).cancelarDoPet(petId); }
        catch (erro) { debugPrint('Cancelamento de avisos pendente (${erro.runtimeType}).'); }
      }
    }),
);

final trocarPetAtualProvider = Provider((ref) => TrocarPetAtual(ref.watch(petAtualRepositorioProvider)));
