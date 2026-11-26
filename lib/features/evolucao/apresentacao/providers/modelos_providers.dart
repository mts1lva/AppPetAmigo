import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/relogio.dart';
import '../../../../core/resultado.dart';
import '../../../../core/sugestao.dart';
import '../../../atividades/apresentacao/providers/indicadores_atividade_provider.dart';
import '../../../diario/apresentacao/providers/aderencia_provider.dart';
import '../../../diario/apresentacao/providers/resumo_dia_provider.dart';
import '../../../nutricao/apresentacao/providers/meta_provider.dart';
import '../../../pets/apresentacao/providers/pets_providers.dart';
import '../../domain/data_prevista.dart';
import '../../domain/indicadores.dart';
import '../../domain/modelos_do_pet.dart';
import '../../domain/peso_ideal.dart';
import '../../domain/projecao.dart';
import '../../domain/sugestao_objetivo.dart';
import 'evolucao_providers.dart';

/// M9 — a cadeia inteira de um pet, recalculada sozinha a cada pesagem,
/// referência, refeição, extra ou atividade gravada (U2-05). `null` enquanto
/// algum stream de entrada ainda não emitiu.
///
/// Entradas: pesagens e referência (P4), resumos dos últimos 14 dias e
/// aderência (P2), gasto médio de atividade (P3) e meta M1 (P1).
final modelosProvider = Provider.family<ModelosDoPet?, String>((ref, petId) {
  final pesagens = ref.watch(pesagensProvider(petId));
  final referencia = ref.watch(referenciaProvider(petId));
  final resumos = ref.watch(resumosJanelaProvider(petId));
  final meta = ref.watch(metaProvider(petId));
  final gasto = ref.watch(gastoAtividadeProvider(petId));
  final aderencia = ref.watch(aderenciaProvider(petId));
  if (!pesagens.hasValue || !referencia.hasValue || !resumos.hasValue || meta == null || gasto == null) {
    return null;
  }
  return calcularModelos(
    pesagens: pesagens.value!,
    referencia: referencia.value,
    ingestao: ingestaoPorDia(resumos.value!),
    // Sem pesagem não há RER, e o gasto vem indisponível; a MER também, então
    // a parte energética de M4 fica de fora de qualquer jeito.
    atividadeKcalPorDia: gasto.valorOuNulo ?? 0,
    mer: meta.valorOuNulo?.mer,
    aderencia: aderencia,
    hoje: ref.watch(agoraProvider)(),
  );
});

/// M2.
final pesoIdealProvider = Provider.family<Resultado<PesoIdeal>?, String>(
  (ref, petId) => ref.watch(modelosProvider(petId).select((m) => m?.pesoIdeal)),
);

/// M3: `ideal(0) … ideal(90)`.
final curvaIdealProvider = Provider.family<Resultado<List<double>>?, String>(
  (ref, petId) => ref.watch(modelosProvider(petId).select((m) => m?.curvaIdeal)),
);

/// M4.
final projecaoProvider = Provider.family<Resultado<Projecao>?, String>(
  (ref, petId) => ref.watch(modelosProvider(petId).select((m) => m?.projecao)),
);

/// M5.
final dataPrevistaProvider = Provider.family<DataPrevista?, String>(
  (ref, petId) => ref.watch(modelosProvider(petId).select((m) => m?.previsao)),
);

/// M7 (evolução; a aderência vem do `aderenciaProvider` do P2).
final indicadoresProvider = Provider.family<Evolucao?, String>(
  (ref, petId) => ref.watch(modelosProvider(petId).select((m) => m?.evolucao)),
);

/// S3 Mudar objetivo (M8) do pet, para o `sugestoesProvider` do Início
/// (P4-2.1). `null` enquanto os dados carregam ou sem sugestão.
///
/// A data prevista (M5) usa a projeção completa de M4: pesagens, ingestão
/// do P2 e gasto de atividade do P3 (P4-1.3).
final sugestaoObjetivoProvider = Provider.family<Sugestao?, String>((ref, petId) {
  final modelos = ref.watch(modelosProvider(petId));
  final nome = ref.watch(petProvider(petId)).value?.nome;
  if (modelos == null || nome == null) return null;
  return sugestaoMudarObjetivoDosRegistros(
    nomePet: nome,
    pesagens: modelos.pesagens,
    referencia: ref.watch(referenciaProvider(petId)).value,
    kgDia: modelos.projecao.valorOuNulo?.kgDia,
    hoje: ref.watch(agoraProvider)(),
  );
});
