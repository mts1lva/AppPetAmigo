import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../../../core/sync/fila_sync_provider.dart';
import '../../data/repositorios/referencia_repositorio_drift.dart';
import '../../domain/casos_de_uso/excluir_pesagem.dart';
import '../../domain/casos_de_uso/referencias.dart';
import '../../domain/casos_de_uso/salvar_pesagem.dart';
import '../../domain/entidades/pesagem.dart';
import '../../domain/entidades/referencia.dart';
import '../../domain/repositorios/referencia_repositorio.dart';
import 'ultima_pesagem_provider.dart';

export 'modelos_providers.dart';
export 'ultima_pesagem_provider.dart';

final referenciaRepositorioProvider = Provider<ReferenciaRepositorio>(
  (ref) => ReferenciaRepositorioDrift(ref.watch(bancoProvider), ref.watch(filaSyncProvider)),
);

/// Pesagens do pet, da mais antiga (peso inicial) para a mais recente.
final pesagensProvider = StreamProvider.family<List<Pesagem>, String>(
  (ref, petId) => ref.watch(pesagemRepositorioProvider).observarTodas(petId),
);

/// ECC e objetivo vigentes do pet, ou `null`.
final referenciaProvider = StreamProvider.family<Referencia?, String>(
  (ref, petId) => ref.watch(referenciaRepositorioProvider).observarVigente(petId),
);

final salvarPesagemProvider = Provider((ref) => SalvarPesagem(ref.watch(pesagemRepositorioProvider)));

final excluirPesagemProvider = Provider((ref) => ExcluirPesagem(ref.watch(pesagemRepositorioProvider)));

final salvarReferenciasProvider = Provider((ref) => SalvarReferencias(ref.watch(referenciaRepositorioProvider)));

final removerReferenciasProvider = Provider((ref) => RemoverReferencias(ref.watch(referenciaRepositorioProvider)));

