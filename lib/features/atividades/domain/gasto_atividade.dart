import '../../../core/resultado.dart';
import 'entidades/atividade.dart';
import 'parametros.dart';

/// M4: a atividade alimenta a projeção, sem alterar a meta alimentar.
Resultado<double> gastoAtividade(Atividade atividade, double rer) {
  if (atividade.duracaoMin <= 0 ||
      atividade.duracaoMin > duracaoMaximaMinutos) {
    return const Indisponivel('Informe a duração em minutos.');
  }
  if (!rer.isFinite || rer <= 0)
    return const Indisponivel('Registre uma pesagem para calcular a meta.');
  final met = atividade.tipo == TipoAtividade.passeio
      ? metPasseio
      : metBrincadeira;
  final kcal = rer / 24 * (met - 1) * (atividade.duracaoMin / 60);
  return kcal.isFinite
      ? Disponivel(kcal)
      : const Indisponivel('O valor precisa ser positivo.');
}

/// Janela de 14 dias civis, incluindo os dias sem atividade no divisor.
Resultado<double> mediaGastoAtividade(
  Iterable<Atividade> atividades,
  double rer,
  DateTime hoje,
) {
  final inicio = DateTime(
    hoje.year,
    hoje.month,
    hoje.day - diasMediaAtividade + 1,
  );
  var soma = 0.0;
  for (final atividade in atividades) {
    if (atividade.dataHora.isBefore(inicio) || atividade.dataHora.isAfter(hoje))
      continue;
    final gasto = gastoAtividade(atividade, rer);
    if (gasto case Indisponivel<double>()) return gasto;
    soma += gasto.valorOuNulo!;
  }
  return Disponivel(soma / diasMediaAtividade);
}
