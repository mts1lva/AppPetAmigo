import '../../../pets/domain/entidades/pet.dart';

final class Dica {
  const Dica({
    required this.id,
    required this.especie,
    required this.texto,
    required this.fonte,
    required this.revisadoEm,
    required this.emRevisao,
  });
  final String id;
  final Especie especie;
  final String texto;
  final String fonte;
  final DateTime revisadoEm;
  final bool emRevisao;
}

Dica? dicaDoDia(List<Dica> dicas, Especie especie, DateTime hoje) {
  final opcoes = dicas.where((d) => d.especie == especie).toList();
  if (opcoes.isEmpty) return null;
  final diaDoAno =
      DateTime.utc(
        hoje.year,
        hoje.month,
        hoje.day,
      ).difference(DateTime.utc(hoje.year)).inDays +
      1;
  return opcoes[diaDoAno % opcoes.length];
}
