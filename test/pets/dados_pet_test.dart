import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/pets/domain/entidades/dados_pet.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

const valido = DadosPet(
  nome: 'Luna',
  especie: Especie.gato,
  sexo: Sexo.femea,
  anos: 6,
  meses: 0,
  castrado: true,
  nivelAtividade: NivelAtividade.moderada,
  pesoInicialKg: 5.4,
);

DadosPet com({String? nome, int? anos, int? meses, double? peso, bool limparPeso = false}) => DadosPet(
      nome: nome ?? valido.nome,
      especie: valido.especie,
      sexo: valido.sexo,
      anos: anos ?? valido.anos,
      meses: meses ?? valido.meses,
      castrado: valido.castrado,
      nivelAtividade: valido.nivelAtividade,
      pesoInicialKg: limparPeso ? null : (peso ?? valido.pesoInicialKg),
    );

void main() {
  group('R05 — validarDadosPet', () {
    test('dados válidos → sem erros', () {
      expect(validarDadosPet(valido), isEmpty);
    });

    test('formulário vazio: todos os campos com erro, na ordem da tela', () {
      expect(validarDadosPet(const DadosPet()).keys, CampoPet.values);
    });

    test('nome: obrigatório, 1 a 40 caracteres', () {
      expect(validarDadosPet(com(nome: '   '))[CampoPet.nome], 'Informe o nome.');
      expect(validarDadosPet(com(nome: 'a' * 41))[CampoPet.nome], 'Informe o nome.');
      expect(validarDadosPet(com(nome: 'a' * 40)), isEmpty);
    });

    test('idade: anos 0–30, meses 0–11 e no mínimo 1 mês (P-10)', () {
      expect(validarDadosPet(com(anos: 0, meses: 0))[CampoPet.idade], 'Informe a idade.');
      expect(validarDadosPet(com(anos: 31))[CampoPet.idade], 'Informe a idade.');
      expect(validarDadosPet(com(meses: 12))[CampoPet.idade], 'Informe a idade.');
      expect(validarDadosPet(com(anos: 0, meses: 1)), isEmpty);
      expect(validarDadosPet(com(anos: 30, meses: 11)), isEmpty);
    });

    test('peso inicial: > 0 e ≤ 150 kg (P-10)', () {
      expect(validarDadosPet(com(limparPeso: true))[CampoPet.pesoInicial], 'O valor precisa ser positivo.');
      expect(validarDadosPet(com(peso: 0))[CampoPet.pesoInicial], 'O valor precisa ser positivo.');
      expect(validarDadosPet(com(peso: 150.1))[CampoPet.pesoInicial], 'Confira o valor: acima de 150 kg.');
      expect(validarDadosPet(com(peso: 150)), isEmpty);
    });

    test('escolhas obrigatórias ficam só com a borda de erro (sem texto em R05)', () {
      final erros = validarDadosPet(const DadosPet(nome: 'Luna', anos: 1, meses: 0, pesoInicialKg: 5));
      expect(erros, {
        CampoPet.especie: '',
        CampoPet.sexo: '',
        CampoPet.castracao: '',
        CampoPet.atividade: '',
      });
    });
  });

  test('DadosPet.dePet separa a idade atual em anos e meses', () {
    final pet = Pet(
      id: 'p',
      nome: 'Luna',
      especie: Especie.gato,
      sexo: Sexo.femea,
      idadeMeses: 70,
      idadeInformadaEm: DateTime(2026, 7, 30),
      castrado: true,
      nivelAtividade: NivelAtividade.moderada,
    );
    final d = DadosPet.dePet(pet, hoje: DateTime(2026, 9, 30), pesoInicialKg: 5.6);
    expect((d.anos, d.meses, d.idadeMeses, d.pesoInicialKg), (6, 0, 72, 5.6));
  });
}
