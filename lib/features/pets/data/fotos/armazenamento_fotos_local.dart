import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../domain/repositorios/fotos_pet.dart';

/// Guarda as fotos em `<documentos do app>/fotos/`, a área privada do app,
/// que outros apps não leem (RNF04).
final class ArmazenamentoFotosLocal implements ArmazenamentoFotos {
  ArmazenamentoFotosLocal({Future<Directory> Function()? pastaBase, DateTime Function()? relogio})
      : _pastaBase = pastaBase ?? getApplicationDocumentsDirectory,
        _relogio = relogio ?? DateTime.now;

  final Future<Directory> Function() _pastaBase;
  final DateTime Function() _relogio;

  Future<Directory> _pastaFotos() async {
    final pasta = Directory('${(await _pastaBase()).path}${Platform.pathSeparator}fotos');
    if (!await pasta.exists()) await pasta.create(recursive: true);
    return pasta;
  }

  @override
  Future<String> guardar(String origem, {required String petId}) async {
    final pasta = await _pastaFotos();
    final destino = '${pasta.path}${Platform.pathSeparator}$petId-${_relogio().microsecondsSinceEpoch}.jpg';
    await File(origem).copy(destino);
    return destino;
  }

  @override
  Future<void> apagar(String caminho) async {
    final arquivo = File(caminho);
    if (await arquivo.exists()) await arquivo.delete();
  }
}
