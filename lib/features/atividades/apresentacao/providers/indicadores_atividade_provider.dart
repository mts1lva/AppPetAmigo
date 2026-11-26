import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/relogio.dart';
import '../../../../core/resultado.dart';
import '../../../../core/sugestao.dart';
import '../../../evolucao/apresentacao/providers/ultima_pesagem_provider.dart';
import '../../../nutricao/apresentacao/providers/meta_provider.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/gasto_atividade.dart';
import '../../domain/sugestao_exercicios.dart';
import 'atividades_providers.dart';

/// Contrato para o P4 ligar o peso ideal do M2. Sem M2, não inventa objetivo.
/// O P4 troca este corpo pela leitura de pesoIdealProvider(petId).
final pesoIdealAtividadeProvider = Provider.family<double?, String>(
  (ref, petId) => null,
);

/// Média diária de kcal de atividade nos últimos 14 dias, para a projeção do P4.
/// `null` durante a leitura; Indisponivel quando não existe pesagem para o RER.
final gastoAtividadeProvider = Provider.family<Resultado<double>?, String>((
  ref,
  petId,
) {
  final atividades = ref.watch(atividadesProvider(petId));
  final meta = ref.watch(metaProvider(petId));
  if (!atividades.hasValue || meta == null) return null;
  final valor = meta.valorOuNulo;
  if (valor == null) {
    return const Indisponivel('Registre uma pesagem para calcular a meta.');
  }
  return mediaGastoAtividade(
    atividades.value!,
    valor.rer,
    ref.watch(agoraProvider)(),
  );
});

final sugestaoExerciciosProvider = Provider.family<Sugestao?, String>((
  ref,
  petId,
) {
  final ideal = ref.watch(pesoIdealAtividadeProvider(petId));
  if (ideal == null) return null;
  final pet = ref.watch(petProvider(petId)).value;
  final peso = ref.watch(ultimaPesagemProvider(petId)).value?.pesoKg;
  final atividades = ref.watch(atividadesProvider(petId));
  if (pet == null || !atividades.hasValue) return null;
  return sugestaoExercicios(
    pet: pet,
    pesoAtualKg: peso,
    pesoIdealKg: ideal,
    atividades: atividades.value!,
    hoje: ref.watch(agoraProvider)(),
  );
});
