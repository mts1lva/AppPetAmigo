/// M8 — Sugestões (U2-11). Tipo compartilhado pelas regras S1 (P2), S2 (P3)
/// e S3 (P4), cada uma uma função pura do domínio do próprio pacote que
/// devolve `Sugestao?`. Dart puro.
library;

/// No máximo 2 sugestões aparecem ao mesmo tempo.
const maximoSugestoes = 2;

/// "Agora não" esconde aquela sugestão por 7 dias.
const diasAdiamentoSugestao = 7;

/// Declarado na ordem de **prioridade**: S3 > S1 > S2. O `name` é o id
/// gravado em `config.sugestoesAdiadas`.
enum TipoSugestao {
  /// S3, do P4. Ação: "Ver evolução".
  mudarObjetivo,

  /// S1, do P2. Ação: "Ver diário".
  reduzirPetiscos,

  /// S2, do P3. Ação: "Ver atividades".
  aumentarExercicios,
}

final class Sugestao {
  const Sugestao({required this.tipo, required this.texto});

  final TipoSugestao tipo;

  /// Texto exato de M8, já com o nome do pet e os números.
  final String texto;

  @override
  bool operator ==(Object other) => other is Sugestao && other.tipo == tipo && other.texto == texto;

  @override
  int get hashCode => Object.hash(tipo, texto);

  @override
  String toString() => 'Sugestao(${tipo.name})';
}

/// Junta S1, S2 e S3: tira as nulas e as adiadas há menos de 7 dias, ordena
/// por prioridade (S3 > S1 > S2) e devolve no máximo 2.
///
/// [adiadas]: tipo → dia em que o tutor tocou "Agora não".
List<Sugestao> selecionarSugestoes({
  Sugestao? s1,
  Sugestao? s2,
  Sugestao? s3,
  Map<TipoSugestao, DateTime> adiadas = const {},
  required DateTime hoje,
}) {
  final dia = DateTime(hoje.year, hoje.month, hoje.day);
  bool adiada(Sugestao s) {
    final em = adiadas[s.tipo];
    if (em == null) return false;
    final diaAdiada = DateTime(em.year, em.month, em.day);
    return dia.difference(diaAdiada).inDays < diasAdiamentoSugestao;
  }

  final candidatas = [s1, s2, s3].whereType<Sugestao>().where((s) => !adiada(s)).toList()
    ..sort((a, b) => a.tipo.index.compareTo(b.tipo.index));
  return candidatas.take(maximoSugestoes).toList();
}
