import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entidades/lembrete.dart';

/// Lembretes do pet, usados pelo card "Lembretes" do Início e pelo N2.
///
/// **STUB** criado pelo P1 na etapa 1 (`plano-de-execucao.md` → Stubs).
final lembretesProvider = StreamProvider.family<List<Lembrete>, String>(
  (ref, petId) => Stream.value(const <Lembrete>[]), // TODO(P3-2.1): ler do banco
);
