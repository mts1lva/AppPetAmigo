import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/core/sync/fila_sync.dart';
import 'package:petamigo/features/pets/data/fotos/armazenamento_fotos_local.dart';
import 'package:petamigo/features/pets/data/fotos/fotos_pet_sync.dart';
import 'package:petamigo/features/pets/data/mapeadores/foto_pet_mapeador.dart';
import 'package:petamigo/features/pets/data/mapeadores/pet_mapeador.dart';
import 'package:petamigo/features/pets/domain/entidades/foto_pet.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

import '../apoio/pets_falsos.dart';

/// Luna do protótipo, com a idade informada numa data fixa.
Pet lunaFixa() => luna().copyWith(idadeInformadaEm: DateTime(2026, 9, 30));

/// Thor: cão macho filhote, não castrado, atividade alta (todos os outros
/// valores dos enums).
Pet thor() => Pet(
      id: 'p2',
      nome: 'Thor',
      especie: Especie.cao,
      sexo: Sexo.macho,
      idadeMeses: 6,
      idadeInformadaEm: DateTime(2026, 8, 15),
      castrado: false,
      nivelAtividade: NivelAtividade.alta,
    );

void main() {
  group('PetMapeador', () {
    final mapeador = PetMapeador(relogio: () => DateTime(2026, 9, 30));

    test('coleção e nome do registro', () {
      expect(mapeador.colecao, ColecoesSync.pets);
      expect(mapeador.nomeRegistro, 'pet');
    });

    test('ida e volta preserva o pet (contrato do mapeador)', () {
      for (final pet in [lunaFixa(), thor()]) {
        expect(mapeador.deFirestore(pet.id, mapeador.paraFirestore(pet)), pet, reason: pet.id);
      }
      final baixa = lunaFixa().copyWith(nivelAtividade: NivelAtividade.baixa);
      expect(mapeador.deFirestore('p1', mapeador.paraFirestore(baixa)), baixa);
    });

    test('documento: enums pelo nome, data como Timestamp, sem o caminho da foto', () {
      final doc = mapeador.paraFirestore(lunaFixa().copyWith(fotoArquivo: () => '/privado/fotos/p1.jpg'));
      expect(doc, {
        'nome': 'Luna',
        'especie': 'gato',
        'sexo': 'femea',
        'idadeMeses': 72,
        'idadeInformadaEm': Timestamp.fromDate(DateTime(2026, 9, 30)),
        'castrado': true,
        'nivelAtividade': 'moderada',
      });
      expect(mapeador.deFirestore('p1', doc).fotoArquivo, isNull, reason: 'o caminho só vale neste aparelho');
    });

    test('documento inválido lança FormatException', () {
      final doc = mapeador.paraFirestore(lunaFixa());
      expect(() => mapeador.deFirestore('p1', {...doc}..remove('nome')), throwsFormatException);
      expect(() => mapeador.deFirestore('p1', {...doc, 'especie': 'peixe'}), throwsFormatException);
      expect(() => mapeador.deFirestore('p1', {...doc, 'idadeInformadaEm': '2026-09-30'}), throwsFormatException);
    });

    test('Firestore devolve números inteiros como int ou double: os dois servem', () {
      final doc = {...mapeador.paraFirestore(lunaFixa()), 'idadeMeses': 72.0};
      expect(mapeador.deFirestore('p1', doc).idadeMeses, 72);
    });

    test('resumo para a tela 17 com os textos de R11', () {
      expect(mapeador.resumoConflito(lunaFixa()), 'Luna • Gata • 6 anos • castrada • atividade moderada');
      expect(mapeador.resumoConflito(thor()), 'Thor • Cão filhote • 7 meses • não castrado • atividade alta');
    });
  });

  group('FotoPetMapeador', () {
    const mapeador = FotoPetMapeador();
    final foto = FotoPet(petId: 'p1', imagem: Uint8List.fromList(List.generate(2048, (i) => i % 256)));

    test('coleção fotos, imagem como Blob, ida e volta', () {
      expect(mapeador.colecao, ColecoesSync.fotos);
      expect(mapeador.nomeRegistro, 'foto');
      final doc = mapeador.paraFirestore(foto);
      expect(doc['petId'], 'p1');
      expect(doc['imagem'], isA<Blob>());
      expect(mapeador.deFirestore('p1', doc), foto);
    });

    test('documento inválido lança FormatException', () {
      expect(() => mapeador.deFirestore('p1', {'petId': 'p1'}), throwsFormatException);
      expect(() => mapeador.deFirestore('p1', {'imagem': Blob(Uint8List(1))}), throwsFormatException);
    });

    test('resumo para a tela 17', () {
      expect(mapeador.resumoConflito(foto), 'foto de 2 KB');
    });
  });

  group('FotosPetSync (envio e restauração, sem rede)', () {
    late Directory pasta;

    setUp(() async => pasta = await Directory.systemTemp.createTemp('fotos_pet_sync'));
    tearDown(() async => pasta.delete(recursive: true));

    test('ida e volta: foto do aparelho → documento → outro aparelho', () async {
      final armazenamento = ArmazenamentoFotosLocal(pastaBase: () async => pasta);
      final sync = FotosPetSync(armazenamento);
      final original = File('docs/design/assets/foto-luna.jpg');
      final caminho = await armazenamento.guardar(original.path, petId: 'p1');

      final paraEnviar = await sync.fotoParaEnvio(lunaFixa().copyWith(fotoArquivo: () => caminho));
      const mapeador = FotoPetMapeador();
      final recebida = mapeador.deFirestore('p1', mapeador.paraFirestore(paraEnviar!));
      final restaurada = await sync.guardarFotoRecebida(recebida);

      expect(restaurada, isNot(caminho), reason: 'sempre um arquivo novo');
      expect(await File(restaurada).readAsBytes(), await original.readAsBytes());
    });

    test('sem foto ou com o arquivo apagado: nada a enviar', () async {
      final sync = FotosPetSync(FotosFalsas());
      expect(await sync.fotoParaEnvio(lunaFixa()), isNull);
      expect(await sync.fotoParaEnvio(lunaFixa().copyWith(fotoArquivo: () => '/sumiu.jpg')), isNull);
    });

    test('foto maior que o documento do Firestore: FotoGrandeDemais', () async {
      final fotos = FotosFalsas()..arquivos['/grande.jpg'] = Uint8List(tamanhoMaximoFotoBytes + 1);
      final sync = FotosPetSync(fotos);
      expect(
        () => sync.fotoParaEnvio(lunaFixa().copyWith(fotoArquivo: () => '/grande.jpg')),
        throwsA(isA<FotoGrandeDemais>()),
      );
    });
  });
}
