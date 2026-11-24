import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/dependencias_nucleo.dart';

void main() {
  group('codigosNoTexto', () {
    test('não confunde P1-0.1 com P1-0.11', () {
      expect(codigosNoTexto('feat(base): P1-0.11 sugestoes'), {'P1-0.11'});
      expect(codigosNoTexto('feat(base): P1-0.1 projeto'), {'P1-0.1'});
    });

    test('vários códigos no mesmo título', () {
      expect(codigosNoTexto('feat(pets): P1-1.2 e P1-1.3 telas'), {'P1-1.2', 'P1-1.3'});
    });

    test('expande intervalos do mesmo grupo', () {
      expect(
        codigosNoTexto('feat(base): Fase 0 do pacote 1 (P1-0.1 a P1-0.4)'),
        {'P1-0.1', 'P1-0.2', 'P1-0.3', 'P1-0.4'},
      );
    });

    test('texto sem código', () {
      expect(codigosNoTexto('Merge pull request #1 from x/p1'), isEmpty);
    });
  });

  group('lerDependencias', () {
    test('lê lista, lista vazia e comentários', () {
      final deps = lerDependencias('''
# comentário
P1-0.1: []            # projeto
P1-0.2: [P1-0.1]
P1-1.1: [P1-0.1, P1-0.2]
''');
      expect(deps, {
        'P1-0.1': <String>[],
        'P1-0.2': ['P1-0.1'],
        'P1-1.1': ['P1-0.1', 'P1-0.2'],
      });
    });

    test('rejeita linha mal formada e tarefa repetida', () {
      expect(() => lerDependencias('P1-0.1: P1-0.2'), throwsFormatException);
      expect(() => lerDependencias('P1-0.1: []\nP1-0.1: []'), throwsFormatException);
      expect(() => lerDependencias('P1-0.2: [P1-0.1x]'), throwsFormatException);
    });
  });

  group('validarGrafo', () {
    test('grafo válido', () {
      expect(
        validarGrafo({
          'P1-0.1': [],
          'P1-0.2': ['P1-0.1'],
        }),
        isEmpty,
      );
    });

    test('dependência inexistente e de si mesma', () {
      final erros = validarGrafo({'P1-0.1': ['P1-0.9'], 'P1-0.2': ['P1-0.2']});
      expect(erros, hasLength(2));
    });

    test('ciclo', () {
      final erros = validarGrafo({
        'P1-0.1': ['P1-0.3'],
        'P1-0.2': ['P1-0.1'],
        'P1-0.3': ['P1-0.2'],
      });
      expect(erros.single, startsWith('ciclo:'));
    });
  });

  group('avaliar', () {
    final repo = Repositorio(
      naDev: {'P1-0.1'},
      noHead: {'P1-0.2'},
      porBranchRemoto: {
        'origin/p2/diario': {'P2-0.1'},
      },
      prPorBranch: {'origin/p2/diario': 7},
    );

    test('liberada quando todas as dependências estão na dev', () {
      expect(avaliar('P1-0.5', ['P1-0.1'], repo), Liberacao.liberada);
      expect(avaliar('P3-0.2', [], repo), Liberacao.liberada);
    });

    test('liberada só no branch quando alguma dependência está só no HEAD', () {
      expect(avaliar('P1-0.5', ['P1-0.1', 'P1-0.2'], repo), Liberacao.liberadaPeloBranch);
    });

    test('bloqueada por dependência em outro branch ou não iniciada', () {
      expect(avaliar('P2-1.1', ['P2-0.1'], repo), Liberacao.bloqueada);
      expect(avaliar('P2-1.1', ['P1-0.9'], repo), Liberacao.bloqueada);
    });

    test('a própria tarefa já feita', () {
      expect(avaliar('P1-0.1', [], repo), Liberacao.jaFeita);
      expect(avaliar('P1-0.2', ['P1-0.1'], repo), Liberacao.feitaNoBranch);
    });

    test('descreve o PR aberto', () {
      expect(repo.descrever('P2-0.1'), 'em andamento (origin/p2/diario, PR #7 aberto)');
    });
  });

  test('dependencias.yaml é válido e tem as mesmas tarefas do plano', () {
    final deps = lerDependencias(File('docs/specs/dependencias.yaml').readAsStringSync());
    final plano = codigosDoPlano(File('docs/specs/plano-de-execucao.md').readAsStringSync());

    expect(validarGrafo(deps), isEmpty);
    expect(plano.difference(deps.keys.toSet()), isEmpty, reason: 'tarefas do plano sem linha no dependencias.yaml');
    expect(deps.keys.toSet().difference(plano), isEmpty, reason: 'tarefas do dependencias.yaml fora do plano');
  });
}
