import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../data/repositorios/pet_atual_repositorio_drift.dart';
import '../../domain/repositorios/pet_atual_repositorio.dart';

final petAtualRepositorioProvider = Provider<PetAtualRepositorio>(
  (ref) => PetAtualRepositorioDrift(ref.watch(bancoProvider).configDao),
);

/// Id do pet atual (`config.petAtualId`), ou `null` sem pet (U2-10).
///
/// **Todos** os providers de dados dos pacotes recebem este id (`.family`):
/// ```dart
/// final petId = ref.watch(petAtualIdProvider).value;
/// if (petId != null) ref.watch(resumoDiaProvider((petId, hoje)));
/// ```
final petAtualIdProvider = StreamProvider<String?>(
  (ref) => ref.watch(petAtualRepositorioProvider).observarId(),
);
