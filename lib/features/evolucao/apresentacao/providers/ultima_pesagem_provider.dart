import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/banco/banco_provider.dart';
import '../../data/repositorios/pesagem_repositorio_drift.dart';
import '../../domain/entidades/pesagem.dart';
import '../../domain/repositorios/pesagem_repositorio.dart';

final pesagemRepositorioProvider = Provider<PesagemRepositorio>(
  (ref) => PesagemRepositorioDrift(ref.watch(bancoProvider)),
);

/// Última pesagem do pet, ou `null` sem pesagem. Usada pela meta (M1) e pelo
/// peso do card do Início.
///
/// **Real** desde a etapa 1 (não é stub): lê a tabela `pesagens`, onde o
/// cadastro do pet grava a primeira pesagem. O P4 assume na P4-1.1.
final ultimaPesagemProvider = StreamProvider.family<Pesagem?, String>(
  (ref, petId) => ref.watch(pesagemRepositorioProvider).observarUltima(petId),
);
