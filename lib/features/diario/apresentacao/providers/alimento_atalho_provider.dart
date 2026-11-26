import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entidades/alimento.dart';
import 'repositorios_providers.dart';

/// Alimento do atalho do pet (`pacote-2`): o da refeição mais recente; sem
/// refeição, o último alimento cadastrado; sem alimento, `null`.
final alimentoAtalhoProvider = StreamProvider.family<Alimento?, String>(
  (ref, petId) => ref.watch(alimentoRepositorioProvider).observarAtalho(petId),
);
