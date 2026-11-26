import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../../../core/relogio.dart';
import '../../../../core/sugestao.dart';
import '../../../atividades/apresentacao/providers/indicadores_atividade_provider.dart';
import '../../../diario/apresentacao/providers/sugestao_petiscos_provider.dart';
import '../../../evolucao/apresentacao/providers/evolucao_providers.dart';
import '../../data/sugestoes_adiadas_config.dart';
import '../../domain/repositorios/sugestoes_adiadas_repositorio.dart';

final sugestoesAdiadasRepositorioProvider = Provider<SugestoesAdiadasRepositorio>(
  (ref) => SugestoesAdiadasConfig(ref.watch(bancoProvider).configDao),
);

/// Sugestões adiadas por "Agora não" (tipo → dia).
final sugestoesAdiadasProvider = StreamProvider<Map<TipoSugestao, DateTime>>(
  (ref) => ref.watch(sugestoesAdiadasRepositorioProvider).observar(),
);

/// Sugestões do card do Início (M8): junta S1, S2 e S3 do pet, na prioridade
/// S3 > S1 > S2, tira as adiadas há menos de 7 dias e devolve no máximo 2
/// (P1-0.11, P1-1.6).
///
/// S1 vem do diário (`sugestaoPetiscosProvider`), S2 das atividades
/// (`sugestaoExerciciosProvider`) e S3 da evolução (`sugestaoObjetivoProvider`,
/// P4-2.1), sem mudar a assinatura deste provider.
final sugestoesProvider = Provider.family<List<Sugestao>, String>((ref, petId) {
  final s1 = ref.watch(sugestaoPetiscosProvider(petId));
  final s2 = ref.watch(sugestaoExerciciosProvider(petId));
  final s3 = ref.watch(sugestaoObjetivoProvider(petId));
  return selecionarSugestoes(
    s1: s1,
    s2: s2,
    s3: s3,
    adiadas: ref.watch(sugestoesAdiadasProvider).value ?? const {},
    hoje: ref.watch(agoraProvider)(),
  );
});
