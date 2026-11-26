import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../../../core/relogio.dart';
import '../../../../core/sugestao.dart';
import '../../../../core/sync/fila_sync_provider.dart';
import '../../data/repositorios/referencia_repositorio_drift.dart';
import '../../domain/casos_de_uso/excluir_pesagem.dart';
import '../../domain/casos_de_uso/referencias.dart';
import '../../domain/casos_de_uso/salvar_pesagem.dart';
import '../../domain/entidades/pesagem.dart';
import '../../domain/entidades/referencia.dart';
import '../../domain/projecao.dart';
import '../../domain/repositorios/referencia_repositorio.dart';
import '../../domain/sugestao_objetivo.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import 'ultima_pesagem_provider.dart';

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

/// S3 Mudar objetivo (M8) do pet, para o `sugestoesProvider` do Início
/// (P4-2.1). `null` enquanto os dados carregam ou sem sugestão.
///
/// O ritmo de M5 vem por enquanto só das pesagens (parte observada de M4).
// TODO(P4-1.3): usar o `projecaoProvider`, com a ingestão do P2 e o gasto de
// atividade do P3, quando eles chegarem à dev.
final sugestaoObjetivoProvider = Provider.family<Sugestao?, String>((ref, petId) {
  final pesagens = ref.watch(pesagensProvider(petId)).value;
  final referencia = ref.watch(referenciaProvider(petId));
  final nome = ref.watch(petProvider(petId)).value?.nome;
  if (pesagens == null || !referencia.hasValue || nome == null) return null;
  final hoje = ref.watch(agoraProvider)();
  final ritmo = projecao(
    pesagens: pesagens,
    ingestaoPorDia: const {},
    atividadeKcalPorDia: 0,
    mer: null,
    hoje: hoje,
  ).valorOuNulo?.kgDia;
  return sugestaoMudarObjetivoDosRegistros(
    nomePet: nome,
    pesagens: pesagens,
    referencia: referencia.value,
    kgDia: ritmo,
    hoje: hoje,
  );
});
