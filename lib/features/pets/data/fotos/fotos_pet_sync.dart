import '../../domain/entidades/foto_pet.dart';
import '../../domain/entidades/pet.dart';
import '../../domain/repositorios/fotos_pet.dart';

/// A foto não cabe num documento do Firestore.
final class FotoGrandeDemais implements Exception {
  const FotoGrandeDemais(this.bytes);

  final int bytes;

  @override
  String toString() => 'FotoGrandeDemais($bytes bytes)';
}

/// Envio e restauração da foto do pet na cópia remota (P-23, P-27; P1-3.1),
/// **sem rede**: o motor do P5 chama estas funções e quem fala com o
/// Firestore é o `FirebaseRemoto`.
///
/// - Envio: depois do commit do lote com o pet, `fotoParaEnvio(pet)` →
///   `FotoPetMapeador.paraFirestore` → `set` em `fotos/{petId}`.
/// - Restauração (pull): `FotoPetMapeador.deFirestore` →
///   `guardarFotoRecebida(foto)` → o caminho vai para `pets.fotoArquivo`,
///   sem entrar na fila.
final class FotosPetSync {
  const FotosPetSync(this._armazenamento);

  final ArmazenamentoFotos _armazenamento;

  /// A foto do pet pronta para enviar, ou `null` se ele não tem foto ou o
  /// arquivo sumiu. Lança [FotoGrandeDemais] se ela não couber no documento.
  Future<FotoPet?> fotoParaEnvio(Pet pet) async {
    final caminho = pet.fotoArquivo;
    if (caminho == null) return null;
    final bytes = await _armazenamento.ler(caminho);
    if (bytes == null) return null;
    final foto = FotoPet(petId: pet.id, imagem: bytes);
    if (!foto.cabeNumDocumento) throw FotoGrandeDemais(bytes.length);
    return foto;
  }

  /// Grava a foto recebida da cópia na área privada e devolve o caminho
  /// para `pets.fotoArquivo`.
  Future<String> guardarFotoRecebida(FotoPet foto) =>
      _armazenamento.guardarBytes(foto.imagem, petId: foto.petId);
}
