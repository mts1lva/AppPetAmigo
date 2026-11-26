import '../../../../core/sugestao.dart';
import '../entidades/resumo_dia.dart';
import '../sugestao_petiscos.dart';

/// Caso de uso de S1 (M8): sugerir reduzir petiscos.
final class AvaliarSugestaoPetiscos {
  const AvaliarSugestaoPetiscos();

  Sugestao? call({required Iterable<ResumoDia> dias, required DateTime hoje}) =>
      sugestaoPetiscos(dias: dias, hoje: hoje);
}
