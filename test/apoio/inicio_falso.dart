import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:petamigo/core/sugestao.dart';
import 'package:petamigo/features/evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import 'package:petamigo/features/inicio/apresentacao/providers/sugestoes_provider.dart';
import 'package:petamigo/features/inicio/domain/repositorios/sugestoes_adiadas_repositorio.dart';

import 'pets_falsos.dart';

/// "Agora não" falso: só anota o que foi adiado.
final class AdiadasFalsas implements SugestoesAdiadasRepositorio {
  final adiadas = <TipoSugestao, DateTime>{};

  @override
  Stream<Map<TipoSugestao, DateTime>> observar() => Stream.value(const {});

  @override
  Future<void> adiar(TipoSugestao tipo, DateTime em) async => adiadas[tipo] = em;
}

/// Overrides para montar o app inteiro (com a aba Início real) sem abrir o
/// banco: pets falsos, nenhuma pesagem e nenhuma sugestão adiada.
List<Override> overridesSemBanco([PetsFalsos? pets]) => [
  ...(pets ?? PetsFalsos()).overrides,
  ultimaPesagemProvider.overrideWith((ref, petId) => Stream.value(null)),
  sugestoesAdiadasRepositorioProvider.overrideWithValue(AdiadasFalsas()),
];
