import '../entidades/dados_pet.dart';
import '../entidades/pet.dart';
import '../repositorios/pet_repositorio.dart';

/// Edita um pet. O peso inicial é editável (U2-06): alterá-lo altera a
/// primeira pesagem, e meta, gráfico e projeção se recalculam pelos streams.
///
/// A conferência de pesagem suspeita (R06, tela 25) no peso inicial é ligada
/// pelo P4 na P4-2.1.
final class EditarPet {
  const EditarPet(this._repositorio);

  final PetRepositorio _repositorio;

  /// [pesoInicialAtualKg]: peso inicial salvo hoje; só regrava a pesagem se
  /// o valor mudou.
  Future<void> call(
    Pet atual,
    DadosPet dados, {
    required double? pesoInicialAtualKg,
    required DateTime agora,
  }) async {
    final erros = validarDadosPet(dados);
    if (erros.isNotEmpty) throw ArgumentError('Dados do pet inválidos: ${erros.keys.map((c) => c.name)}');

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
    );
    final novoPeso = dados.pesoInicialKg!;
    await _repositorio.editar(
      editado,
      pesoInicialKg: novoPeso == pesoInicialAtualKg ? null : novoPeso,
      agora: agora,
    );
  }
}
