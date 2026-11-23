import '../entidades/dados_pet.dart';
import '../entidades/pet.dart';
import '../repositorios/pet_repositorio.dart';

/// Cadastra um pet com o peso inicial e o torna o pet atual (U2-10).
///
/// O formulário valida antes (`validarDadosPet`); chamar com dados
/// inválidos é erro de programação e lança [ArgumentError].
final class CadastrarPet {
  const CadastrarPet(this._repositorio, {required this.novoId});

  final PetRepositorio _repositorio;
  /// Gera IDs estáveis (UUID v4).
  final String Function() novoId;

  /// Devolve o id do pet cadastrado.
  Future<String> call(DadosPet dados, {required DateTime agora}) async {
    final erros = validarDadosPet(dados);
    if (erros.isNotEmpty) throw ArgumentError('Dados do pet inválidos: ${erros.keys.map((c) => c.name)}');

    final pet = Pet(
      id: novoId(),
      nome: dados.nome.trim(),
      especie: dados.especie!,
      sexo: dados.sexo!,
      idadeMeses: dados.idadeMeses!,
      idadeInformadaEm: agora,
      castrado: dados.castrado!,
      nivelAtividade: dados.nivelAtividade!,
    );
    await _repositorio.cadastrar(pet, pesoInicialKg: dados.pesoInicialKg!, agora: agora);
    return pet.id;
  }
}
