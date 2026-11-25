/// Textos do Diário (R02, R04, R08, R09) e do atalho. Dart puro: as funções
/// recebem o resumo e a meta já calculados.
library;

import '../../../core/formato/numeros.dart';
import '../../../core/resultado.dart';
import '../../nutricao/domain/meta_diaria.dart';
import 'aderencia.dart';
import 'entidades/resumo_dia.dart';

/// R09 — dia sem nenhum registro. Não mostrar "0 kcal".
const textoSemRegistros = 'Sem registros nesta data. Ausência de dados não significa consumo zero.';

const textoSemMeta = 'Registre uma pesagem para ver a meta.';

/// Card "Resumo do dia" do Diário (R02). Duas linhas separadas por `\n`.
/// Sem registros: só [textoSemRegistros] (R09).
String textoResumoDia(ResumoDia resumo, Resultado<MetaDiaria>? meta) {
  if (!resumo.temRegistros) return textoSemRegistros;

  final petiscos = resumo.parcelaExtras == null ? '—' : formatarPercentual(resumo.parcelaExtras!.toDouble());
  final total = formatarNumero(resumo.totalKcal, casas: 0);

  switch (meta) {
    case Disponivel(valor: final m):
      final mer = formatarNumero(m.mer, casas: 0);
      final linha1 = '$total de $mer kcal • Petiscos $petiscos dos registros';
      final falta = m.mer - resumo.totalKcal;
      final linha2 = falta >= 0
          ? 'Faltam ${formatarNumero(falta, casas: 0)} kcal para a meta de hoje.'
          : '${formatarNumero(-falta, casas: 0)} kcal acima da meta de hoje.';
      return '$linha1\n$linha2';
    case Indisponivel() || null:
      return '$total kcal • Petiscos $petiscos dos registros\n$textoSemMeta';
  }
}

/// R04 — gramas da meta com a densidade do alimento do atalho, arredondadas
/// ao grama e sempre com "≈". `null` se a conversão for indisponível.
String? textoGramasAproximadas(Resultado<double> gramas) => switch (gramas) {
      Disponivel(:final valor) => '≈ ${formatarNumero(valor, casas: 0)} g',
      Indisponivel() => null,
    };

/// Linha extra do atalho 06 (U2-01): `Meta de hoje: 397 kcal (≈ 110 g)`.
/// Sem meta, `null` (o atalho não mostra a linha). Sem gramas, só as kcal.
String? textoMetaNoAtalho(Resultado<MetaDiaria>? meta, Resultado<double>? gramasDaMeta) {
  switch (meta) {
    case Disponivel(valor: final m):
      final kcal = 'Meta de hoje: ${formatarEnergia(m.mer)}';
      final g = gramasDaMeta == null ? null : textoGramasAproximadas(gramasDaMeta);
      return g == null ? kcal : '$kcal ($g)';
    case Indisponivel() || null:
      return null;
  }
}

/// R08 — depois de salvar uma refeição (tela 20).
String textoRefeicaoSalva({required double antesKcal, required ResumoDia depois}) =>
    'O diário passa de ${formatarNumero(antesKcal, casas: 0)} para ${formatarNumero(depois.totalKcal, casas: 0)} kcal. '
    'Ração ${formatarEnergia(depois.racaoKcal)} • Petiscos ${formatarEnergia(depois.extrasKcal)}. '
    'Continue no seu ritmo.';

/// M7 — `67% (4 de 6 dias com registro)`.
String textoAderencia(Aderencia a) =>
    '${formatarPercentual(a.percentual)} (${a.aderentes} de ${a.diasComRegistro} dias com registro)';
