import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../../../core/sync/fila_sync_provider.dart';
import '../../data/repositorios/alimento_repositorio_drift.dart';
import '../../data/repositorios/extra_repositorio_drift.dart';
import '../../data/repositorios/refeicao_repositorio_drift.dart';
import '../../domain/entidades/alimento.dart';
import '../../domain/entidades/extra.dart';
import '../../domain/entidades/refeicao.dart';
import '../../domain/periodo.dart';
import '../../domain/repositorios/alimento_repositorio.dart';
import '../../domain/repositorios/extra_repositorio.dart';
import '../../domain/repositorios/refeicao_repositorio.dart';

final alimentoRepositorioProvider = Provider<AlimentoRepositorio>(
  (ref) => AlimentoRepositorioDrift(ref.watch(bancoProvider), ref.watch(filaSyncProvider)),
);

final refeicaoRepositorioProvider = Provider<RefeicaoRepositorio>(
  (ref) => RefeicaoRepositorioDrift(ref.watch(bancoProvider), ref.watch(filaSyncProvider)),
);

final extraRepositorioProvider = Provider<ExtraRepositorio>(
  (ref) => ExtraRepositorioDrift(ref.watch(bancoProvider), ref.watch(filaSyncProvider)),
);

/// Alimentos não arquivados do pet.
final alimentosDoPetProvider = StreamProvider.family<List<Alimento>, String>(
  (ref, petId) => ref.watch(alimentoRepositorioProvider).observarDoPet(petId),
);

final alimentoProvider = StreamProvider.family<Alimento?, String>(
  (ref, id) => ref.watch(alimentoRepositorioProvider).observar(id),
);

final refeicaoProvider = StreamProvider.family<Refeicao?, String>(
  (ref, id) => ref.watch(refeicaoRepositorioProvider).observar(id),
);

final extraProvider = StreamProvider.family<Extra?, String>(
  (ref, id) => ref.watch(extraRepositorioProvider).observar(id),
);

/// Refeições do [dia] (00:00 a 23:59). Passe o dia sem hora.
final refeicoesDoDiaProvider = StreamProvider.family<List<Refeicao>, (String petId, DateTime dia)>(
  (ref, args) {
    final inicio = diaDe(args.$2);
    return ref.watch(refeicaoRepositorioProvider).observarEntre(args.$1, inicio, inicio.add(const Duration(days: 1)));
  },
);

final extrasDoDiaProvider = StreamProvider.family<List<Extra>, (String petId, DateTime dia)>(
  (ref, args) {
    final inicio = diaDe(args.$2);
    return ref.watch(extraRepositorioProvider).observarEntre(args.$1, inicio, inicio.add(const Duration(days: 1)));
  },
);
