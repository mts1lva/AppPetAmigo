import 'package:flutter_test/flutter_test.dart';
import 'package:petamigo/features/pets/domain/descricao_pet.dart';
import 'package:petamigo/features/pets/domain/entidades/pet.dart';

final hoje = DateTime(2026, 9, 30);

Pet pet({
  Especie especie = Especie.gato,
  Sexo sexo = Sexo.femea,
  int idadeMeses = 72,
  bool castrado = true,
  DateTime? informadaEm,
}) =>
    Pet(
      id: 'p',
      nome: 'Luna',
      especie: especie,
      sexo: sexo,
      idadeMeses: idadeMeses,
      idadeInformadaEm: informadaEm ?? hoje,
      castrado: castrado,
      nivelAtividade: NivelAtividade.moderada,
    );

void main() {
  group('mesesCompletosEntre', () {
    test('conta só meses completos', () {
      expect(mesesCompletosEntre(DateTime(2026, 3, 15), DateTime(2026, 4, 14)), 0);
      expect(mesesCompletosEntre(DateTime(2026, 3, 15), DateTime(2026, 4, 15)), 1);
      expect(mesesCompletosEntre(DateTime(2025, 9, 30), DateTime(2026, 9, 30)), 12);
      expect(mesesCompletosEntre(DateTime(2026, 1, 31), DateTime(2026, 2, 28)), 0);
    });

    test('data final anterior → 0', () {
      expect(mesesCompletosEntre(DateTime(2026, 9, 30), DateTime(2026, 1, 1)), 0);
    });
  });

  group('Pet', () {
    test('idade atual = idadeMeses + meses desde a data informada', () {
      final p = pet(idadeMeses: 6, informadaEm: DateTime(2026, 3, 30));
      expect(p.idadeMesesEm(hoje), 12);
      expect(p.ehFilhoteEm(hoje), isFalse);
      expect(p.ehFilhoteEm(DateTime(2026, 9, 29)), isTrue);
    });

    test('toString não expõe o nome (logs)', () {
      expect(pet().toString(), isNot(contains('Luna')));
    });

    test('copyWith troca e remove a foto', () {
      final comFoto = pet().copyWith(fotoArquivo: () => '/fotos/p.jpg');
      expect(comFoto.fotoArquivo, '/fotos/p.jpg');
      expect(comFoto.copyWith(fotoArquivo: () => null).fotoArquivo, isNull);
      expect(comFoto.copyWith(nome: 'Mia').fotoArquivo, '/fotos/p.jpg');
    });
  });

  group('R11 — textos do pet', () {
    test('espécie flexionada pelo sexo (P-02)', () {
      expect(nomeEspecie(Especie.gato, Sexo.macho), 'Gato');
      expect(nomeEspecie(Especie.gato, Sexo.femea), 'Gata');
      expect(nomeEspecie(Especie.cao, Sexo.macho), 'Cão');
      expect(nomeEspecie(Especie.cao, Sexo.femea), 'Cadela');
    });

    test('castração flexionada', () {
      expect(castracaoTexto(pet(sexo: Sexo.femea)), 'castrada');
      expect(castracaoTexto(pet(sexo: Sexo.macho)), 'castrado');
      expect(castracaoTexto(pet(sexo: Sexo.femea, castrado: false)), 'não castrada');
      expect(castracaoTexto(pet(sexo: Sexo.macho, castrado: false)), 'não castrado');
    });

    test('linha do cabeçalho: Gata • 6 anos; filhote: Gata filhote • 6 meses', () {
      expect(linhaEspecieIdade(pet(), hoje), 'Gata • 6 anos');
      expect(linhaEspecieIdade(pet(idadeMeses: 6), hoje), 'Gata filhote • 6 meses');
      expect(linhaEspecieIdade(pet(especie: Especie.cao, sexo: Sexo.macho, idadeMeses: 12), hoje), 'Cão • 1 ano');
    });

    test('card do Início: Gata • 6 anos • castrada / Atividade moderada', () {
      final p = pet();
      expect('${linhaEspecieIdade(p, hoje)} • ${castracaoTexto(p)}', 'Gata • 6 anos • castrada');
      expect('Atividade ${nivelAtividadeTexto(p.nivelAtividade)}', 'Atividade moderada');
    });

    test('inicial do nome para o círculo sem foto (P-14)', () {
      expect(inicialDoNome('luna'), 'L');
      expect(inicialDoNome('  Érica'), 'É');
      expect(inicialDoNome(''), '');
    });
  });
}
