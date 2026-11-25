import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entidades/lembrete.dart';
import 'notificacoes_providers.dart';

/// Lembretes do pet, usados pelo card "Lembretes" do Início e pelo N2.
///
/// Leitura real do banco local; atualiza o Início ao salvar ou pausar.
final lembretesProvider = StreamProvider.family<List<Lembrete>, String>(
  (ref, petId) => ref.watch(lembreteRepositorioProvider).observar(petId),
);
