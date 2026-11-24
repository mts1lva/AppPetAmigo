import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/relogio.dart';
import '../../../../core/resultado.dart';
import '../../../evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/meta_diaria.dart';

/// Meta diária do pet (M1, R03). Recalcula sozinha quando muda a última
/// pesagem, a idade, a castração ou o nível de atividade (M9), porque observa
/// o pet e a pesagem. `null` enquanto o pet ou a pesagem ainda carregam.
///
/// Sem pesagem: `Indisponivel('Registre uma pesagem para calcular a meta.')`.
final metaProvider = Provider.family<Resultado<MetaDiaria>?, String>((ref, petId) {
  final pet = ref.watch(petProvider(petId)).value;
  final pesagem = ref.watch(ultimaPesagemProvider(petId));
  if (pet == null || !pesagem.hasValue) return null;
  return metaDiaria(pet, pesagem.value?.pesoKg, ref.watch(agoraProvider)());
});
