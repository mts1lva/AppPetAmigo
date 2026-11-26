// P4-1.1 — Repositórios de pesagens e referências (drift + FilaSync).

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/evolucao/data/repositorios/pesagem_repositorio_drift.dart';
import 'package:petamigo/features/evolucao/data/repositorios/referencia_repositorio_drift.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';

import '../apoio/fila_gravadora.dart';

void main() {
  late BancoLocal banco;
  late FilaGravadora fila;
  late PesagemRepositorioDrift pesagens;
  late ReferenciaRepositorioDrift referencias;

  final t0 = DateTime(2026, 9, 30, 8);
  final t1 = DateTime(2026, 9, 30, 9);

  Future<void> criarPet(String id) => banco.into(banco.pets).insert(PetsCompanion.insert(
        id: id,
        criadoEm: t0,
        atualizadoEm: t0,
        nome: 'Luna',
        especie: 'gato',
        sexo: 'femea',
        idadeMeses: 72,
        idadeInformadaEm: t0,
        castrado: true,
        nivelAtividade: 'moderada',
      ));

  Pesagem pesagem(String id, double kg, DateTime data, {String petId = 'p1', bool conferida = false}) =>
      Pesagem(id: id, petId: petId, pesoKg: kg, dataHora: data, conferida: conferida);

  Referencia referencia(String id, {int? ecc = 7, double? objetivoKg, String petId = 'p1'}) => Referencia(
        id: id,
        petId: petId,
        ecc: ecc,
        objetivoKg: objetivoKg,
        origem: OrigemReferencia.veterinario,
        data: DateTime(2026, 9, 30),
      );

  setUp(() async {
    banco = BancoLocal(NativeDatabase.memory());
    fila = FilaGravadora();
    pesagens = PesagemRepositorioDrift(banco, fila);
    referencias = ReferenciaRepositorioDrift(banco, fila);
    await criarPet('p1');
    await criarPet('p2');
  });
  tearDown(() => banco.close());

  group('PesagemRepositorioDrift', () {
    test('salvar cria com versão 1, estado da fila e enfileira', () async {
      await pesagens.salvar(pesagem('w1', 5.4, DateTime(2026, 9, 30, 8)), agora: t0);

      final linha = await banco.select(banco.pesagens).getSingle();
      expect((linha.versao, linha.estadoSync, linha.conferida, linha.criadoEm), (1, 'local', false, t0));
      expect(fila.chamadas, [('pesagens', 'w1', OperacaoSync.upsert)]);
    });

    test('salvar de novo o mesmo id é edição: versão + 1, conferida gravada', () async {
      await pesagens.salvar(pesagem('w1', 5.4, DateTime(2026, 9, 30, 8)), agora: t0);
      await pesagens.salvar(pesagem('w1', 54, DateTime(2026, 9, 29, 7), conferida: true), agora: t1);

      final linha = await banco.select(banco.pesagens).getSingle();
      expect((linha.pesoKg, linha.dataHora, linha.conferida), (54.0, DateTime(2026, 9, 29, 7), true));
      expect((linha.versao, linha.criadoEm, linha.atualizadoEm), (2, t0, t1));
      expect(fila.chamadas, hasLength(2));
    });

    test('com a cópia remota ligada, grava como pendente', () async {
      fila.estado = EstadoSync.pendente;
      await pesagens.salvar(pesagem('w1', 5.4, t0), agora: t0);
      expect((await banco.select(banco.pesagens).getSingle()).estadoSync, 'pendente');
    });

    test('transação: se a fila falhar, a pesagem não fica gravada', () async {
      fila.falhar = true;
      await expectLater(pesagens.salvar(pesagem('w1', 5.4, t0), agora: t0), throwsStateError);
      expect(await banco.select(banco.pesagens).get(), isEmpty);
    });

    test('observarTodas: da mais antiga para a mais recente, só do pet, sem excluídas', () async {
      await pesagens.salvar(pesagem('w3', 5.4, DateTime(2026, 9, 30)), agora: t0);
      await pesagens.salvar(pesagem('w1', 5.6, DateTime(2026, 9, 16)), agora: t0);
      await pesagens.salvar(pesagem('w2', 5.5, DateTime(2026, 9, 23)), agora: t0);
      await pesagens.salvar(pesagem('x', 3.0, DateTime(2026, 9, 20), petId: 'p2'), agora: t0);
      await pesagens.salvar(pesagem('w4', 9.9, DateTime(2026, 9, 25)), agora: t0);
      await pesagens.excluir('w4', agora: t1);

      final todas = await pesagens.observarTodas('p1').first;
      expect(todas.map((p) => p.id), ['w1', 'w2', 'w3']);
    });

    test('observarUltima continua igual (assinatura do P1)', () async {
      await pesagens.salvar(pesagem('w1', 5.6, DateTime(2026, 9, 16)), agora: t0);
      await pesagens.salvar(pesagem('w2', 5.5, DateTime(2026, 9, 23)), agora: t0);
      expect((await pesagens.observarUltima('p1').first)?.id, 'w2');
      expect(await pesagens.observarUltima('p2').first, isNull);
    });

    test('excluir vira lápide (versão + 1) e enfileira a exclusão', () async {
      await pesagens.salvar(pesagem('w1', 5.4, t0), agora: t0);
      await pesagens.excluir('w1', agora: t1);

      final linha = await banco.select(banco.pesagens).getSingle();
      expect((linha.excluido, linha.versao, linha.atualizadoEm), (true, 2, t1));
      expect(fila.chamadas.last, ('pesagens', 'w1', OperacaoSync.excluir));
      expect(await pesagens.observarUltima('p1').first, isNull);
    });

    test('excluir algo que não existe não faz nada', () async {
      await pesagens.excluir('nada', agora: t1);
      expect(fila.chamadas, isEmpty);
    });

    test('editar uma pesagem excluída é recusado', () async {
      await pesagens.salvar(pesagem('w1', 5.4, t0), agora: t0);
      await pesagens.excluir('w1', agora: t1);
      await expectLater(pesagens.salvar(pesagem('w1', 5.5, t0), agora: t1), throwsStateError);
    });

    test('observarTodas emite de novo a cada gravação', () async {
      final emitidos = <int>[];
      final sub = pesagens.observarTodas('p1').listen((l) => emitidos.add(l.length));
      await pumpEventQueue();
      await pesagens.salvar(pesagem('w1', 5.4, t0), agora: t0);
      await pumpEventQueue();
      await pesagens.salvar(pesagem('w2', 5.3, t1), agora: t1);
      await pumpEventQueue();
      await sub.cancel();
      expect(emitidos, [0, 1, 2]);
    });
  });

  group('ReferenciaRepositorioDrift', () {
    test('sem referência → null', () async {
      expect(await referencias.observarVigente('p1').first, isNull);
    });

    test('salvar cria e enfileira; observarVigente devolve a referência', () async {
      await referencias.salvar(referencia('r1'), agora: t0);
      expect(await referencias.observarVigente('p1').first, referencia('r1'));
      expect(fila.chamadas, [('referencias', 'r1', OperacaoSync.upsert)]);
      expect(await referencias.observarVigente('p2').first, isNull);
    });

    test('salvar o mesmo id é edição: versão + 1', () async {
      await referencias.salvar(referencia('r1'), agora: t0);
      await referencias.salvar(referencia('r1', ecc: null, objetivoKg: 4.8), agora: t1);

      final linha = await banco.select(banco.referencias).getSingle();
      expect((linha.ecc, linha.objetivoKg, linha.versao), (null, 4.8, 2));
    });

    test('uma linha vigente por pet: salvar outra id vira lápide da anterior', () async {
      await referencias.salvar(referencia('r1'), agora: t0);
      await referencias.salvar(referencia('r2', ecc: 6), agora: t1);

      final vigentes = await (banco.select(banco.referencias)..where((r) => r.excluido.equals(false))).get();
      expect(vigentes.map((r) => r.id), ['r2']);
      expect(fila.chamadas, [
        ('referencias', 'r1', OperacaoSync.upsert),
        ('referencias', 'r2', OperacaoSync.upsert),
        ('referencias', 'r1', OperacaoSync.excluir),
      ]);
      expect((await referencias.observarVigente('p1').first)?.ecc, 6);
    });

    test('remover: lápide da referência e nenhuma pesagem é tocada (RF10)', () async {
      await pesagens.salvar(pesagem('w1', 5.6, DateTime(2026, 9, 16)), agora: t0);
      await pesagens.salvar(pesagem('w2', 5.4, DateTime(2026, 9, 30)), agora: t0);
      await referencias.salvar(referencia('r1'), agora: t0);
      final antes = await banco.select(banco.pesagens).get();
      fila.chamadas.clear();

      await referencias.remover('p1', agora: t1);

      expect(await referencias.observarVigente('p1').first, isNull);
      expect(fila.chamadas, [('referencias', 'r1', OperacaoSync.excluir)]);
      expect(await banco.select(banco.pesagens).get(), antes);
    });

    test('remover sem referência não faz nada', () async {
      await referencias.remover('p1', agora: t1);
      expect(fila.chamadas, isEmpty);
    });

    test('transação: se a fila falhar, nada muda', () async {
      fila.falhar = true;
      await expectLater(referencias.salvar(referencia('r1'), agora: t0), throwsStateError);
      expect(await banco.select(banco.referencias).get(), isEmpty);
    });
  });
}
