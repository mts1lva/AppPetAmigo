import '../entidades/dados_pet.dart';
import '../entidades/pet.dart';
import '../repositorios/fotos_pet.dart';
import '../repositorios/pet_repositorio.dart';

/// Edita um pet. O peso inicial é editável (U2-06): alterá-lo altera a
/// primeira pesagem, e meta, gráfico e projeção se recalculam pelos streams.
/// Trocar a foto apaga o arquivo antigo da área privada (critério do P1).
///
/// A conferência de pesagem suspeita (R06, tela 25) no peso inicial é ligada
/// pelo P4 na P4-2.1.
final class EditarPet {
  const EditarPet(this._repositorio, this._fotos, {this.reagendarLembretes});
  final Future<void> Function(String petId, String nomePet)? reagendarLembretes;

  final PetRepositorio _repositorio;
  final ArmazenamentoFotos _fotos;

  /// [pesoInicialAtualKg]: peso inicial salvo hoje; só regrava a pesagem se
  /// o valor mudou. [fotoEscolhida]: caminho temporário de uma foto nova.
  Future<void> call(
    Pet atual,
    DadosPet dados, {
    required double? pesoInicialAtualKg,
    required DateTime agora,
    String? fotoEscolhida,
  }) async {
    final erros = validarDadosPet(dados);
    if (erros.isNotEmpty) throw ArgumentError('Dados do pet inválidos: ${erros.keys.map((c) => c.name)}');

    final fotoNova = fotoEscolhida == null ? null : await _fotos.guardar(fotoEscolhida, petId: atual.id);

    // A idade só é "reinformada" se o tutor mudou o valor: senão ela continua
    // avançando a partir da data em que foi informada.
    final idadeMudou = dados.idadeMeses != atual.idadeMesesEm(agora);
    final editado = atual.copyWith(
      nome: dados.nome.trim(),
      especie: dados.especie,
      sexo: dados.sexo,
      idadeMeses: idadeMudou ? dados.idadeMeses : atual.idadeMeses,
      idadeInformadaEm: idadeMudou ? agora : atual.idadeInformadaEm,
      castrado: dados.castrado,
      nivelAtividade: dados.nivelAtividade,
      fotoArquivo: fotoNova == null ? null : () => fotoNova,
    );
    final novoPeso = dados.pesoInicialKg!;
    try {
      await _repositorio.editar(
        editado,
        pesoInicialKg: novoPeso == pesoInicialAtualKg ? null : novoPeso,
        agora: agora,
      );
    } catch (_) {
      if (fotoNova != null) await _fotos.apagar(fotoNova);
      rethrow;
    }

    // Só depois da transação confirmada: apaga a foto antiga.
    final antiga = atual.fotoArquivo;
    if (fotoNova != null && antiga != null && antiga != fotoNova) await _fotos.apagar(antiga);
    await reagendarLembretes?.call(editado.id, editado.nome);
  }
}
