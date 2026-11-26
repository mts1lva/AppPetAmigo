import 'dart:convert';

import 'package:flutter/services.dart';

import '../../pets/domain/entidades/pet.dart';
import '../domain/entidades/dica.dart';

final class DicasLocais {
  Future<List<Dica>> carregar() async =>
      decodificar(await rootBundle.loadString('assets/conteudo/dicas.json'));

  static List<Dica> decodificar(String json) => [
    for (final d in jsonDecode(json) as List<dynamic>)
      Dica(
        id: d['id'] as String,
        especie: Especie.values.byName(d['especie'] as String),
        texto: d['texto'] as String,
        fonte: d['fonte'] as String,
        revisadoEm: DateTime.parse('${d['revisadoEm']}-01'),
        emRevisao: d['situacao'] == 'em_revisao',
      ),
  ];
}
