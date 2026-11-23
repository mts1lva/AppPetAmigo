import '../entidades/dados_pet.dart';
import '../entidades/pet.dart';
import '../repositorios/fotos_pet.dart';
import '../repositorios/pet_repositorio.dart';

/// Cadastra um pet com o peso inicial (e a foto, se escolhida) e o torna o
/// pet atual (U2-10).
///
/// O formulário valida antes (`validarDadosPet`); chamar com dados
/// inválidos é erro de programação e lança [ArgumentError].
final class CadastrarPet {
  const CadastrarPet(this._repositorio, this._fotos, {required this.novoId});

  final PetRepositorio _repositorio;
  final ArmazenamentoFotos _fotos;

  /// Gera IDs estáveis (UUID v4).
  final String Function() novoId;

  /// Devolve o id do pet cadastrado. [fotoEscolhida]: caminho temporário
  /// devolvido pelo seletor; é copiado para a área privada aqui.
  Future<String> call(DadosPet dados, {required DateTime agora, String? fotoEscolhida}) async {
    final erros = validarDadosPet(dados);
    if (erros.isNotEmpty) throw ArgumentError('Dados do pet inválidos: ${erros.keys.map((c) => c.name)}');

    final id = novoId();
    final foto = fotoEscolhida == null ? null : await _fotos.guardar(fotoEscolhida, petId: id);
    final pet = Pet(
      id: id,
      nome: dados.nome.trim(),
      especie: dados.especie!,
      sexo: dados.sexo!,
      idadeMeses: dados.idadeMeses!,
      idadeInformadaEm: agora,
      castrado: dados.castrado!,
      nivelAtividade: dados.nivelAtividade!,
      fotoArquivo: foto,
    );
    try {
      await _repositorio.cadastrar(pet, pesoInicialKg: dados.pesoInicialKg!, agora: agora);
    } catch (_) {
      // A transação desfez tudo: a cópia da foto também não deve sobrar.
      if (foto != null) await _fotos.apagar(foto);
      rethrow;
    }
    return id;
  }
}
