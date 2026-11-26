import 'dart:io';

import 'package:share_plus/share_plus.dart';

/// O arquivo e a pasta privada criados pelo gerador são removidos mesmo se
/// o tutor cancelar o compartilhamento. A chamada só ocorre por ação explícita.
Future<void> compartilharArquivo(
  File arquivo, {
  required String tipoMime,
}) async {
  try {
    await SharePlus.instance.share(
      ShareParams(files: [XFile(arquivo.path, mimeType: tipoMime)]),
    );
  } finally {
    if (await arquivo.exists()) await arquivo.delete();
    final pasta = arquivo.parent;
    if (pasta.path
            .split(Platform.pathSeparator)
            .last
            .startsWith('petamigo-exportacao-') &&
        await pasta.exists() &&
        await pasta.list().isEmpty) {
      await pasta.delete();
    }
  }
}
