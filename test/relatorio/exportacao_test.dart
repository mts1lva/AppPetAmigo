import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/banco/database.dart';
import 'package:petamigo/features/relatorio/data/gerador_exportacao.dart';
import 'package:petamigo/features/relatorio/data/repositorios/exportacao_repositorio_drift.dart';

import '../atividades/repositorios_p3_test.dart' show inserirPet;

void main() {
  test('R13: JSON formato 2, todos os pets, sem fotos, lápides ou controle de sync', () async {
    final banco = BancoLocal(NativeDatabase.memory());
    final pasta = await Directory.systemTemp.createTemp('petamigo-teste-');
    addTearDown(banco.close);
    addTearDown(() => pasta.delete(recursive: true));
    final agora = DateTime(2026, 9, 30, 18);
    await inserirPet(banco, 'p1', agora);
    await inserirPet(banco, 'p2', agora);
    await inserirPet(banco, 'excluido', agora);
    await (banco.update(banco.pets)..where((p) => p.id.equals('p1'))).write(
      const PetsCompanion(fotoArquivo: Value('/privado/foto.jpg')),
    );
    await (banco.update(banco.pets)..where((p) => p.id.equals('excluido')))
        .write(const PetsCompanion(excluido: Value(true)));
    await banco
        .into(banco.atividades)
        .insert(
          AtividadesCompanion.insert(
            id: 'a1',
            petId: 'p2',
            criadoEm: agora,
            atualizadoEm: agora,
            tipo: 'brincadeira',
            duracaoMin: 10,
            dataHora: agora,
          ),
        );
    final gerador = GeradorExportacao(
      ExportacaoRepositorioDrift(banco),
      temporarios: () async => pasta,
    );
    final arquivo = await gerador.gerarJson();
    final texto = await arquivo.readAsString();
    final dados = jsonDecode(texto) as Map<String, dynamic>;
    expect(dados['formato'], 2);
    expect((dados['pets'] as List).map((p) => p['id']), ['p1', 'p2']);
    expect(
      dados.keys,
      containsAll([
        'alimentos',
        'refeicoes',
        'extras',
        'atividades',
        'lembretes',
        'pesagens',
        'referencias',
      ]),
    );
    expect(dados['atividades'].single['petId'], 'p2');
    expect(DateTime.parse(dados['atividades'].single['dataHora']), agora);
    for (final proibido in [
      'fotoArquivo',
      '/privado',
      'estadoSync',
      'versaoRemota',
      'criadoEm',
      'atualizadoEm',
    ]) {
      expect(texto, isNot(contains(proibido)));
    }
    expect(await banco.select(banco.itensFilaSync).get(), isEmpty);
  });

  test(
    'R13: exporta ração, petisco cadastrado e os dois tipos de extra',
    () async {
      final banco = BancoLocal(NativeDatabase.memory());
      final pasta = await Directory.systemTemp.createTemp('petamigo-teste-');
      addTearDown(banco.close);
      addTearDown(() => pasta.delete(recursive: true));
      final agora = DateTime(2026, 9, 30, 18);
      await inserirPet(banco, 'p1', agora);
      await inserirPet(banco, 'p2', agora);
      await banco.batch((lote) {
        lote.insertAll(banco.alimentos, [
          AlimentosCompanion.insert(
            id: 'a1',
            petId: 'p1',
            criadoEm: agora,
            atualizadoEm: agora,
            nome: 'Ração habitual',
            densidadeKcalPor100g: const Value(360),
            porcaoPadraoG: const Value(30),
          ),
          AlimentosCompanion.insert(
            id: 'a2',
            petId: 'p2',
            criadoEm: agora,
            atualizadoEm: agora,
            nome: 'Bifinho',
            tipo: const Value('petisco'),
            kcalPorUnidade: const Value(3.5),
            unidadesHabituais: const Value(2),
            arquivado: const Value(true),
          ),
        ]);
        lote.insertAll(banco.extras, [
          ExtrasCompanion.insert(
            id: 'e1',
            petId: 'p2',
            criadoEm: agora,
            atualizadoEm: agora,
            alimentoId: const Value('a2'),
            descricao: 'Bifinho antigo',
            unidades: const Value(2),
            energiaKcal: 6,
            dataHora: agora,
          ),
          ExtrasCompanion.insert(
            id: 'e2',
            petId: 'p1',
            criadoEm: agora,
            atualizadoEm: agora,
            descricao: 'Petisco digitado',
            quantidadeG: const Value(3),
            energiaKcal: 12,
            dataHora: agora,
          ),
        ]);
      });

      final arquivo = await GeradorExportacao(
        ExportacaoRepositorioDrift(banco),
        temporarios: () async => pasta,
      ).gerarJson();
      final dados =
          jsonDecode(await arquivo.readAsString()) as Map<String, dynamic>;
      expect(dados['formato'], 2);
      expect(
        dados['alimentos'],
        unorderedEquals([
          {
            'id': 'a1',
            'petId': 'p1',
            'nome': 'Ração habitual',
            'tipo': 'racao',
            'densidadeKcalPor100g': 360.0,
            'porcaoPadraoG': 30.0,
            'kcalPorUnidade': null,
            'unidadesHabituais': null,
            'arquivado': false,
          },
          {
            'id': 'a2',
            'petId': 'p2',
            'nome': 'Bifinho',
            'tipo': 'petisco',
            'densidadeKcalPor100g': null,
            'porcaoPadraoG': null,
            'kcalPorUnidade': 3.5,
            'unidadesHabituais': 2,
            'arquivado': true,
          },
        ]),
      );
      expect(
        dados['extras'],
        unorderedEquals([
          {
            'id': 'e1',
            'petId': 'p2',
            'descricao': 'Bifinho antigo',
            'alimentoId': 'a2',
            'quantidadeG': null,
            'unidades': 2,
            'energiaKcal': 6.0,
            'dataHora': agora.toIso8601String(),
          },
          {
            'id': 'e2',
            'petId': 'p1',
            'descricao': 'Petisco digitado',
            'alimentoId': null,
            'quantidadeG': 3.0,
            'unidades': null,
            'energiaKcal': 12.0,
            'dataHora': agora.toIso8601String(),
          },
        ]),
      );
    },
  );
}
