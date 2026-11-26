import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/atividades/data/dicas_locais.dart';
import 'package:petamigo/features/atividades/domain/entidades/dica.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

void main() {
  test(
    'catálogo local: três dicas por espécie, com fonte e conteúdo em revisão',
    () {
      final dicas = DicasLocais.decodificar(
        File('assets/conteudo/dicas.json').readAsStringSync(),
      );
      expect(dicas.map((d) => d.id).toSet(), hasLength(dicas.length));
      for (final especie in Especie.values) {
        expect(
          dicas.where((d) => d.especie == especie).length,
          greaterThanOrEqualTo(3),
        );
        final hoje = DateTime(2026, 9, 30);
        expect(dicaDoDia(dicas, especie, hoje)?.especie, especie);
        expect(
          dicaDoDia(dicas, especie, hoje)?.id,
          isNot(
            dicaDoDia(dicas, especie, hoje.add(const Duration(days: 1)))?.id,
          ),
        );
      }
      expect(
        dicas.every(
          (d) => d.emRevisao && d.fonte.isNotEmpty && d.texto.isNotEmpty,
        ),
        isTrue,
      );
    },
  );
}
