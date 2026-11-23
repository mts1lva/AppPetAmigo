import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/pets/domain/casos_de_uso/cadastrar_pet.dart';
import 'package:petamigo/features/pets/domain/casos_de_uso/editar_pet.dart';
import 'package:petamigo/features/pets/domain/casos_de_uso/excluir_pet.dart';
import 'package:petamigo/features/pets/domain/casos_de_uso/trocar_pet_atual.dart';
import 'package:petamigo/features/pets/domain/entidades/dados_pet.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';
import 'package:petamigo/features/pets/domain/repositorios/pet_atual_repositorio.dart';
import 'package:petamigo/features/pets/domain/repositorios/pet_repositorio.dart';

import 'dados_pet_test.dart' show valido;

/// Repositório falso: guarda as chamadas para conferir o que o caso de uso pediu.
final class _RepoFalso implements PetRepositorio {
  final cadastros = <(Pet, double)>[];
  final edicoes = <(Pet, double?)>[];
  final exclusoes = <String>[];

  @override
  Future<void> cadastrar(Pet pet, {required double pesoInicialKg, required DateTime agora}) async =>
      cadastros.add((pet, pesoInicialKg));

  @override
  Future<void> editar(Pet pet, {double? pesoInicialKg, required DateTime agora}) async =>
      edicoes.add((pet, pesoInicialKg));

  @override
  Future<void> excluir(String id, {required DateTime agora}) async => exclusoes.add(id);

  @override
  Stream<Pet?> observar(String id) => const Stream.empty();

  @override
  Stream<double?> observarPesoInicial(String petId) => const Stream.empty();

  @override
  Stream<List<Pet>> observarTodos() => const Stream.empty();
}

final class _PetAtualFalso implements PetAtualRepositorio {
  String? id;

  @override
  Future<void> definirId(String? petId) async => id = petId;

  @override
  Stream<String?> observarId() => Stream.value(id);
}

void main() {
  final agora = DateTime(2026, 9, 30, 8);

  group('CadastrarPet', () {
    test('monta o pet com o id novo, nome sem espaços, idade em meses e data informada = agora', () async {
      final repo = _RepoFalso();
      final id = await CadastrarPet(repo, novoId: () => 'novo-id')(
        const DadosPet(
          nome: '  Luna ',
          especie: Especie.gato,
          sexo: Sexo.femea,
          anos: 0,
          meses: 6,
          castrado: false,
          nivelAtividade: NivelAtividade.alta,
          pesoInicialKg: 2.1,
        ),
        agora: agora,
      );

      expect(id, 'novo-id');
      final (pet, peso) = repo.cadastros.single;
      expect(pet.nome, 'Luna');
      expect(pet.idadeMeses, 6);
      expect(pet.idadeInformadaEm, agora);
      expect(pet.fotoArquivo, isNull);
      expect(peso, 2.1);
    });

    test('dados inválidos → ArgumentError e nada gravado', () async {
      final repo = _RepoFalso();
      await expectLater(CadastrarPet(repo, novoId: () => 'x')(const DadosPet(), agora: agora), throwsArgumentError);
      expect(repo.cadastros, isEmpty);
    });
  });

  group('EditarPet', () {
    final luna = Pet(
      id: 'p1',
      nome: 'Luna',
      especie: Especie.gato,
      sexo: Sexo.femea,
      idadeMeses: 70,
      idadeInformadaEm: DateTime(2026, 7, 30),
      castrado: true,
      nivelAtividade: NivelAtividade.moderada,
      fotoArquivo: '/fotos/p1.jpg',
    );

    test('idade igual à atual: mantém a data informada (a idade continua avançando)', () async {
      final repo = _RepoFalso();
      await EditarPet(repo)(luna, DadosPet.dePet(luna, hoje: agora, pesoInicialKg: 5.4),
          pesoInicialAtualKg: 5.4, agora: agora);

      final (pet, peso) = repo.edicoes.single;
      expect(pet.idadeMeses, 70);
      expect(pet.idadeInformadaEm, DateTime(2026, 7, 30));
      expect(pet.fotoArquivo, '/fotos/p1.jpg');
      expect(peso, isNull, reason: 'peso inicial não mudou');
    });

    test('idade e peso inicial alterados: idade reinformada hoje e nova primeira pesagem (U2-06)', () async {
      final repo = _RepoFalso();
      final dados = DadosPet.dePet(luna, hoje: agora, pesoInicialKg: 5.6);
      await EditarPet(repo)(
        luna,
        DadosPet(
          nome: 'Luna',
          especie: dados.especie,
          sexo: dados.sexo,
          anos: 7,
          meses: 0,
          castrado: dados.castrado,
          nivelAtividade: dados.nivelAtividade,
          pesoInicialKg: 5.6,
        ),
        pesoInicialAtualKg: 5.4,
        agora: agora,
      );

      final (pet, peso) = repo.edicoes.single;
      expect(pet.idadeMeses, 84);
      expect(pet.idadeInformadaEm, agora);
      expect(peso, 5.6);
    });
  });

  test('ExcluirPet e TrocarPetAtual delegam aos repositórios', () async {
    final repo = _RepoFalso();
    await ExcluirPet(repo)('p1', agora: agora);
    expect(repo.exclusoes, ['p1']);

    final atual = _PetAtualFalso();
    await TrocarPetAtual(atual)('p2');
    expect(atual.id, 'p2');
  });

  test('o dado válido de exemplo passa na validação', () {
    expect(validarDadosPet(valido), isEmpty);
  });
}
