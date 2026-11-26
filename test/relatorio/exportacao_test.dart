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
}
