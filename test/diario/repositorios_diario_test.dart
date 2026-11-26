import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/diario/data/repositorios/alimento_repositorio_drift.dart';
import 'package:petamigo/features/diario/data/repositorios/extra_repositorio_drift.dart';
import 'package:petamigo/features/diario/data/repositorios/refeicao_repositorio_drift.dart';
import 'package:petamigo/features/diario/domain/casos_de_uso/salvar_refeicao.dart';
import 'package:petamigo/features/diario/domain/entidades/alimento.dart';
import 'package:petamigo/features/diario/domain/entidades/extra.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';

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
  late AlimentoRepositorioDrift alimentos;
  late RefeicaoRepositorioDrift refeicoes;
  late ExtraRepositorioDrift extras;

  final t0 = DateTime(2026, 9, 30, 8);
  final t1 = DateTime(2026, 9, 30, 12);
  final hoje = DateTime(2026, 9, 30);
  final amanha = DateTime(2026, 10, 1);

  Alimento racao({String id = 'a1', String petId = 'p1', double densidade = 360, bool arquivado = false}) =>
      Alimento(
        id: id,
        petId: petId,
        nome: 'Ração habitual',
        densidadeKcalPor100g: densidade,
        porcaoPadraoG: 30,
        arquivado: arquivado,
      );

  Refeicao refeicao({
    String id = 'r1',
    String petId = 'p1',
    String? alimentoId = 'a1',
    double quantidade = 30,
    double densidade = 360,
    double energia = 108,
    DateTime? quando,
  }) =>
      Refeicao(
        id: id,
        petId: petId,
        alimentoId: alimentoId,
        alimentoNome: 'Ração habitual',
        densidadeKcalPor100g: densidade,
        quantidadeG: quantidade,
        energiaKcal: energia,
        dataHora: quando ?? t0,
      );

  Extra petisco({String id = 'e1', String petId = 'p1', DateTime? quando}) => Extra(
        id: id,
        petId: petId,
        descricao: 'Petisco',
        quantidadeG: 3,
        energiaKcal: 12,
        dataHora: quando ?? t1,
      );

  Future<void> cadastrarPet(String id) => banco.into(banco.pets).insert(PetsCompanion.insert(
        id: id,
        criadoEm: t0,
        atualizadoEm: t0,
        nome: id,
        especie: 'gato',
        sexo: 'femea',
        idadeMeses: 72,
        idadeInformadaEm: t0,
        castrado: true,
        nivelAtividade: 'moderada',
      ));

  setUp(() async {
    banco = BancoLocal(NativeDatabase.memory());
    fila = _FilaGravadora();
    alimentos = AlimentoRepositorioDrift(banco, fila);
    refeicoes = RefeicaoRepositorioDrift(banco, fila);
    extras = ExtraRepositorioDrift(banco, fila);
    await cadastrarPet('p1');
    await cadastrarPet('p2');
  });
  tearDown(() => banco.close());

  group('alimentos', () {
    test('grava, enfileira upsert e lista só os do pet', () async {
      await alimentos.salvar(racao(), agora: t0);
      await alimentos.salvar(racao(id: 'a2', petId: 'p2'), agora: t0);

      expect((await banco.select(banco.alimentos).get()).map((l) => (l.id, l.versao, l.estadoSync)), [
        ('a1', 1, 'local'),
        ('a2', 1, 'local'),
      ]);
      expect(fila.chamadas, [
        ('alimentos', 'a1', OperacaoSync.upsert),
        ('alimentos', 'a2', OperacaoSync.upsert),
      ]);
      expect((await alimentos.observarDoPet('p1').first).map((a) => a.id), ['a1']);
    });

    test('editar soma versão; transação desfaz se a fila falhar', () async {
      await alimentos.salvar(racao(), agora: t0);
      fila.chamadas.clear();
      await alimentos.salvar(racao(densidade: 400), agora: t1);
      expect((await banco.select(banco.alimentos).getSingle()).densidadeKcalPor100g, 400);
      expect((await banco.select(banco.alimentos).getSingle()).versao, 2);

      fila.falhar = true;
      await expectLater(alimentos.salvar(racao(id: 'a3'), agora: t1), throwsStateError);
      expect(await alimentos.observarDoPet('p1').first, [racao(densidade: 400)]);
    });

    test('arquivar some das escolhas e não altera a refeição antiga (RF04)', () async {
      await alimentos.salvar(racao(), agora: t0);
      await refeicoes.salvar(refeicao(), agora: t0);
      fila.chamadas.clear();

      await alimentos.arquivar('a1', agora: t1);
      await alimentos.salvar(racao().copyWith(densidadeKcalPor100g: 400, arquivado: true), agora: t1);

      expect(await alimentos.observarDoPet('p1').first, isEmpty);
      final refeicaoSalva = await refeicoes.observar('r1').first;
      expect(refeicaoSalva!.densidadeKcalPor100g, 360);
      expect(refeicaoSalva.energiaKcal, 108);
      expect(fila.chamadas.last, ('alimentos', 'a1', OperacaoSync.upsert));
    });
  });

  group('refeições', () {
    test('salvar em transação com a fila; excluir vira lápide', () async {
      await refeicoes.salvar(refeicao(), agora: t0);
      expect((await banco.select(banco.refeicoes).getSingle()).excluido, isFalse);
      fila.chamadas.clear();

      await refeicoes.excluir('r1', agora: t1);
      final linha = await banco.select(banco.refeicoes).getSingle();
      expect((linha.excluido, linha.versao), (true, 2));
      expect(await refeicoes.observar('r1').first, isNull);
      expect(fila.chamadas, [('refeicoes', 'r1', OperacaoSync.excluir)]);
    });

    test('do dia filtra horário; o outro pet não aparece', () async {
      await refeicoes.salvar(refeicao(), agora: t0);
      await refeicoes.salvar(refeicao(id: 'r2', quando: DateTime(2026, 9, 29, 8)), agora: t0);
      await refeicoes.salvar(refeicao(id: 'r3', petId: 'p2'), agora: t0);

      final doDia = await refeicoes.observarEntre('p1', hoje, amanha).first;
      expect(doDia.map((r) => r.id), ['r1']);
    });

  });

  group('R01 na gravação', () {
    test('SalvarRefeicao grava 108 kcal e, ao editar, usa a densidade copiada', () async {
      await alimentos.salvar(racao(), agora: t0);
      final caso = SalvarRefeicao(refeicoes);
      await caso(refeicao(energia: 0), agora: t0);
      expect((await refeicoes.observar('r1').first)!.energiaKcal, 108);

      await alimentos.salvar(racao().copyWith(densidadeKcalPor100g: 400), agora: t1);
      await caso(refeicao(quantidade: 40, densidade: 360, energia: 0), agora: t1);
      expect((await refeicoes.observar('r1').first)!.energiaKcal, 144);
    });
  });

  group('extras', () {
    test('grava, lista do dia e exclui com lápide', () async {
      await extras.salvar(petisco(), agora: t1);
      await extras.salvar(petisco(id: 'e2', petId: 'p2'), agora: t1);
      expect((await extras.observarEntre('p1', hoje, amanha).first).map((e) => e.id), ['e1']);

      await extras.excluir('e1', agora: t1);
      expect(await extras.observar('e1').first, isNull);
      expect(
        (await (banco.select(banco.extras)..where((e) => e.id.equals('e1'))).getSingle()).excluido,
        isTrue,
      );
    });
  });

  group('alimento do atalho', () {
    test('sem refeição: último cadastrado; com refeição: o da mais recente', () async {
      await alimentos.salvar(racao(id: 'a1'), agora: t0);
      await alimentos.salvar(
        Alimento(id: 'a2', petId: 'p1', nome: 'Úmida', densidadeKcalPor100g: 80, porcaoPadraoG: 50),
        agora: t1,
      );
      expect((await alimentos.observarAtalho('p1').first)?.id, 'a2');

      await refeicoes.salvar(refeicao(alimentoId: 'a1', quando: t1), agora: t1);
      expect((await alimentos.observarAtalho('p1').first)?.id, 'a1');
    });

    test('alimento arquivado da última refeição cai para o último cadastrado ativo', () async {
      await alimentos.salvar(racao(id: 'a1'), agora: t0);
      await alimentos.salvar(
        Alimento(id: 'a2', petId: 'p1', nome: 'Úmida', densidadeKcalPor100g: 80, porcaoPadraoG: 50),
        agora: t1,
      );
      await refeicoes.salvar(refeicao(alimentoId: 'a1'), agora: t0);
      await alimentos.arquivar('a1', agora: t1);
      expect((await alimentos.observarAtalho('p1').first)?.id, 'a2');
    });

    test('a lista atualiza sozinha (stream)', () async {
      final emitidos = <List<String>>[];
      final assinatura = alimentos.observarDoPet('p1').listen((l) => emitidos.add([for (final a in l) a.id]));
      await pumpEventQueue();
      await alimentos.salvar(racao(), agora: t0);
      await pumpEventQueue();
      await alimentos.arquivar('a1', agora: t1);
      await pumpEventQueue();
      await assinatura.cancel();
      expect(emitidos, [
        <String>[],
        ['a1'],
        <String>[],
      ]);
    });
  });

  test('com a cópia ligada, grava como pendente', () async {
    fila.estado = EstadoSync.pendente;
    await alimentos.salvar(racao(), agora: t0);
    await refeicoes.salvar(refeicao(), agora: t0);
    await extras.salvar(petisco(), agora: t1);
    expect((await banco.select(banco.alimentos).getSingle()).estadoSync, 'pendente');
    expect((await banco.select(banco.refeicoes).getSingle()).estadoSync, 'pendente');
    expect((await banco.select(banco.extras).getSingle()).estadoSync, 'pendente');
  });
}
