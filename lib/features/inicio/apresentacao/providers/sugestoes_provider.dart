import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../../../core/relogio.dart';
import '../../../../core/sugestao.dart';
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
/// Até a Fase 2, as três regras devolvem `null`, então a lista é vazia e o
/// card não aparece. Cada pacote troca a sua linha pelo próprio provider,
/// sem mudar a assinatura deste.
final sugestoesProvider = Provider.family<List<Sugestao>, String>((ref, petId) {
  // TODO(P2-2.1): S1 reduzir petiscos → ref.watch(<provider da S1>(petId)).value
  const Sugestao? s1 = null;
  // TODO(P3-2.1): S2 aumentar exercícios → ref.watch(<provider da S2>(petId)).value
  const Sugestao? s2 = null;
  // TODO(P4-2.1): S3 mudar objetivo → ref.watch(<provider da S3>(petId)).value
  const Sugestao? s3 = null;
  return selecionarSugestoes(
    s1: s1,
    s2: s2,
    s3: s3,
    adiadas: ref.watch(sugestoesAdiadasProvider).value ?? const {},
    hoje: ref.watch(agoraProvider)(),
  );
});
