import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/atividades/data/repositorios/atividade_repositorio_drift.dart';
import 'package:petamigo/features/atividades/domain/entidades/atividade.dart';
import 'package:petamigo/features/lembretes/data/repositorios/lembrete_repositorio_drift.dart';
import 'package:petamigo/features/lembretes/domain/entidades/lembrete.dart';
import 'package:petamigo/features/lembretes/domain/repositorios/lembrete_repositorio.dart';

final class FilaDeTeste implements FilaSync {
  bool falhar = false;
  final chamadas = <(String, String, OperacaoSync)>[];
  @override
  Future<EstadoSync> estadoInicial() async => EstadoSync.pendente;
  @override
  Future<void> enfileirar(String tabela, String id, OperacaoSync op) async {
    if (falhar) throw StateError('Falha simulada na fila.');
    chamadas.add((tabela, id, op));
  }
}

Future<void> inserirPet(BancoLocal banco, String id, DateTime agora) => banco
    .into(banco.pets)
    .insert(
      PetsCompanion.insert(
        id: id,
        criadoEm: agora,
        atualizadoEm: agora,
        nome: id,
        especie: 'gato',
        sexo: 'femea',
        idadeMeses: 72,
        idadeInformadaEm: agora,
        castrado: true,
        nivelAtividade: 'moderada',
      ),
    )
    .then((_) {});

void main() {
  final agora = DateTime(2026, 9, 30, 20);
  late BancoLocal banco;
  late FilaDeTeste fila;
  late AtividadeRepositorioDrift atividades;
  late LembreteRepositorioDrift lembretes;
  setUp(() async {
    banco = BancoLocal(NativeDatabase.memory());
    fila = FilaDeTeste();
    atividades = AtividadeRepositorioDrift(banco, fila);
    var sequencia = 0;
    lembretes = LembreteRepositorioDrift(
      banco,
      fila,
      novoId: () => 'l${++sequencia}',
    );
    await inserirPet(banco, 'p1', agora);
    await inserirPet(banco, 'p2', agora);
  });
  tearDown(() => banco.close());

  Atividade atividade(String id, {String petId = 'p1', int minutos = 10}) =>
      Atividade(
        id: id,
        petId: petId,
        tipo: TipoAtividade.brincadeira,
        duracaoMin: minutos,
        dataHora: agora,
      );

  test(
    'atividades: versão, stream por pet, lápide e fila na mesma transação',
    () async {
      await atividades.salvar(atividade('a1'), agora: agora);
      await atividades.salvar(atividade('a2', petId: 'p2'), agora: agora);
      await atividades.salvar(atividade('a1', minutos: 20), agora: agora);
      final lista = await atividades
          .observar(
            'p1',
            inicio: DateTime(2026, 9, 30),
            fim: DateTime(2026, 10, 1),
          )
          .first;
      expect(lista.single.duracaoMin, 20);
      final linha = await (banco.select(
        banco.atividades,
      )..where((a) => a.id.equals('a1'))).getSingle();
      expect((linha.versao, linha.estadoSync), (2, 'pendente'));
      await atividades.excluir('p2', 'a1', agora: agora);
      expect(
        (await banco.select(banco.atividades).get()).where((a) => a.excluido),
        isEmpty,
      );
      await atividades.excluir('p1', 'a1', agora: agora);
      final apagada = await (banco.select(
        banco.atividades,
      )..where((a) => a.id.equals('a1'))).getSingle();
      expect((apagada.excluido, apagada.versao), (true, 3));
      expect(fila.chamadas.last, ('atividades', 'a1', OperacaoSync.excluir));
      await expectLater(
        atividades.salvar(atividade('a1'), agora: agora),
        throwsStateError,
      );
    },
  );

  test('falha na fila desfaz criação, edição e exclusão', () async {
    fila.falhar = true;
    await expectLater(
      atividades.salvar(atividade('a1'), agora: agora),
      throwsStateError,
    );
    expect(await banco.select(banco.atividades).get(), isEmpty);
    fila.falhar = false;
    await atividades.salvar(atividade('a1'), agora: agora);
    fila.falhar = true;
    await expectLater(
      atividades.salvar(atividade('a1', minutos: 30), agora: agora),
      throwsStateError,
    );
    await expectLater(
      atividades.excluir('p1', 'a1', agora: agora),
      throwsStateError,
    );
    final linha = await banco.select(banco.atividades).getSingle();
    expect((linha.duracaoMin, linha.versao, linha.excluido), (10, 1, false));
  });

  test(
    'lembretes: IDs globais estáveis, repetição bloqueada e sugeridos atômicos',
    () async {
      final p1 = await lembretes.criarSugeridos('p1', agora: agora);
      final p2 = await lembretes.criarSugeridos('p2', agora: agora);
      expect([...p1, ...p2].map((l) => l.notificacaoId).toSet(), hasLength(6));
      final primeiro = p1.first;
      final editado = await lembretes.salvar(
        Lembrete(
          id: primeiro.id,
          petId: 'p1',
          horaMinutos: 481,
          tipo: TipoLembrete.refeicao,
          ativo: false,
          notificacaoId: 999,
        ),
        agora: agora,
      );
      expect(editado.notificacaoId, primeiro.notificacaoId);
      await expectLater(
        lembretes.salvar(
          Lembrete(
            id: 'repetido',
            petId: 'p1',
            horaMinutos: 481,
            tipo: TipoLembrete.refeicao,
            ativo: true,
            notificacaoId: 999,
          ),
          agora: agora,
        ),
        throwsA(isA<HorarioRepetido>()),
      );
      await inserirPet(banco, 'p3', agora);
      fila.falhar = true;
      await expectLater(
        lembretes.criarSugeridos('p3', agora: agora),
        throwsStateError,
      );
      expect(await lembretes.listar('p3'), isEmpty);
      fila.falhar = false;
      await lembretes.excluir('p1', primeiro.id, agora: agora);
      expect(await lembretes.listar('p1'), hasLength(2));
      expect(
        await lembretes.listar('p1', incluirExcluidos: true),
        hasLength(3),
      );
    },
  );

  test('formulário antigo não grava depois da exclusão do pet', () async {
    await (banco.update(banco.pets)..where((p) => p.id.equals('p1'))).write(
      const PetsCompanion(excluido: Value(true)),
    );
    await expectLater(
      atividades.salvar(atividade('a1'), agora: agora),
      throwsStateError,
    );
    await expectLater(
      lembretes.criarSugeridos('p1', agora: agora),
      throwsStateError,
    );
  });
}
