import '../../../../core/resultado.dart';
import '../../../nutricao/domain/meta_diaria.dart';
import '../aderencia.dart';
import '../entidades/resumo_dia.dart';

/// Caso de uso de M7: aderência ao plano alimentar na janela de 14 dias.
final class CalcularAderencia {
  const CalcularAderencia();

  Resultado<Aderencia> call({
    required Iterable<ResumoDia> dias,
    required Resultado<MetaDiaria> meta,
    required DateTime hoje,
  }) =>
      aderencia(dias: dias, meta: meta, hoje: hoje);
}
