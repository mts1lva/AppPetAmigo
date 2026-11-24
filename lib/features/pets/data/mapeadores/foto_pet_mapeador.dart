import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/formato/numeros.dart';
import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/entidades/foto_pet.dart';

/// Foto ↔ documento `usuarios/{uid}/fotos/{petId}` (P-23, P-27; P1-3.1):
/// `petId` e a imagem como `Bytes` (`Blob`). O id do documento é o do pet.
///
/// Quem grava e lê o documento é o motor do P5, pelo `FirebaseRemoto`; este
/// mapeador só converte.
final class FotoPetMapeador implements MapeadorSync<FotoPet> {
  const FotoPetMapeador();

  @override
  String get colecao => ColecoesSync.fotos;

  @override
  String get nomeRegistro => 'foto';

  @override
  Map<String, Object?> paraFirestore(FotoPet foto) => {
        'petId': foto.petId,
        'imagem': Blob(foto.imagem),
      };

  @override
  FotoPet deFirestore(String id, Map<String, Object?> documento) {
    final petId = documento['petId'];
    final imagem = documento['imagem'];
    if (petId is! String || imagem is! Blob) {
      throw FormatException('fotos/$id: "petId" ou "imagem" ausente ou inválido');
    }
    return FotoPet(petId: petId, imagem: imagem.bytes);
  }

  /// `foto de 48 KB` (tela 17).
  @override
  String resumoConflito(FotoPet foto) => 'foto de ${formatarNumero(foto.imagem.length / 1024, casas: 0)} KB';
}
