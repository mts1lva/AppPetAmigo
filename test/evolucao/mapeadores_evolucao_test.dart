// P4-3.1 — PesagemMapeador e ReferenciaMapeador: ida e volta.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:petamigo/core/formato/datas.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/evolucao/data/mapeadores/pesagem_mapeador.dart';
import 'package:petamigo/features/evolucao/data/mapeadores/referencia_mapeador.dart';
import 'package:petamigo/features/evolucao/domain/entidades/pesagem.dart';
import 'package:petamigo/features/evolucao/domain/entidades/referencia.dart';

void main() {
  setUpAll(() => initializeDateFormatting(localeApp));

  group('PesagemMapeador', () {
    const mapeador = PesagemMapeador();
    final normal = Pesagem(id: 'w1', petId: 'p1', pesoKg: 5.4, dataHora: DateTime(2026, 9, 30, 8));
    final conferida = Pesagem(id: 'w2', petId: 'p1', pesoKg: 54, dataHora: DateTime(2026, 9, 30, 9), conferida: true);

    test('coleção e nome do registro', () {
      expect(mapeador.colecao, ColecoesSync.pesagens);
      expect(mapeador.nomeRegistro, 'pesagem');
    });

    test('ida e volta, com e sem conferida', () {
      for (final p in [normal, conferida]) {
        expect(mapeador.deFirestore(p.id, mapeador.paraFirestore(p)), p, reason: p.id);
      }
    });

    test('documento: data como Timestamp e conferida: true', () {
      expect(mapeador.paraFirestore(conferida), {
        'petId': 'p1',
        'pesoKg': 54.0,
        'dataHora': Timestamp.fromDate(DateTime(2026, 9, 30, 9)),
        'conferida': true,
      });
    });

    test('peso inteiro vindo como int serve; conferida ausente vale false', () {
      final doc = {...mapeador.paraFirestore(normal), 'pesoKg': 5}..remove('conferida');
      final p = mapeador.deFirestore('w1', doc);
      expect((p.pesoKg, p.conferida), (5.0, false));
    });

    test('documento inválido lança FormatException', () {
      final doc = mapeador.paraFirestore(normal);
      expect(() => mapeador.deFirestore('w1', {...doc}..remove('petId')), throwsFormatException);
      expect(() => mapeador.deFirestore('w1', {...doc, 'pesoKg': -1}), throwsFormatException);
      expect(() => mapeador.deFirestore('w1', {...doc, 'dataHora': '2026-09-30'}), throwsFormatException);
      expect(() => mapeador.deFirestore('w1', {...doc, 'conferida': 'sim'}), throwsFormatException);
    });

    test('resumo para a tela 17', () {
      expect(mapeador.resumoConflito(normal), '5,4 kg • 30 set. 2026');
    });
  });

  group('ReferenciaMapeador', () {
    const mapeador = ReferenciaMapeador();
    final ecc = Referencia(
      id: 'r1',
      petId: 'p1',
      ecc: 7,
      origem: OrigemReferencia.veterinario,
      data: DateTime(2026, 9, 30),
    );
    final objetivo = Referencia(
      id: 'r2',
      petId: 'p1',
      objetivoKg: 4.8,
      origem: OrigemReferencia.outroProfissional,
      data: DateTime(2026, 9, 1),
    );
    final ambos = Referencia(
      id: 'r3',
      petId: 'p2',
      ecc: 3,
      objetivoKg: 6,
      origem: OrigemReferencia.tutor,
      data: DateTime(2026, 8, 15),
    );

    test('coleção e nome do registro', () {
      expect(mapeador.colecao, ColecoesSync.referencias);
      expect(mapeador.nomeRegistro, 'referência');
    });

    test('ida e volta com cada origem e com ECC e objetivo nulos', () {
      for (final r in [ecc, objetivo, ambos]) {
        expect(mapeador.deFirestore(r.id, mapeador.paraFirestore(r)), r, reason: r.id);
      }
    });

    test('documento: origem pelo nome e data como Timestamp', () {
      expect(mapeador.paraFirestore(ecc), {
        'petId': 'p1',
        'ecc': 7,
        'objetivoKg': null,
        'origem': 'veterinario',
        'data': Timestamp.fromDate(DateTime(2026, 9, 30)),
      });
    });

    test('ECC vindo como 7.0 serve', () {
      final doc = {...mapeador.paraFirestore(ecc), 'ecc': 7.0};
      expect(mapeador.deFirestore('r1', doc).ecc, 7);
    });

    test('documento inválido lança FormatException', () {
      final doc = mapeador.paraFirestore(ecc);
      expect(() => mapeador.deFirestore('r1', {...doc, 'ecc': 10}), throwsFormatException);
      expect(() => mapeador.deFirestore('r1', {...doc, 'ecc': 6.5}), throwsFormatException);
      expect(() => mapeador.deFirestore('r1', {...doc, 'objetivoKg': 0}), throwsFormatException);
      expect(() => mapeador.deFirestore('r1', {...doc, 'origem': 'vizinho'}), throwsFormatException);
      expect(() => mapeador.deFirestore('r1', {...doc}..remove('data')), throwsFormatException);
    });

    test('resumo para a tela 17', () {
      expect(mapeador.resumoConflito(ecc), 'ECC 7 de 9 • Objetivo não informado');
      expect(mapeador.resumoConflito(ambos), 'ECC 3 de 9 • Objetivo 6,0 kg');
    });
  });
}
