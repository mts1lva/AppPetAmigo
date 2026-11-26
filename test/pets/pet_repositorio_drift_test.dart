import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/daos/config_dao.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/pets/data/repositorios/pet_repositorio_drift.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

/// Fila que registra as chamadas; pode simular a cópia ligada ou uma falha.
final class _FilaGravadora implements FilaSync {
  EstadoSync estado = EstadoSync.local;
  bool falhar = false;
  final chamadas = <(String, String, OperacaoSync)>[];

  @override
  Future<EstadoSync> estadoInicial() async => estado;

  @override
  Future<void> enfileirar(String tabela, String registroId, OperacaoSync op) async {
    if (falhar) throw StateError('falha simulada');
    chamadas.add((tabela, registroId, op));
  }
}

void main() {
  late BancoLocal banco;
  late _FilaGravadora fila;
  late PetRepositorioDrift repo;
  var contador = 0;

  final t0 = DateTime(2026, 9, 1, 8);
  final t1 = DateTime(2026, 9, 2, 8);
  final t2 = DateTime(2026, 9, 3, 8);

  Pet pet(String id, {String nome = 'Luna'}) => Pet(
        id: id,
        nome: nome,
        especie: Especie.gato,
        sexo: Sexo.femea,
        idadeMeses: 72,
        idadeInformadaEm: t0,
        castrado: true,
        nivelAtividade: NivelAtividade.moderada,
      );

  setUp(() {
    banco = BancoLocal(NativeDatabase.memory());
    fila = _FilaGravadora();
    contador = 0;
    repo = PetRepositorioDrift(banco, fila, novoId: () => 'id-${++contador}');
  });
  tearDown(() => banco.close());

  Future<String?> petAtual() => banco.configDao.ler(ChavesConfig.petAtualId);

  group('cadastrar', () {
    test('grava o pet e a primeira pesagem, enfileira os dois e torna o pet atual', () async {
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0);

      final linha = await banco.select(banco.pets).getSingle();
      expect((linha.id, linha.versao, linha.estadoSync, linha.excluido), ('p1', 1, 'local', false));
      final pesagem = await banco.select(banco.pesagens).getSingle();
      expect((pesagem.id, pesagem.petId, pesagem.pesoKg, pesagem.dataHora), ('id-1', 'p1', 5.4, t0));
      expect(fila.chamadas, [
        ('pets', 'p1', OperacaoSync.upsert),
        ('pesagens', 'id-1', OperacaoSync.upsert),
      ]);
      expect(await petAtual(), 'p1');
      expect(await repo.observarPesoInicial('p1').first, 5.4);
    });

    test('com a cópia remota ligada, grava como pendente', () async {
      fila.estado = EstadoSync.pendente;
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0);
      expect((await banco.select(banco.pets).getSingle()).estadoSync, 'pendente');
      expect((await banco.select(banco.pesagens).getSingle()).estadoSync, 'pendente');
    });

    test('transação: se a fila falhar, nada fica gravado', () async {
      fila.falhar = true;
      await expectLater(repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0), throwsStateError);
      expect(await banco.select(banco.pets).get(), isEmpty);
      expect(await banco.select(banco.pesagens).get(), isEmpty);
      expect(await petAtual(), isNull);
    });

    test('vários pets por ordem de cadastro; o último cadastrado vira o atual', () async {
      await repo.cadastrar(pet('p1', nome: 'Luna'), pesoInicialKg: 5.4, agora: t0);
      await repo.cadastrar(pet('p2', nome: 'Thor'), pesoInicialKg: 20, agora: t1);
      expect((await repo.observarTodos().first).map((p) => p.nome), ['Luna', 'Thor']);
      expect(await petAtual(), 'p2');
      expect(await repo.observar('p2').first, pet('p2', nome: 'Thor'));
    });
  });

  group('editar', () {
    test('grava os campos com versão + 1 e enfileira', () async {
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0);
      fila.chamadas.clear();

      await repo.editar(pet('p1').copyWith(nome: 'Luna Maria', castrado: false), agora: t1);

      final linha = await banco.select(banco.pets).getSingle();
      expect((linha.nome, linha.castrado, linha.versao, linha.atualizadoEm), ('Luna Maria', false, 2, t1));
      expect(fila.chamadas, [('pets', 'p1', OperacaoSync.upsert)]);
      expect((await banco.select(banco.pesagens).getSingle()).versao, 1, reason: 'peso não mudou');
    });

    test('peso inicial altera só a primeira pesagem (U2-06)', () async {
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.6, agora: t0);
      await banco.into(banco.pesagens).insert(PesagensCompanion.insert(
            id: 'w2',
            criadoEm: t1,
            atualizadoEm: t1,
            petId: 'p1',
            pesoKg: 5.5,
            dataHora: t1,
          ));
      fila.chamadas.clear();

      await repo.editar(pet('p1'), pesoInicialKg: 5.7, agora: t2);

      final pesos = {for (final p in await banco.select(banco.pesagens).get()) p.id: (p.pesoKg, p.versao)};
      expect(pesos, {'id-1': (5.7, 2), 'w2': (5.5, 1)});
      expect(fila.chamadas, [('pets', 'p1', OperacaoSync.upsert), ('pesagens', 'id-1', OperacaoSync.upsert)]);
      expect(await repo.observarPesoInicial('p1').first, 5.7);
    });

    test('peso inicial mantido na tela 25 grava conferida; um valor comum depois limpa (R06, P4-2.1)', () async {
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0);

      await repo.editar(pet('p1'), pesoInicialKg: 54, pesoInicialConferido: true, agora: t1);
      expect((await banco.select(banco.pesagens).getSingle()).conferida, isTrue);

      await repo.editar(pet('p1'), pesoInicialKg: 5.4, agora: t2);
      expect((await banco.select(banco.pesagens).getSingle()).conferida, isFalse);
    });

    test('pet inexistente → StateError', () async {
      await expectLater(repo.editar(pet('nao-existe'), agora: t1), throwsStateError);
    });
  });

  group('excluir', () {
    Future<void> registrarRefeicao(String id, String petId) => banco.into(banco.refeicoes).insert(
          RefeicoesCompanion.insert(
            id: id,
            criadoEm: t1,
            atualizadoEm: t1,
            petId: petId,
            alimentoNome: 'Ração',
            densidadeKcalPor100g: 360,
            quantidadeG: 30,
            energiaKcal: 108,
            dataHora: t1,
          ),
        );

    test('lápide em cascata no pet e nos registros dele; os do outro pet ficam', () async {
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0); // pesagem id-1
      await repo.cadastrar(pet('p2'), pesoInicialKg: 20, agora: t0); // pesagem id-2
      await registrarRefeicao('r1', 'p1');
      await registrarRefeicao('r2', 'p2');
      fila.chamadas.clear();

      await repo.excluir('p1', agora: t2);

      final p1 = await (banco.select(banco.pets)..where((p) => p.id.equals('p1'))).getSingle();
      expect((p1.excluido, p1.versao, p1.atualizadoEm), (true, 2, t2));
      final refeicoes = {for (final r in await banco.select(banco.refeicoes).get()) r.id: (r.excluido, r.versao)};
      expect(refeicoes, {'r1': (true, 2), 'r2': (false, 1)});
      final pesagens = {for (final p in await banco.select(banco.pesagens).get()) p.id: p.excluido};
      expect(pesagens, {'id-1': true, 'id-2': false});
      expect(fila.chamadas.toSet(), {
        ('pets', 'p1', OperacaoSync.excluir),
        ('refeicoes', 'r1', OperacaoSync.excluir),
        ('pesagens', 'id-1', OperacaoSync.excluir),
      });
      expect((await repo.observarTodos().first).map((p) => p.id), ['p2']);
      expect(await repo.observar('p1').first, isNull);
    });

    test('excluir o pet atual passa para o primeiro da lista por ordem de cadastro', () async {
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0);
      await repo.cadastrar(pet('p2'), pesoInicialKg: 6, agora: t1);
      await repo.cadastrar(pet('p3'), pesoInicialKg: 7, agora: t2);
      expect(await petAtual(), 'p3');

      await repo.excluir('p3', agora: t2);
      expect(await petAtual(), 'p1');
    });

    test('excluir um pet que não é o atual não muda o atual', () async {
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0);
      await repo.cadastrar(pet('p2'), pesoInicialKg: 6, agora: t1);
      await repo.excluir('p1', agora: t2);
      expect(await petAtual(), 'p2');
    });

    test('excluir o último pet deixa sem pet atual (tela 26)', () async {
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0);
      await repo.excluir('p1', agora: t1);
      expect(await petAtual(), isNull);
      expect(await repo.observarTodos().first, isEmpty);
    });

    test('a lista de pets atualiza sozinha (stream do drift)', () async {
      final emitidos = <List<String>>[];
      final assinatura = repo.observarTodos().listen((l) => emitidos.add([for (final p in l) p.id]));
      await pumpEventQueue();
      await repo.cadastrar(pet('p1'), pesoInicialKg: 5.4, agora: t0);
      await pumpEventQueue();
      await repo.excluir('p1', agora: t1);
      await pumpEventQueue();
      await assinatura.cancel();
      expect(emitidos, [
        <String>[],
        ['p1'],
        <String>[],
      ]);
    });
  });
}
