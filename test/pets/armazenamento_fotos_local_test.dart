import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/pets/data/fotos/armazenamento_fotos_local.dart';

void main() {
  late Directory base;
  late ArmazenamentoFotosLocal fotos;
  var micros = 1000;

  setUp(() async {
    base = await Directory.systemTemp.createTemp('petamigo_fotos_');
    fotos = ArmazenamentoFotosLocal(
      pastaBase: () async => base,
      relogio: () => DateTime.fromMicrosecondsSinceEpoch(micros++),
    );
  });
  tearDown(() => base.delete(recursive: true));

  Future<String> fotoTemporaria(String conteudo) async {
    final arquivo = File('${base.path}${Platform.pathSeparator}temp-${micros++}.jpg');
    await arquivo.writeAsString(conteudo);
    return arquivo.path;
  }

  test('guarda uma cópia em <documentos>/fotos com nome novo a cada vez', () async {
    final origem = await fotoTemporaria('imagem');
    final a = await fotos.guardar(origem, petId: 'p1');
    final b = await fotos.guardar(origem, petId: 'p1');

    expect(a, isNot(b));
    for (final caminho in [a, b]) {
      expect(File(caminho).parent.path, endsWith('${Platform.pathSeparator}fotos'));
      expect(File(caminho).uri.pathSegments.last, startsWith('p1-'));
      expect(await File(caminho).readAsString(), 'imagem');
    }
    expect(await File(origem).exists(), isTrue, reason: 'copia, não move o arquivo do seletor');
  });

  test('apagar remove o arquivo e ignora o que já não existe', () async {
    final caminho = await fotos.guardar(await fotoTemporaria('x'), petId: 'p1');
    await fotos.apagar(caminho);
    expect(await File(caminho).exists(), isFalse);
    await expectLater(fotos.apagar(caminho), completes);
  });
}
