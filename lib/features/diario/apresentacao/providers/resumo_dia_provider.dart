import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entidades/resumo_dia.dart';

/// Resumo de um dia do pet (R02), usado pelo card "Hoje" do Início e pelo
/// Diário. Passe o dia sem hora: `DateTime(a, m, d)`.
///
/// **STUB** criado pelo P1 na etapa 1 (`plano-de-execucao.md` → Stubs).
final resumoDiaProvider = StreamProvider.family<ResumoDia, (String petId, DateTime dia)>(
  (ref, args) => Stream.value(ResumoDia.vazio(args.$2)), // TODO(P2-2.1): ler do banco
);
