import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../../../core/relogio.dart';
import '../../../../core/sync/fila_sync_provider.dart';
import '../../data/dicas_locais.dart';
import '../../data/repositorios/atividade_repositorio_drift.dart';
import '../../domain/casos_de_uso/salvar_atividade.dart';
import '../../domain/entidades/atividade.dart';
import '../../domain/entidades/dica.dart';
import '../../domain/repositorios/atividade_repositorio.dart';

final atividadeRepositorioProvider = Provider<AtividadeRepositorio>(
  (ref) => AtividadeRepositorioDrift(
    ref.watch(bancoProvider),
    ref.watch(filaSyncProvider),
  ),
);
final salvarAtividadeProvider = Provider(
  (ref) => SalvarAtividade(ref.watch(atividadeRepositorioProvider)),
);

final atividadesPeriodoProvider =
    StreamProvider.family<
      List<Atividade>,
      ({String petId, DateTime inicio, DateTime fim})
    >(
      (ref, periodo) => ref
          .watch(atividadeRepositorioProvider)
          .observar(periodo.petId, inicio: periodo.inicio, fim: periodo.fim),
    );

/// A janela cobre o cálculo de 14 dias e o histórico visual de sete dias.
final atividadesProvider = Provider.family<AsyncValue<List<Atividade>>, String>(
  (ref, petId) {
    final hoje = ref.watch(agoraProvider)();
    return ref.watch(
      atividadesPeriodoProvider((
        petId: petId,
        inicio: DateTime(hoje.year, hoje.month, hoje.day - 13),
        fim: DateTime(hoje.year, hoje.month, hoje.day + 1),
      )),
    );
  },
);

final dicasProvider = FutureProvider<List<Dica>>(
  (ref) => DicasLocais().carregar(),
);
