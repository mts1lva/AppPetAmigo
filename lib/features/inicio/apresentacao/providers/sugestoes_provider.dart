import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/sugestao.dart';

/// Sugestões do card do Início (M8): junta S1, S2 e S3 do pet, na prioridade
/// S3 > S1 > S2, no máximo 2 (P1-0.11).
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
  // TODO(P1-1.6): esconder as adiadas por "Agora não" (config.sugestoesAdiadas).
  return selecionarSugestoes(s1: s1, s2: s2, s3: s3, hoje: DateTime.now());
});
