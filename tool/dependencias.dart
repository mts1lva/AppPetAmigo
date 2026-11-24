// Controle de dependências entre as tarefas do plano.
//
//   dart tool/dependencias.dart verificar P2-1.3 [P2-1.4 ...]
//   dart tool/dependencias.dart proximas [P2]
//   dart tool/dependencias.dart validar
//   dart tool/dependencias.dart responsaveis   (pacotes, responsáveis e progresso)
//   dart tool/dependencias.dart assumir P2 ["Nome"]   (registra no README)
//
// Opção: --sem-fetch (não roda `git fetch`; usa o último estado baixado).
//
// Uma tarefa conta como feita quando o título de um commit na origin/dev tem
// o código dela. Dependências em docs/specs/dependencias.yaml.
//
// Códigos de saída do `verificar`: 0 liberada, 1 bloqueada, 2 já feita
// (na dev ou no branch atual),
// 64 uso errado, 70 erro (git, arquivo).

import 'dart:convert';
import 'dart:io';

import 'dependencias_nucleo.dart';

final Directory _raiz = File.fromUri(Platform.script).parent.parent;
const String _caminhoYaml = 'docs/specs/dependencias.yaml';
const String _caminhoPlano = 'docs/specs/plano-de-execucao.md';
const String _caminhoReadme = 'docs/specs/README.md';

Future<void> main(List<String> argumentos) async {
  final semFetch = argumentos.contains('--sem-fetch');
  final args = argumentos.where((a) => !a.startsWith('--')).toList();
  if (args.isEmpty) {
    _uso();
    exitCode = 64;
    return;
  }
  try {
    switch (args.first) {
      case 'verificar':
        exitCode = await _verificar(args.skip(1).toList(), semFetch: semFetch);
      case 'proximas':
        exitCode = await _proximas(args.length > 1 ? args[1].toUpperCase() : null, semFetch: semFetch);
      case 'validar':
        exitCode = _validar();
      case 'responsaveis':
        exitCode = await _responsaveis(semFetch: semFetch);
      case 'assumir':
        exitCode = await _assumir(args.skip(1).toList(), semFetch: semFetch);
      default:
        _uso();
        exitCode = 64;
    }
  } on _ErroGit catch (e) {
    stderr.writeln('Erro: ${e.mensagem}');
    exitCode = 70;
  } on FormatException catch (e) {
    stderr.writeln('Erro: ${e.message}');
    exitCode = 70;
  }
}

void _uso() {
  stderr.writeln('''
Uso:
  dart tool/dependencias.dart verificar <código> [<código> ...]   ex.: verificar P2-1.3
  dart tool/dependencias.dart proximas [<pacote>]                 ex.: proximas P2
  dart tool/dependencias.dart validar
  dart tool/dependencias.dart responsaveis
  dart tool/dependencias.dart assumir <pacote> ["Nome"]           ex.: assumir P2
Opção: --sem-fetch  usa o último estado baixado do GitHub''');
}

// ---------------------------------------------------------------- comandos

Future<int> _verificar(List<String> pedidos, {required bool semFetch}) async {
  final codigos = pedidos.map((p) => p.toUpperCase()).toList();
  if (codigos.isEmpty) {
    _uso();
    return 64;
  }
  final deps = _lerYaml();
  final desconhecidos = codigos.where((c) => !deps.containsKey(c)).toList();
  if (desconhecidos.isNotEmpty) {
    stderr.writeln('Tarefa fora do $_caminhoYaml: ${desconhecidos.join(', ')}');
    return 64;
  }

  final repo = await _lerRepositorio(semFetch: semFetch);
  var pior = 0;
  for (final codigo in codigos) {
    final lista = deps[codigo]!;
    final resultado = avaliar(codigo, lista, repo);
    stdout.writeln('$codigo (pacote ${pacoteDe(codigo)}): ${_rotulo(resultado)}');
    final propria = repo.situacao(codigo);
    if (propria == Situacao.emOutroBranch || propria == Situacao.noSeuBranch) {
      stdout.writeln('  esta tarefa: ${repo.descrever(codigo)}');
    }
    if (lista.isEmpty) {
      stdout.writeln('  sem dependências');
    }
    for (final dep in lista) {
      final ok = repo.situacao(dep) == Situacao.feita;
      stdout.writeln('  ${ok ? '[ok]' : '[  ]'} $dep: ${repo.descrever(dep)}');
    }
    switch (resultado) {
      case Liberacao.jaFeita:
      case Liberacao.feitaNoBranch:
        pior = pior == 0 ? 2 : pior;
      case Liberacao.bloqueada:
        pior = 1;
      case Liberacao.liberadaPeloBranch:
        stdout.writeln('  Atenção: continue neste branch. O que depender de $codigo só libera depois do merge na dev.');
      case Liberacao.liberada:
        break;
    }
  }
  return pior;
}

Future<int> _proximas(String? pacote, {required bool semFetch}) async {
  if (pacote != null && !RegExp(r'^P[1-5]$').hasMatch(pacote)) {
    _uso();
    return 64;
  }
  final deps = _lerYaml();
  final repo = await _lerRepositorio(semFetch: semFetch);
  final linhas = <String>[];
  deps.forEach((codigo, lista) {
    if (pacote != null && pacoteDe(codigo) != pacote) return;
    final situacao = repo.situacao(codigo);
    if (situacao == Situacao.feita || situacao == Situacao.noSeuBranch) return;
    final resultado = avaliar(codigo, lista, repo);
    if (resultado != Liberacao.liberada && resultado != Liberacao.liberadaPeloBranch) return;
    final notas = [
      if (resultado == Liberacao.liberadaPeloBranch) 'só neste branch',
      if (situacao == Situacao.emOutroBranch) repo.descrever(codigo),
    ];
    linhas.add('  $codigo${notas.isEmpty ? '' : '  (${notas.join('; ')})'}');
  });
  final filtro = pacote == null ? '' : ' do $pacote';
  if (linhas.isEmpty) {
    stdout.writeln('Nenhuma tarefa$filtro liberada agora.');
  } else {
    stdout.writeln('Tarefas$filtro liberadas e ainda não feitas:');
    linhas.forEach(stdout.writeln);
  }
  return 0;
}

int _validar() {
  final deps = _lerYaml();
  final plano = codigosDoPlano(_ler(_caminhoPlano));
  final erros = [
    ...validarGrafo(deps),
    for (final c in plano.difference(deps.keys.toSet())) '$c está no plano mas não no $_caminhoYaml',
    for (final c in deps.keys.toSet().difference(plano)) '$c está no $_caminhoYaml mas não no plano',
  ];
  if (erros.isEmpty) {
    stdout.writeln('OK: ${deps.length} tarefas, sem ciclos, iguais às do plano.');
    return 0;
  }
  erros.forEach(stderr.writeln);
  return 1;
}

// ---------------------------------------------------------------- responsáveis

/// Quem pegou cada pacote: na dev, neste branch (README local) e nos branches
/// remotos (escolhas ainda em PR).
class _Escolhas {
  _Escolhas(this.pacotes, this.porPacote);

  /// Pacotes do README local (escopo, telas, Firebase, teste).
  final List<InfoPacote> pacotes;

  /// Pacote → nome → onde está registrado ('dev', 'neste branch', branch remoto).
  final Map<String, Map<String, List<String>>> porPacote;

  Map<String, List<String>> de(String pacote) => porPacote[pacote] ?? const {};

  /// Pacote de [nome], se houver.
  String? pacoteDe(String nome) {
    for (final e in porPacote.entries) {
      if (e.value.keys.any((n) => _mesmoNome(n, nome))) return e.key;
    }
    return null;
  }
}

bool _mesmoNome(String a, String b) => a.trim().toLowerCase() == b.trim().toLowerCase();

Future<String?> _readmeEm(String ref) async {
  final r = await Process.run('git', ['show', '$ref:$_caminhoReadme'], workingDirectory: _raiz.path, stdoutEncoding: utf8);
  return r.exitCode == 0 ? r.stdout as String : null;
}

Future<_Escolhas> _lerEscolhas(Repositorio repo) async {
  final porPacote = <String, Map<String, List<String>>>{};
  void anotar(String? readme, String onde) {
    if (readme == null) return;
    for (final p in pacotesDoReadme(readme)) {
      final nome = p.responsavel;
      if (nome == null) continue;
      final nomes = porPacote.putIfAbsent(p.pacote, () => {});
      final chave = nomes.keys.firstWhere((n) => _mesmoNome(n, nome), orElse: () => nome);
      nomes.putIfAbsent(chave, () => []).add(onde);
    }
  }

  anotar(await _readmeEm('origin/dev'), 'dev');
  final local = _ler(_caminhoReadme);
  anotar(local, 'neste branch');
  final refs = await _git(['for-each-ref', 'refs/remotes/origin', '--format=%(refname:short)']);
  for (final b in refs.split('\n').map((s) => s.trim())) {
    if (b.isEmpty || b == 'origin/dev' || b == 'origin/HEAD' || b == 'origin') continue;
    final pr = repo.prPorBranch[b];
    anotar(await _readmeEm(b), pr == null ? b : '$b, PR #$pr');
  }
  return _Escolhas(pacotesDoReadme(local), porPacote);
}

Future<String> _eu() async => (await _git(['config', 'user.name'])).trim();

String _descreverEscolha(Map<String, List<String>> nomes) {
  if (nomes.isEmpty) return 'livre';
  final partes = nomes.entries.map((e) {
    if (e.value.contains('dev')) return '${e.key} (confirmado na dev)';
    return '${e.key} (pendente: ${e.value.join('; ')})';
  }).toList();
  return nomes.length > 1 ? 'CONFLITO: ${partes.join(' x ')}' : partes.single;
}

Future<int> _responsaveis({required bool semFetch}) async {
  final deps = _lerYaml();
  final repo = await _lerRepositorio(semFetch: semFetch);
  final escolhas = await _lerEscolhas(repo);
  for (final p in escolhas.pacotes) {
    final tarefas = deps.keys.where((c) => pacoteDe(c) == p.pacote).toList();
    final feitas = tarefas.where((c) => repo.situacao(c) == Situacao.feita).length;
    final andamento = tarefas
        .where((c) => repo.situacao(c) == Situacao.noSeuBranch || repo.situacao(c) == Situacao.emOutroBranch)
        .length;
    stdout
      ..writeln('${p.pacote} — ${p.escopo}')
      ..writeln('   Telas: ${p.telas} · Firebase: ${p.firebase} · Teste oficial: ${p.teste}')
      ..writeln('   Responsável: ${_descreverEscolha(escolhas.de(p.pacote))}')
      ..writeln('   Progresso: $feitas de ${tarefas.length} tarefas na dev, $andamento em andamento')
      ..writeln();
  }
  final eu = await _eu();
  final meu = eu.isEmpty ? null : escolhas.pacoteDe(eu);
  stdout.writeln(meu == null ? 'VOCÊ ($eu): sem pacote' : 'VOCÊ ($eu): $meu');
  return 0;
}

Future<int> _assumir(List<String> args, {required bool semFetch}) async {
  if (args.isEmpty || !RegExp(r'^P[1-5]$').hasMatch(args.first.toUpperCase())) {
    _uso();
    return 64;
  }
  final pacote = args.first.toUpperCase();
  final nome = args.length > 1 ? args.skip(1).join(' ').trim() : await _eu();
  if (nome.isEmpty || nome.contains('|')) {
    stderr.writeln('Informe o nome: dart tool/dependencias.dart assumir $pacote "Seu Nome"');
    return 64;
  }

  final repo = await _lerRepositorio(semFetch: semFetch);
  final escolhas = await _lerEscolhas(repo);
  final outros = escolhas.de(pacote).keys.where((n) => !_mesmoNome(n, nome)).toList();
  if (outros.isNotEmpty) {
    stderr.writeln('O $pacote já foi escolhido: ${_descreverEscolha(escolhas.de(pacote))}. Escolha outro pacote.');
    return 1;
  }
  final atual = escolhas.pacoteDe(nome);
  if (atual != null && atual != pacote) {
    stderr.writeln('$nome já é responsável pelo $atual. Cada pessoa assume um pacote.');
    return 1;
  }

  final arquivo = File('${_raiz.path}/$_caminhoReadme');
  arquivo.writeAsStringSync(readmeComResponsavel(arquivo.readAsStringSync(), pacote, nome));
  stdout
    ..writeln('$nome registrado(a) como responsável pelo $pacote em $_caminhoReadme.')
    ..writeln('Commit sugerido: docs(specs): $nome assume o pacote ${pacote.substring(1)}');
  return 0;
}

// ---------------------------------------------------------------- apoio

String _rotulo(Liberacao l) => switch (l) {
      Liberacao.jaFeita => 'JÁ FEITA (está na dev)',
      Liberacao.feitaNoBranch => 'JÁ FEITA NESTE BRANCH (falta o merge na dev)',
      Liberacao.liberada => 'LIBERADA',
      Liberacao.liberadaPeloBranch => 'LIBERADA NESTE BRANCH',
      Liberacao.bloqueada => 'BLOQUEADA',
    };

String _ler(String relativo) => File('${_raiz.path}/$relativo').readAsStringSync();

Map<String, List<String>> _lerYaml() => lerDependencias(_ler(_caminhoYaml));

class _ErroGit implements Exception {
  _ErroGit(this.mensagem);
  final String mensagem;
}

Future<String> _git(List<String> args) async {
  final r = await Process.run('git', args, workingDirectory: _raiz.path, stdoutEncoding: utf8);
  if (r.exitCode != 0) {
    throw _ErroGit('git ${args.join(' ')}: ${(r.stderr as String).trim()}');
  }
  return r.stdout as String;
}

Future<Set<String>> _codigosDosTitulos(String intervalo) async {
  final titulos = await _git(['log', intervalo, '--format=%s']);
  return codigosConcluidos(titulos);
}

Future<Repositorio> _lerRepositorio({required bool semFetch}) async {
  if (!semFetch) {
    final r = await Process.run('git', ['fetch', 'origin', '--quiet'], workingDirectory: _raiz.path);
    if (r.exitCode != 0) {
      stderr.writeln('Aviso: não deu para atualizar do GitHub (sem rede?). Usando o último estado baixado.');
    }
  }
  final refs = await _git(['for-each-ref', 'refs/remotes/origin', '--format=%(refname:short)']);
  final branches = refs.split('\n').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  if (!branches.contains('origin/dev')) {
    throw _ErroGit('a origin/dev não existe. Rode "git fetch origin".');
  }

  final naDev = await _codigosDosTitulos('origin/dev');
  final noHead = await _codigosDosTitulos('origin/dev..HEAD');
  final porBranch = <String, Set<String>>{};
  for (final b in branches) {
    if (b == 'origin/dev' || b == 'origin/HEAD' || b == 'origin') continue;
    final codigos = await _codigosDosTitulos('origin/dev..$b');
    if (codigos.isNotEmpty) porBranch[b] = codigos;
  }
  return Repositorio(naDev: naDev, noHead: noHead, porBranchRemoto: porBranch, prPorBranch: await _prsAbertos());
}

/// PRs abertos no GitHub, pelo `gh`. Sem `gh` ou sem login, segue sem eles.
Future<Map<String, int>> _prsAbertos() async {
  try {
    final r = await Process.run(
      'gh',
      ['pr', 'list', '--state', 'open', '--limit', '100', '--json', 'number,headRefName'],
      workingDirectory: _raiz.path,
      stdoutEncoding: utf8,
    );
    if (r.exitCode != 0) {
      stderr.writeln('Aviso: gh indisponível; os PRs abertos não aparecem.');
      return {};
    }
    final lista = jsonDecode(r.stdout as String) as List<dynamic>;
    return {
      for (final pr in lista.cast<Map<String, dynamic>>()) 'origin/${pr['headRefName']}': pr['number'] as int,
    };
  } on ProcessException {
    stderr.writeln('Aviso: gh não instalado; os PRs abertos não aparecem.');
    return {};
  }
}
