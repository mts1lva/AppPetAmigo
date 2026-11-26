import '../entidades/extra.dart';
import '../entidades/refeicao.dart';
import '../entidades/resumo_dia.dart';
import '../resumo_do_dia.dart';

/// Caso de uso de R02: totais de ração, extras e registros de um dia.
final class CalcularResumoDia {
  const CalcularResumoDia();

  ResumoDia call({
    required DateTime dia,
    required Iterable<Refeicao> refeicoes,
    required Iterable<Extra> extras,
  }) =>
      resumoDoDia(dia: dia, refeicoes: refeicoes, extras: extras);
}
