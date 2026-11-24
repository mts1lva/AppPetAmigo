/// Regras puras do controle de dependências entre as tarefas do plano
/// (`docs/specs/dependencias.yaml`). Sem git, sem arquivos: o
/// `tool/dependencias.dart` busca os dados e chama estas funções, e o
/// `test/ferramentas/dependencias_test.dart` as testa.
library;

/// Código de tarefa do plano (`P2-1.3`). O lookahead impede que `P1-0.1`
/// case dentro de `P1-0.11`.
final RegExp _codigo = RegExp(r'P[1-5]-\d+\.\d+(?!\d)');

/// Intervalo escrito como no plano: `P1-0.1 a P1-0.11`.
final RegExp _intervalo = RegExp(r'(P[1-5])-(\d+)\.(\d+) a (P[1-5])-(\d+)\.(\d+)(?!\d)');

/// Linha do YAML: `P1-1.5: [P1-1.1, P1-0.8]   # comentário`.
final RegExp _linhaYaml = RegExp(r'^(P[1-5]-\d+\.\d+):\s*\[([^\]]*)\]\s*(?:#.*)?$');

/// Códigos citados num texto, expandindo intervalos (`P1-0.1 a P1-0.3` →
/// P1-0.1, P1-0.2, P1-0.3).
Set<String> codigosNoTexto(String texto) {
  final codigos = <String>{};
  for (final m in _intervalo.allMatches(texto)) {
    final mesmoGrupo = m[1] == m[4] && m[2] == m[5];
    final inicio = int.parse(m[3]!);
    final fim = int.parse(m[6]!);
    if (mesmoGrupo && inicio <= fim) {
      for (var i = inicio; i <= fim; i++) {
        codigos.add('${m[1]}-${m[2]}.$i');
      }
    }
  }
  codigos.addAll(_codigo.allMatches(texto).map((m) => m[0]!));
  return codigos;
}

/// Códigos das tarefas concluídas, a partir dos títulos dos commits (um por
/// linha). Títulos com `(parcial)` são commits intermediários e não contam.
Set<String> codigosConcluidos(String titulos) => {
      for (final titulo in titulos.split(RegExp(r'\r?\n')))
        if (!titulo.toLowerCase().contains('(parcial)')) ...codigosNoTexto(titulo),
    };

/// Lê o `dependencias.yaml`. Mantém a ordem do arquivo. Lança
/// [FormatException] em linha mal formada ou tarefa repetida.
Map<String, List<String>> lerDependencias(String texto) {
  final dependencias = <String, List<String>>{};
  final linhas = texto.split(RegExp(r'\r?\n'));
  for (var i = 0; i < linhas.length; i++) {
    final linha = linhas[i].trim();
    if (linha.isEmpty || linha.startsWith('#')) continue;
    final m = _linhaYaml.firstMatch(linha);
    if (m == null) {
      throw FormatException('dependencias.yaml, linha ${i + 1}: formato esperado "P1-1.5: [P1-1.1, P1-0.8]"', linha);
    }
    final codigo = m[1]!;
    if (dependencias.containsKey(codigo)) {
      throw FormatException('dependencias.yaml, linha ${i + 1}: $codigo aparece mais de uma vez', linha);
    }
    final lista = m[2]!.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    for (final dep in lista) {
      if (!_codigo.hasMatch(dep) || _codigo.firstMatch(dep)![0] != dep) {
        throw FormatException('dependencias.yaml, linha ${i + 1}: "$dep" não é um código de tarefa', linha);
      }
    }
    dependencias[codigo] = lista;
  }
  return dependencias;
}

/// Problemas do grafo: dependência de tarefa que não existe, tarefa que
/// depende de si mesma e ciclos. Lista vazia = grafo válido.
List<String> validarGrafo(Map<String, List<String>> dependencias) {
  final erros = <String>[];
  dependencias.forEach((codigo, deps) {
    for (final dep in deps) {
      if (dep == codigo) {
        erros.add('$codigo depende de si mesma');
      } else if (!dependencias.containsKey(dep)) {
        erros.add('$codigo depende de $dep, que não está no dependencias.yaml');
      }
    }
  });

  // Busca em profundidade com três cores para achar ciclos.
  const branco = 0, cinza = 1, preto = 2;
  final cor = {for (final c in dependencias.keys) c: branco};
  final pilha = <String>[];
  void visitar(String codigo) {
    cor[codigo] = cinza;
    pilha.add(codigo);
    for (final dep in dependencias[codigo]!) {
      if (!cor.containsKey(dep) || dep == codigo) continue;
      if (cor[dep] == cinza) {
        final ciclo = [...pilha.sublist(pilha.indexOf(dep)), dep];
        erros.add('ciclo: ${ciclo.join(' → ')}');
      } else if (cor[dep] == branco) {
        visitar(dep);
      }
    }
    pilha.removeLast();
    cor[codigo] = preto;
  }

  for (final codigo in dependencias.keys) {
    if (cor[codigo] == branco) visitar(codigo);
  }
  return erros;
}

/// Códigos das tabelas das etapas do `plano-de-execucao.md` (primeira
/// coluna das tabelas sob `## Etapa`). Linhas sem código (Stubs,
/// `ultimaPesagemProvider`) são ignoradas.
Set<String> codigosDoPlano(String plano) {
  final codigos = <String>{};
  var dentroDeEtapa = false;
  for (final linha in plano.split(RegExp(r'\r?\n'))) {
    if (linha.startsWith('## ')) {
      dentroDeEtapa = linha.startsWith('## Etapa');
      continue;
    }
    if (!dentroDeEtapa || !linha.startsWith('|')) continue;
    final celulas = linha.split('|');
    if (celulas.length < 3) continue;
    codigos.addAll(codigosNoTexto(celulas[1]));
  }
  return codigos;
}

/// Pacote dono da tarefa (`P2-1.3` → `P2`).
String pacoteDe(String codigo) => codigo.substring(0, 2);

/// Onde está uma tarefa, do mais adiantado para o menos.
enum Situacao {
  /// Commit com o código no título já está na origin/dev (PR aceito).
  feita,

  /// Commit só no branch atual (HEAD), ainda não na origin/dev.
  noSeuBranch,

  /// Commit num branch remoto que não é a dev (em andamento, talvez com PR).
  emOutroBranch,

  /// Nenhum commit com o código.
  naoIniciada,
}

/// Retrato do repositório que o `tool/dependencias.dart` monta com git e gh.
class Repositorio {
  Repositorio({
    required this.naDev,
    required this.noHead,
    this.porBranchRemoto = const {},
    this.prPorBranch = const {},
  });

  /// Códigos nos títulos dos commits da origin/dev.
  final Set<String> naDev;

  /// Códigos nos títulos de `origin/dev..HEAD`.
  final Set<String> noHead;

  /// Branch remoto (`origin/p1/fase-0`) → códigos em `origin/dev..branch`.
  final Map<String, Set<String>> porBranchRemoto;

  /// Branch remoto (`origin/p1/fase-0`) → número do PR aberto.
  final Map<String, int> prPorBranch;

  Situacao situacao(String codigo) {
    if (naDev.contains(codigo)) return Situacao.feita;
    if (noHead.contains(codigo)) return Situacao.noSeuBranch;
    if (branchesCom(codigo).isNotEmpty) return Situacao.emOutroBranch;
    return Situacao.naoIniciada;
  }

  /// Branches remotos (fora a dev) que têm a tarefa.
  List<String> branchesCom(String codigo) => [
        for (final e in porBranchRemoto.entries)
          if (e.value.contains(codigo)) e.key,
      ];

  /// Texto curto de onde a tarefa está, com o PR quando houver.
  String descrever(String codigo) {
    final branches = branchesCom(codigo);
    String ondeRemoto() => branches.map((b) {
          final pr = prPorBranch[b];
          return pr == null ? b : '$b, PR #$pr aberto';
        }).join('; ');
    switch (situacao(codigo)) {
      case Situacao.feita:
        return 'feita (na dev)';
      case Situacao.noSeuBranch:
        return branches.isEmpty ? 'só no seu branch (sem push)' : 'no seu branch (${ondeRemoto()})';
      case Situacao.emOutroBranch:
        return 'em andamento (${ondeRemoto()})';
      case Situacao.naoIniciada:
        return 'não iniciada';
    }
  }
}

/// Resultado da verificação de uma tarefa.
enum Liberacao {
  /// A própria tarefa já está na dev.
  jaFeita,

  /// A própria tarefa já tem commit no branch atual; falta o merge na dev.
  feitaNoBranch,

  /// Todas as dependências estão na dev.
  liberada,

  /// Todas as dependências estão na dev ou no branch atual. Pode continuar
  /// neste branch, mas quem depender dela espera o merge.
  liberadaPeloBranch,

  /// Alguma dependência não está nem na dev nem no branch atual.
  bloqueada,
}

Liberacao avaliar(String codigo, List<String> dependencias, Repositorio repo) {
  switch (repo.situacao(codigo)) {
    case Situacao.feita:
      return Liberacao.jaFeita;
    case Situacao.noSeuBranch:
      return Liberacao.feitaNoBranch;
    case Situacao.emOutroBranch:
    case Situacao.naoIniciada:
      break;
  }
  var precisaDoBranch = false;
  for (final dep in dependencias) {
    switch (repo.situacao(dep)) {
      case Situacao.feita:
        break;
      case Situacao.noSeuBranch:
        precisaDoBranch = true;
      case Situacao.emOutroBranch:
      case Situacao.naoIniciada:
        return Liberacao.bloqueada;
    }
  }
  return precisaDoBranch ? Liberacao.liberadaPeloBranch : Liberacao.liberada;
}
