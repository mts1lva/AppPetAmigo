// Migrações do banco local. `esquema_v1.sql` é o esquema da versão 1, tirado
// do sqlite_master antes da P-32: o teste monta um banco antigo com dados e
// abre com o código atual, como acontece no aparelho de quem atualiza o app.

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/database.dart';

/// Banco na versão 1 com uma Luna, uma ração e um petisco digitado.
NativeDatabase bancoV1() => NativeDatabase.memory(setup: (db) {
      for (final sql in File('test/core/banco/esquema_v1.sql').readAsStringSync().split(';\n')) {
        if (sql.trim().isNotEmpty) db.execute(sql);
      }
      db.execute(
        "INSERT INTO pets (id, criado_em, atualizado_em, nome, especie, sexo, idade_meses, idade_informada_em, "
        "castrado, nivel_atividade) VALUES ('p1', 0, 0, 'Luna', 'gato', 'femea', 72, 0, 1, 'moderada')",
      );
      db.execute(
        "INSERT INTO alimentos (id, criado_em, atualizado_em, pet_id, nome, densidade_kcal_por100g, porcao_padrao_g) "
        "VALUES ('a1', 0, 0, 'p1', 'Ração habitual', 360, 30)",
      );
      db.execute(
        "INSERT INTO extras (id, criado_em, atualizado_em, pet_id, descricao, quantidade_g, energia_kcal, data_hora) "
        "VALUES ('e1', 0, 0, 'p1', 'Petisco', 3, 12, 0)",
      );
      db.execute('PRAGMA user_version = 1');
    });

/// Tabelas com as colunas (nome, tipo, obrigatória, padrão, chave) e as
/// chaves estrangeiras, em ordem
/// de nome, e índices com as colunas. `addColumn` põe a coluna no fim da
/// tabela, então a ordem das colunas não entra na comparação.
Future<Map<String, Object>> esquema(BancoLocal banco) async {
  final objetos = await banco
      .customSelect("SELECT type, name FROM sqlite_master WHERE name NOT LIKE 'sqlite_%' ORDER BY name")
      .get();
  final resultado = <String, Object>{};
  for (final o in objetos) {
    final nome = o.read<String>('name');
    if (o.read<String>('type') == 'table') {
      final colunas = await banco.customSelect('PRAGMA table_info("$nome")').get();
      final chaves = await banco.customSelect('PRAGMA foreign_key_list("$nome")').get();
      resultado[nome] = ([
        for (final c in colunas)
          '${c.read<String>('name')} ${c.read<String>('type')} notnull=${c.read<int>('notnull')} '
              'padrao=${c.readNullable<String>('dflt_value')} pk=${c.read<int>('pk')}',
        for (final k in chaves)
          'fk ${k.read<String>('from')} → ${k.read<String>('table')}.${k.read<String>('to')} '
              'on_delete=${k.read<String>('on_delete')}',
      ]..sort());
    } else {
      final colunas = await banco.customSelect('PRAGMA index_info("$nome")').get();
      resultado[nome] = [for (final c in colunas) c.read<String>('name')];
    }
  }
  return resultado;
}

void main() {
  group('versão 1 → 2 (P-32, petiscos cadastrados)', () {
    test('os dados continuam e a ração antiga vira tipo racao', () async {
      final banco = BancoLocal(bancoV1());
      addTearDown(banco.close);

      final alimento = await banco.select(banco.alimentos).getSingle();
      expect(alimento.tipo, 'racao');
      expect((alimento.densidadeKcalPor100g, alimento.porcaoPadraoG), (360, 30));
      expect((alimento.kcalPorUnidade, alimento.unidadesHabituais), (null, null));

      final extra = await banco.select(banco.extras).getSingle();
      expect((extra.descricao, extra.energiaKcal, extra.quantidadeG), ('Petisco', 12, 3));
      expect((extra.alimentoId, extra.unidades), (null, null));
    });

    test('o esquema migrado é igual ao de um banco novo, com índices', () async {
      final migrado = BancoLocal(bancoV1());
      final novo = BancoLocal(NativeDatabase.memory());
      addTearDown(migrado.close);
      addTearDown(novo.close);

      final m = await esquema(migrado);
      expect(m, await esquema(novo));
      expect(m.keys, contains('idx_alimentos_pet'));
      expect(await migrado.customSelect('PRAGMA user_version').map((l) => l.read<int>('user_version')).getSingle(), 2);
    });

    test('a chave estrangeira continua valendo depois da migração', () async {
      final banco = BancoLocal(bancoV1());
      addTearDown(banco.close);

      await banco.select(banco.alimentos).get(); // abre e migra
      await expectLater(
        banco.customStatement(
          "INSERT INTO alimentos (id, criado_em, atualizado_em, pet_id, nome, tipo, kcal_por_unidade, "
          "unidades_habituais) VALUES ('a2', 0, 0, 'sem-pet', 'Bifinho', 'petisco', 3, 2)",
        ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
