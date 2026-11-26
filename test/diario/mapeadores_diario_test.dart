import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/diario/data/mapeadores/alimento_mapeador.dart';
import 'package:petamigo/features/diario/data/mapeadores/extra_mapeador.dart';
import 'package:petamigo/features/diario/data/mapeadores/refeicao_mapeador.dart';
import 'package:petamigo/features/diario/domain/entidades/alimento.dart';
import 'package:petamigo/features/diario/domain/entidades/extra.dart';
import 'package:petamigo/features/diario/domain/entidades/petisco.dart';
import 'package:petamigo/features/diario/domain/entidades/refeicao.dart';

Alimento racao() => const Alimento(
      id: 'a1',
      petId: 'p1',
      nome: 'Ração habitual',
      densidadeKcalPor100g: 360,
      porcaoPadraoG: 30,
    );

const petisco = Petisco(
  id: 'a2',
  petId: 'p1',
  nome: 'Bifinho',
  kcalPorUnidade: 3.5,
  unidadesHabituais: 2,
  arquivado: true,
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

    test('coleção, nome e ida e volta da ração', () {
      expect(mapeador.colecao, ColecoesSync.alimentos);
      expect(mapeador.nomeRegistro, 'alimento');
      final doc = mapeador.paraFirestore(racao());
      expect(doc, {
        'petId': 'p1',
        'nome': 'Ração habitual',
        'tipo': 'racao',
        'densidadeKcalPor100g': 360.0,
        'porcaoPadraoG': 30.0,
        'arquivado': false,
      });
      expect(mapeador.deFirestore('a1', doc), racao());
    });

    test('ida e volta do petisco cadastrado', () {
      final doc = mapeador.paraFirestore(petisco);
      expect(doc, {
        'petId': 'p1',
        'nome': 'Bifinho',
        'tipo': 'petisco',
        'kcalPorUnidade': 3.5,
        'unidadesHabituais': 2,
        'arquivado': true,
      });
      expect(doc['unidadesHabituais'], isA<int>());
      expect(mapeador.deFirestore('a2', doc), petisco);
    });

    test('ração antiga sem tipo, com densidade inteira e porção decimal', () {
      final doc = {
        'petId': 'p1',
        'nome': 'Ração habitual',
        'densidadeKcalPor100g': 360,
        'porcaoPadraoG': 30.0,
        'arquivado': true,
      };
      expect(mapeador.deFirestore('a1', doc), racao().copyWith(arquivado: true));
    });

    test('documento inválido lança FormatException', () {
      final doc = mapeador.paraFirestore(racao());
      expect(() => mapeador.deFirestore('a1', {...doc}..remove('nome')), throwsFormatException);
      expect(() => mapeador.deFirestore('a1', {...doc, 'tipo': 'outro'}), throwsFormatException);
      expect(() => mapeador.deFirestore('a1', {...doc, 'tipo': null}), throwsFormatException);
      final docPetisco = mapeador.paraFirestore(petisco);
      expect(() => mapeador.deFirestore('a2', {...docPetisco}..remove('kcalPorUnidade')), throwsFormatException);
      expect(() => mapeador.deFirestore('a2', {...docPetisco, 'kcalPorUnidade': double.nan}), throwsFormatException);
      expect(() => mapeador.deFirestore('a2', {...docPetisco, 'unidadesHabituais': 2.5}), throwsFormatException);
      expect(() => mapeador.deFirestore('a2', {...docPetisco, 'unidadesHabituais': 0}), throwsFormatException);
    });

    test('resumo para a tela 17', () {
      expect(mapeador.resumoConflito(racao()), '30 g • 360 kcal/100 g');
      expect(mapeador.resumoConflito(petisco), '2 un. • 4 kcal/un.');
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

    test('coleção e ida e volta do extra digitado com e sem quantidade', () {
      expect(mapeador.colecao, ColecoesSync.extras);
      expect(mapeador.nomeRegistro, 'petisco');
      for (final digitado in [extra(), extra(quantidadeG: null)]) {
        final doc = mapeador.paraFirestore(digitado);
        expect(doc, containsPair('alimentoId', null));
        expect(doc, containsPair('unidades', null));
        expect(mapeador.deFirestore('e1', doc), digitado);
      }
    });

    test('ida e volta do extra de petisco cadastrado preserva as cópias', () {
      final cadastrado = extra(quantidadeG: null).copyWith(
        alimentoId: () => 'a2',
        unidades: () => 2,
        descricao: 'Bifinho antigo',
        energiaKcal: 6,
      );
      final doc = mapeador.paraFirestore(cadastrado);
      expect(doc, {
        'petId': 'p1',
        'alimentoId': 'a2',
        'descricao': 'Bifinho antigo',
        'quantidadeG': null,
        'unidades': 2,
        'energiaKcal': 6.0,
        'dataHora': Timestamp.fromDate(cadastrado.dataHora),
      });
      expect(doc['unidades'], isA<int>());
      expect(mapeador.deFirestore('e1', doc), cadastrado);
    });

    test('extra antigo sem alimentoId e unidades', () {
      final doc = mapeador.paraFirestore(extra())
        ..remove('alimentoId')
        ..remove('unidades');
      expect(mapeador.deFirestore('e1', doc), extra());
    });

    test('alimentoId ou unidades inválidos lançam FormatException', () {
      final doc = mapeador.paraFirestore(extra());
      expect(() => mapeador.deFirestore('e1', {...doc, 'alimentoId': 2}), throwsFormatException);
      expect(() => mapeador.deFirestore('e1', {...doc, 'unidades': 2.5}), throwsFormatException);
      expect(() => mapeador.deFirestore('e1', {...doc, 'unidades': 0}), throwsFormatException);
    });

    test('resumo para a tela 17', () {
      expect(mapeador.resumoConflito(extra()), '3 g • 12:00');
      expect(mapeador.resumoConflito(extra(quantidadeG: null)), '12 kcal • 12:00');
      expect(mapeador.resumoConflito(extra(quantidadeG: null).copyWith(unidades: () => 2)), '2 un. • 12:00');
    });
  });
}
