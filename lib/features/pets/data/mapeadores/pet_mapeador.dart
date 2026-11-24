import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/sync/fila_sync.dart';
import '../../../../core/sync/mapeador_sync.dart';
import '../../domain/descricao_pet.dart';
import '../../domain/entidades/pet.dart';

/// Pet ↔ documento `usuarios/{uid}/pets/{id}` (`dados-e-sync.md`; P1-3.1).
///
/// O id do pet é o id do documento. O caminho da foto (`fotoArquivo`) **não**
/// vai: ele só vale neste aparelho. A foto viaja à parte, no documento
/// `fotos/{petId}` (`FotoPetMapeador`, P-27), e na restauração o motor grava
/// o arquivo e preenche o caminho.
final class PetMapeador implements MapeadorSync<Pet> {
  PetMapeador({DateTime Function()? relogio}) : _relogio = relogio ?? DateTime.now;

  final DateTime Function() _relogio;

  @override
  String get colecao => ColecoesSync.pets;

  @override
  String get nomeRegistro => 'pet';

  @override
  Map<String, Object?> paraFirestore(Pet pet) => {
        'nome': pet.nome,
        'especie': pet.especie.name,
        'sexo': pet.sexo.name,
        'idadeMeses': pet.idadeMeses,
        'idadeInformadaEm': Timestamp.fromDate(pet.idadeInformadaEm),
        'castrado': pet.castrado,
        'nivelAtividade': pet.nivelAtividade.name,
      };

  /// Lança [FormatException] se faltar campo ou vier valor desconhecido: um
  /// documento inválido não pode virar pet no banco local.
  @override
  Pet deFirestore(String id, Map<String, Object?> documento) {
    T campo<T>(String nome) {
      final valor = documento[nome];
      if (valor is! T) throw FormatException('pets/$id: campo "$nome" ausente ou inválido');
      return valor;
    }

    E enumerado<E extends Enum>(List<E> valores, String nome) {
      final texto = campo<String>(nome);
      for (final v in valores) {
        if (v.name == texto) return v;
      }
      throw FormatException('pets/$id: valor desconhecido em "$nome"');
    }

    return Pet(
      id: id,
      nome: campo<String>('nome'),
      especie: enumerado(Especie.values, 'especie'),
      sexo: enumerado(Sexo.values, 'sexo'),
      idadeMeses: campo<num>('idadeMeses').toInt(),
      idadeInformadaEm: campo<Timestamp>('idadeInformadaEm').toDate(),
      castrado: campo<bool>('castrado'),
      nivelAtividade: enumerado(NivelAtividade.values, 'nivelAtividade'),
    );
  }

  /// `Luna • Gata • 6 anos • castrada • atividade moderada` (tela 17), com
  /// os textos de R11.
  @override
  String resumoConflito(Pet pet) =>
      '${pet.nome} • ${linhaEspecieIdade(pet, _relogio())} • ${castracaoTexto(pet)} • '
      'atividade ${nivelAtividadeTexto(pet.nivelAtividade)}';
}
