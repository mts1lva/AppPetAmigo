import '../../../core/sugestao.dart';
import '../../pets/domain/entidades/pet.dart';
import 'entidades/atividade.dart';
import 'parametros.dart';

/// S2 de M8. Sem objetivo de perda, não sugere aumentar exercícios.
Sugestao? sugestaoExercicios({
  required Pet pet,
  required double? pesoAtualKg,
  required double? pesoIdealKg,
  required Iterable<Atividade> atividades,
  required DateTime hoje,
}) {
  if (pesoAtualKg == null ||
      pesoIdealKg == null ||
      !pesoAtualKg.isFinite ||
      !pesoIdealKg.isFinite ||
      pesoIdealKg <= 0 ||
      pesoIdealKg >= pesoAtualKg)
    return null;
  final inicio = DateTime(
    hoje.year,
    hoje.month,
    hoje.day - diasSugestaoExercicios + 1,
  );
  final minutos = atividades
      .where(
        (a) =>
            a.petId == pet.id &&
            !a.dataHora.isBefore(inicio) &&
            !a.dataHora.isAfter(hoje),
      )
      .fold<int>(0, (s, a) => s + a.duracaoMin);
  final meta = pet.especie == Especie.cao
      ? minutosDiariosCao
      : minutosDiariosGato;
  final falta = (meta - minutos / diasSugestaoExercicios).ceil();
  if (falta <= 0) return null;
  return Sugestao(
    tipo: TipoSugestao.aumentarExercicios,
    texto:
        'Mais $falta minutos de passeio ou brincadeira por dia ajudam ${pet.nome}. Veja ideias em Atividades.',
  );
}
