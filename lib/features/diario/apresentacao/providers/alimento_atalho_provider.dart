import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entidades/alimento.dart';

/// Alimento do atalho do pet (`pacote-2`): o da refeição mais recente; sem
/// refeição, o último alimento cadastrado; sem alimento, `null`. Usado pelo
/// card "Referência alimentar" do Início para mostrar a meta em gramas (R04).
///
/// **STUB** criado pelo P1 na P1-1.6 (`plano-de-execucao.md` → Stubs):
/// sempre `null`, então o Início mostra só as kcal (P-24).
final alimentoAtalhoProvider = StreamProvider.family<Alimento?, String>(
  (ref, petId) => Stream.value(null), // TODO(P2-2.1): ler do banco
);
