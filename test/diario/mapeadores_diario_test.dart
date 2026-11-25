import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/diario/data/mapeadores/alimento_mapeador.dart';
import 'package:petamigo/features/diario/data/mapeadores/extra_mapeador.dart';
import 'package:petamigo/features/diario/data/mapeadores/refeicao_mapeador.dart';
import 'package:petamigo/features/diario/domain/entidades/alimento.dart';
import 'package:petamigo/features/diario/domain/entidades/extra.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';

Alimento racao() => const Alimento(
      id: 'a1',
      petId: 'p1',
      nome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      porcaoPadraoG: 30,
    );

Refeicao refeicao() => Refeicao(
      id: 'r1',
      petId: 'p1',
      alimentoId: 'a1',
      alimentoNome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      quantidadeG: 30,
      energiaKcal: 108,
      dataHora: DateTime(2026, 9, 30, 8),
    );

Extra extra({double? quantidadeG = 3}) => Extra(
      id: 'e1',
      petId: 'p1',
      descricao: 'Petisco',
      quantidadeG: quantidadeG,
      energiaKcal: 12,
      dataHora: DateTime(2026, 9, 30, 12),
    );

void main() {
  group('AlimentoMapeador', () {
    const mapeador = AlimentoMapeador();

    test('coleção, nome e ida e volta', () {
      expect(mapeador.colecao, ColecoesSync.alimentos);
      expect(mapeador.nomeRegistro, 'alimento');
      expect(mapeador.deFirestore('a1', mapeador.paraFirestore(racao())), racao());
      expect(mapeador.deFirestore('a2', mapeador.paraFirestore(racao().copyWith(arquivado: true))).arquivado, isTrue);
    });

    test('Firestore devolve números como int ou double', () {
      final doc = {...mapeador.paraFirestore(racao()), 'densidadeKcalPor100g': 360, 'porcaoPadraoG': 30.0};
      expect(mapeador.deFirestore('a1', doc).densidadeKcalPor100g, 360);
      expect(mapeador.deFirestore('a1', doc).porcaoPadraoG, 30);
    });

    test('documento inválido lança FormatException', () {
      final doc = mapeador.paraFirestore(racao());
      expect(() => mapeador.deFirestore('a1', {...doc}..remove('nome')), throwsFormatException);
    });

    test('resumo para a tela 17', () {
      expect(mapeador.resumoConflito(racao()), '30 g • 360 kcal/100 g');
    });
  });

  group('RefeicaoMapeador', () {
    const mapeador = RefeicaoMapeador();

    test('coleção, cópias no documento e ida e volta', () {
      expect(mapeador.colecao, ColecoesSync.refeicoes);
      expect(mapeador.nomeRegistro, 'refeição');
      final doc = mapeador.paraFirestore(refeicao());
      expect(doc['alimentoNome'], 'Ração habitual');
      expect(doc['densidadeKcalPor100g'], 360);
      expect(doc['dataHora'], Timestamp.fromDate(DateTime(2026, 9, 30, 8)));
      expect(mapeador.deFirestore('r1', doc), refeicao());
    });

    test('alimentoId nulo (alimento arquivado) na ida e volta', () {
      final r = refeicao().copyWith(alimentoId: () => null);
      expect(mapeador.deFirestore('r1', mapeador.paraFirestore(r)), r);
    });

    test('documento inválido lança FormatException', () {
      final doc = mapeador.paraFirestore(refeicao());
      expect(() => mapeador.deFirestore('r1', {...doc}..remove('alimentoNome')), throwsFormatException);
      expect(() => mapeador.deFirestore('r1', {...doc, 'dataHora': '2026-09-30'}), throwsFormatException);
    });

    test('resumo para a tela 17', () {
      expect(mapeador.resumoConflito(refeicao()), '30 g • 08:00');
    });
  });

  group('ExtraMapeador', () {
    const mapeador = ExtraMapeador();

    test('coleção e ida e volta com e sem quantidade', () {
      expect(mapeador.colecao, ColecoesSync.extras);
      expect(mapeador.nomeRegistro, 'petisco');
      expect(mapeador.deFirestore('e1', mapeador.paraFirestore(extra())), extra());
      expect(mapeador.deFirestore('e1', mapeador.paraFirestore(extra(quantidadeG: null))).quantidadeG, isNull);
    });

    test('resumo para a tela 17', () {
      expect(mapeador.resumoConflito(extra()), '3 g • 12:00');
      expect(mapeador.resumoConflito(extra(quantidadeG: null)), '12 kcal • 12:00');
    });
  });
}
