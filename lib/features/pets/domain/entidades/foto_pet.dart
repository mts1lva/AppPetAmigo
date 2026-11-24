/// Foto do pet como vai para a cópia remota (P-23, P-27): os bytes do JPEG
/// num documento próprio, `usuarios/{uid}/fotos/{petId}`. Dart puro.
library;

import 'dart:typed_data';

/// Maior foto que cabe num documento do Firestore (limite de 1 MiB por
/// documento, com folga para os campos de controle). A foto do app já sai
/// reduzida a 512 px (`seletor_foto_galeria.dart`), bem abaixo disso.
const tamanhoMaximoFotoBytes = 1000 * 1000;

final class FotoPet {
  FotoPet({required this.petId, required Uint8List imagem}) : imagem = Uint8List.fromList(imagem);

  final String petId;

  /// Bytes do JPEG.
  final Uint8List imagem;

  bool get cabeNumDocumento => imagem.length <= tamanhoMaximoFotoBytes;

  @override
  bool operator ==(Object other) {
    if (other is! FotoPet || other.petId != petId || other.imagem.length != imagem.length) return false;
    for (var i = 0; i < imagem.length; i++) {
      if (other.imagem[i] != imagem[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(petId, imagem.length, imagem.isEmpty ? 0 : imagem.first);

  /// Sem os bytes: logs não carregam a imagem.
  @override
  String toString() => 'FotoPet($petId, ${imagem.length} bytes)';
}
