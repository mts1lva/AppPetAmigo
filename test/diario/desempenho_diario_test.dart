// P2-4.3 — RNF06 do diário: salvar e abrir o resumo com 1.000 registros
// em menos de 1 s / 2 s. Medido aqui em memória (NativeDatabase), 20 vezes.
// A medição em `--profile` num aparelho real continua pendente (sem device
// neste ambiente).

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/diario/data/repositorios/refeicao_repositorio_drift.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';
import 'package:petamigo/features/diario/domain/resumo_do_dia.dart';

final class _FilaNula implements FilaSync {
  @override
  Future<EstadoSync> estadoInicial() async => EstadoSync.local;

  @override
  Future<void> enfileirar(String tabela, String registroId, OperacaoSync op) async {}
}

void main() {
  test(
    'RNF06: salvar e resumir com 1.000 refeições, 20 vezes, p95 < 1 s / 2 s',
    () async {
    final banco = BancoLocal(NativeDatabase.memory());
    addTearDown(banco.close);
    final agora = DateTime(2026, 9, 30, 8);
    await banco.into(banco.pets).insert(PetsCompanion.insert(
          id: 'p1',
          criadoEm: agora,
          atualizadoEm: agora,
          nome: 'Luna',
          especie: 'gato',
          sexo: 'femea',
          idadeMeses: 72,
          idadeInformadaEm: agora,
          castrado: true,
          nivelAtividade: 'moderada',
        ));

    final repo = RefeicaoRepositorioDrift(banco, _FilaNula());
    await banco.batch((b) {
      for (var i = 0; i < 1000; i++) {
        b.insert(
          banco.refeicoes,
          RefeicoesCompanion.insert(
            id: 'r$i',
            criadoEm: agora,
            atualizadoEm: agora,
            petId: 'p1',
            alimentoNome: 'Ração',
            densidadeKcalPor100g: 360,
            quantidadeG: 30,
            energiaKcal: 108,
            dataHora: agora.add(Duration(minutes: i % (24 * 60))),
          ),
        );
      }
    });

    final temposSalvar = <int>[];
    final temposResumo = <int>[];
    for (var n = 0; n < 20; n++) {
      final nova = Refeicao(
        id: 'nova-$n',
        petId: 'p1',
        alimentoNome: 'Ração',
        densidadeKcalPor100g: 360,
        quantidadeG: 30,
        energiaKcal: 108,
        dataHora: agora.add(Duration(seconds: n)),
      );
      final t0 = DateTime.now();
      await repo.salvar(nova, agora: agora);
      temposSalvar.add(DateTime.now().difference(t0).inMilliseconds);

      final t1 = DateTime.now();
      final lista = await repo.observarEntre('p1', DateTime(2026, 9, 30), DateTime(2026, 10, 1)).first;
      resumoDoDia(dia: DateTime(2026, 9, 30), refeicoes: lista, extras: const []);
      temposResumo.add(DateTime.now().difference(t1).inMilliseconds);
    }

    temposSalvar.sort();
    temposResumo.sort();
    final p95Salvar = temposSalvar[18];
    final p95Resumo = temposResumo[18];
    expect(p95Salvar, lessThan(1000), reason: 'salvar p95=${p95Salvar}ms tempos=$temposSalvar');
    expect(p95Resumo, lessThan(2000), reason: 'resumo p95=${p95Resumo}ms tempos=$temposResumo');
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}
