/// Resumo do dia de um pet (R02). Dart puro.
///
/// Criado pelo P1 na etapa 1, com o mínimo que o card "Hoje" do Início usa.
/// O P2 é o dono: completa e calcula de verdade na P2-2.1.
final class ResumoDia {
  const ResumoDia({
    required this.dia,
    required this.racaoKcal,
    required this.extrasKcal,
    required this.registros,
  });

  /// Dia sem nenhum registro (R09: ausência de dados não é consumo zero).
  ResumoDia.vazio(DateTime dia) : this(dia: DateTime(dia.year, dia.month, dia.day), racaoKcal: 0, extrasKcal: 0, registros: 0);

  /// O dia (00:00 no fuso do aparelho).
  final DateTime dia;

  /// Σ energia das refeições do dia.
  final double racaoKcal;

  /// Σ energia dos petiscos e extras do dia.
  final double extrasKcal;

  /// Quantidade de refeições + extras registrados no dia.
  final int registros;

  double get totalKcal => racaoKcal + extrasKcal;

  bool get temRegistros => registros > 0;

  /// Percentual dos petiscos no total (`round(extras / total × 100)`), ou
  /// `null` quando o total é zero (R02 mostra "—").
  int? get parcelaExtras => totalKcal > 0 ? (extrasKcal / totalKcal * 100).round() : null;

  @override
  bool operator ==(Object other) =>
      other is ResumoDia &&
      other.dia == dia &&
      other.racaoKcal == racaoKcal &&
      other.extrasKcal == extrasKcal &&
      other.registros == registros;

  @override
  int get hashCode => Object.hash(dia, racaoKcal, extrasKcal, registros);
}
