import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/pets/domain/casos_de_uso/cadastrar_pet.dart';
import 'package:petamigo/features/pets/domain/casos_de_uso/editar_pet.dart';
import 'package:petamigo/features/pets/domain/casos_de_uso/excluir_pet.dart';
import 'package:petamigo/features/pets/domain/casos_de_uso/trocar_pet_atual.dart';
import 'package:petamigo/features/pets/domain/entidades/dados_pet.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';
import 'package:petamigo/features/pets/domain/repositorios/pet_atual_repositorio.dart';
import 'package:petamigo/features/pets/domain/repositorios/pet_repositorio.dart';

import '../apoio/pets_falsos.dart' show FotosFalsas;

import 'dados_pet_test.dart' show valido;

/// Repositório falso: guarda as chamadas para conferir o que o caso de uso pediu.
final class _RepoFalso implements PetRepositorio {
  final cadastros = <(Pet, double)>[];
  final edicoes = <(Pet, double?)>[];
  final exclusoes = <String>[];
  bool falhar = false;

  @override
  Future<void> cadastrar(Pet pet, {required double pesoInicialKg, required DateTime agora}) async {
    if (falhar) throw StateError('falha simulada');
    cadastros.add((pet, pesoInicialKg));
  }

  @override
  Future<void> editar(Pet pet, {double? pesoInicialKg, bool pesoInicialConferido = false, required DateTime agora}) async {
    if (falhar) throw StateError('falha simulada');
    edicoes.add((pet, pesoInicialKg));
  }

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

final lunaComFoto = Pet(
  id: 'p1',
  nome: 'Luna',
  especie: Especie.gato,
  sexo: Sexo.femea,
  idadeMeses: 72,
  idadeInformadaEm: DateTime(2026, 9, 30),
  castrado: true,
  nivelAtividade: NivelAtividade.moderada,
  fotoArquivo: '/fotos/p1.jpg',
);

DadosPet dadosLuna() => DadosPet.dePet(lunaComFoto, hoje: DateTime(2026, 9, 30, 8), pesoInicialKg: 5.4);

void main() {
  final agora = DateTime(2026, 9, 30, 8);

  group('CadastrarPet', () {
    test('monta o pet com o id novo, nome sem espaços, idade em meses e data informada = agora', () async {
      final repo = _RepoFalso();
      final id = await CadastrarPet(repo, FotosFalsas(), novoId: () => 'novo-id')(
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
      await expectLater(CadastrarPet(repo, FotosFalsas(), novoId: () => 'x')(const DadosPet(), agora: agora), throwsArgumentError);
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
      await EditarPet(repo, FotosFalsas())(luna, DadosPet.dePet(luna, hoje: agora, pesoInicialKg: 5.4),
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
      await EditarPet(repo, FotosFalsas())(
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
    final fotos = FotosFalsas();
    await ExcluirPet(repo, fotos)(lunaComFoto, agora: agora);
    expect(repo.exclusoes, ['p1']);
    expect(fotos.apagadas, ['/fotos/p1.jpg'], reason: 'excluir o pet apaga a foto');

    final atual = _PetAtualFalso();
    await TrocarPetAtual(atual)('p2');
    expect(atual.id, 'p2');
  });

  group('Foto (P1-1.4)', () {
    test('cadastrar com foto: copia para a área privada e grava o caminho', () async {
      final repo = _RepoFalso();
      final fotos = FotosFalsas();
      await CadastrarPet(repo, fotos, novoId: () => 'p9')(valido, agora: agora, fotoEscolhida: '/cache/x.jpg');
      expect(fotos.guardadas, [('/cache/x.jpg', 'p9')]);
      expect(repo.cadastros.single.$1.fotoArquivo, '/privado/fotos/p9-1.jpg');
    });

    test('cadastro que falha não deixa a cópia da foto', () async {
      final repo = _RepoFalso()..falhar = true;
      final fotos = FotosFalsas();
      await expectLater(
        CadastrarPet(repo, fotos, novoId: () => 'p9')(valido, agora: agora, fotoEscolhida: '/cache/x.jpg'),
        throwsStateError,
      );
      expect(fotos.apagadas, ['/privado/fotos/p9-1.jpg']);
    });

    test('trocar a foto apaga a antiga, só depois de salvar', () async {
      final repo = _RepoFalso();
      final fotos = FotosFalsas();
      await EditarPet(repo, fotos)(lunaComFoto, dadosLuna(),
          pesoInicialAtualKg: 5.4, agora: agora, fotoEscolhida: '/cache/nova.jpg');
      expect(repo.edicoes.single.$1.fotoArquivo, '/privado/fotos/p1-1.jpg');
      expect(fotos.apagadas, ['/fotos/p1.jpg']);
    });

    test('edição que falha mantém a foto antiga e descarta a nova', () async {
      final repo = _RepoFalso()..falhar = true;
      final fotos = FotosFalsas();
      await expectLater(
        EditarPet(repo, fotos)(lunaComFoto, dadosLuna(),
            pesoInicialAtualKg: 5.4, agora: agora, fotoEscolhida: '/cache/nova.jpg'),
        throwsStateError,
      );
      expect(fotos.apagadas, ['/privado/fotos/p1-1.jpg']);
    });

    test('editar sem foto nova não mexe na foto', () async {
      final repo = _RepoFalso();
      final fotos = FotosFalsas();
      await EditarPet(repo, fotos)(lunaComFoto, dadosLuna(), pesoInicialAtualKg: 5.4, agora: agora);
      expect(repo.edicoes.single.$1.fotoArquivo, '/fotos/p1.jpg');
      expect(fotos.guardadas, isEmpty);
      expect(fotos.apagadas, isEmpty);
    });
  });

  test('o dado válido de exemplo passa na validação', () {
    expect(validarDadosPet(valido), isEmpty);
  });
}
