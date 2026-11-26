import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../domain/repositorios/exportacao_repositorio.dart';

/// R13: apenas gera o arquivo quando solicitado. Nenhuma comunicação remota.
final class GeradorExportacao {
  GeradorExportacao(
    this._repositorio, {
    Future<Directory> Function()? temporarios,
  }) : _temporarios = temporarios ?? getTemporaryDirectory;
  final ExportacaoRepositorio _repositorio;
  final Future<Directory> Function() _temporarios;

  Future<File> gerarJson() async {
    final dados = await _repositorio.carregar();
    final pasta = await (await _temporarios()).createTemp(
      'petamigo-exportacao-',
    );
    final arquivo = File('${pasta.path}/petamigo-dados.json');
    try {
      return await arquivo.writeAsString(
        const JsonEncoder.withIndent('  ').convert(dados),
        flush: true,
      );
    } catch (_) {
      await pasta.delete(recursive: true);
      rethrow;
    }
  }
}
