import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/casos_de_uso/arquivar_alimento.dart';
import '../../domain/casos_de_uso/excluir_extra.dart';
import '../../domain/casos_de_uso/excluir_refeicao.dart';
import '../../domain/casos_de_uso/salvar_alimento.dart';
import '../../domain/casos_de_uso/salvar_extra.dart';
import '../../domain/casos_de_uso/salvar_petisco.dart';
import '../../domain/casos_de_uso/salvar_refeicao.dart';
import 'repositorios_providers.dart';

final salvarAlimentoProvider = Provider(
  (ref) => SalvarAlimento(ref.watch(alimentoRepositorioProvider)),
);

final arquivarAlimentoProvider = Provider(
  (ref) => ArquivarAlimento(ref.watch(alimentoRepositorioProvider)),
);

final salvarRefeicaoProvider = Provider(
  (ref) => SalvarRefeicao(ref.watch(refeicaoRepositorioProvider)),
);

final excluirRefeicaoProvider = Provider(
  (ref) => ExcluirRefeicao(ref.watch(refeicaoRepositorioProvider)),
);

final salvarExtraProvider = Provider(
  (ref) => SalvarExtra(ref.watch(extraRepositorioProvider)),
);

final excluirExtraProvider = Provider(
  (ref) => ExcluirExtra(ref.watch(extraRepositorioProvider)),
);

final salvarPetiscoProvider = Provider(
  (ref) => SalvarPetisco(ref.watch(petiscoRepositorioProvider)),
);

/// Arquiva o petisco cadastrado (P-32): some das escolhas, sem alterar os
/// registros antigos.
final arquivarPetiscoProvider = Provider<Future<void> Function(String id, {required DateTime agora})>(
  (ref) => ref.watch(petiscoRepositorioProvider).arquivar,
);
