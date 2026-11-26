import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/daos/config_dao.dart';
import 'package:petamigo/core/banco/database.dart';

void main() {
  late BancoLocal banco;

  setUp(() => banco = BancoLocal(NativeDatabase.memory()));
  tearDown(() => banco.close());

  Future<List<String>> nomes(String tipo) async {
    final linhas = await banco
        .customSelect("SELECT name FROM sqlite_master WHERE type = ? AND name NOT LIKE 'sqlite_%' ORDER BY name",
            variables: [Variable.withString(tipo)])
        .get();
    return [for (final l in linhas) l.read<String>('name')];
  }

  final agora = DateTime(2026, 9, 30, 8);

  PetsCompanion pet(String id) => PetsCompanion.insert(
        id: id,
        criadoEm: agora,
        atualizadoEm: agora,
        nome: 'Luna',
        especie: 'gato',
        sexo: 'femea',
        idadeMeses: 72,
        idadeInformadaEm: agora,
        castrado: true,
        nivelAtividade: 'moderada',
      );

  PesagensCompanion pesagem(String id, String petId) => PesagensCompanion.insert(
        id: id,
        criadoEm: agora,
        atualizadoEm: agora,
        petId: petId,
        pesoKg: 5.4,
        dataHora: agora,
      );

  group('Esquema (versão 2, P-32)', () {
    test('todas as tabelas de domínio e de controle existem', () async {
      expect(banco.schemaVersion, 2);
      expect(await nomes('table'), [
        'alimentos',
        'atividades',
        'config',
        'conflitos',
        'extras',
        'fila_sync',
        'lembretes',
        'pesagens',
        'pets',
        'refeicoes',
        'referencias',
      ]);
    });

    test('índices obrigatórios: (petId, dataHora), petId e (tabela, registroId)', () async {
      expect(await nomes('index'), [
        'idx_alimentos_pet',
        'idx_atividades_pet_data',
        'idx_extras_pet_data',
        'idx_fila_sync_registro',
        'idx_lembretes_pet',
        'idx_pesagens_pet_data',
        'idx_refeicoes_pet_data',
        'idx_referencias_pet',
      ]);
    });

    test('colunas de controle com os valores iniciais', () async {
      await banco.into(banco.pets).insert(pet('p1'));
      final linha = await banco.select(banco.pets).getSingle();
      expect(linha.versao, 1);
      expect(linha.versaoRemota, isNull);
      expect(linha.estadoSync, 'local');
      expect(linha.excluido, isFalse);
      expect(linha.fotoArquivo, isNull);
    });

    test('chaves estrangeiras ligadas: registro sem pet é recusado', () async {
      final fk = await banco.customSelect('PRAGMA foreign_keys').getSingle();
      expect(fk.read<int>('foreign_keys'), 1);
      await expectLater(banco.into(banco.pesagens).insert(pesagem('w1', 'nao-existe')), throwsA(isA<Exception>()));
    });

    test('apagar o pet de verdade apaga os registros dele (limpeza da lápide)', () async {
      await banco.into(banco.pets).insert(pet('p1'));
      await banco.into(banco.pets).insert(pet('p2'));
      await banco.into(banco.pesagens).insert(pesagem('w1', 'p1'));
      await banco.into(banco.pesagens).insert(pesagem('w2', 'p2'));

      await (banco.delete(banco.pets)..where((p) => p.id.equals('p1'))).go();

      final restantes = await banco.select(banco.pesagens).get();
      expect(restantes.map((p) => p.id), ['w2']);
    });

    test('notificacaoId dos lembretes é único', () async {
      await banco.into(banco.pets).insert(pet('p1'));
      LembretesCompanion lembrete(String id) => LembretesCompanion.insert(
            id: id,
            criadoEm: agora,
            atualizadoEm: agora,
            petId: 'p1',
            hora: 480,
            tipo: 'refeicao',
            notificacaoId: 7,
          );
      await banco.into(banco.lembretes).insert(lembrete('l1'));
      await expectLater(banco.into(banco.lembretes).insert(lembrete('l2')), throwsA(isA<Exception>()));
    });
  });

  group('ConfigDao', () {
    test('gravar, ler, observar e remover', () async {
      final dao = banco.configDao;
      final emitidos = <String?>[];
      final assinatura = dao.observar(ChavesConfig.petAtualId).listen(emitidos.add);

      expect(await dao.ler(ChavesConfig.petAtualId), isNull);
      await pumpEventQueue();
      await dao.gravar(ChavesConfig.petAtualId, 'p1');
      expect(await dao.ler(ChavesConfig.petAtualId), 'p1');
      await pumpEventQueue();
      await dao.gravar(ChavesConfig.petAtualId, 'p2');
      await pumpEventQueue();
      await dao.gravar(ChavesConfig.petAtualId, null);
      expect(await dao.ler(ChavesConfig.petAtualId), isNull);
      await pumpEventQueue();
      await assinatura.cancel();
      expect(emitidos, [null, 'p1', 'p2', null]);
    });
  });
}
