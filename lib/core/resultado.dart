/// Resultado selado dos modelos matemáticos e regras de domínio
/// (`docs/specs/comum/modelos-matematicos.md`). Em vez de lançar exceção,
/// o domínio devolve [Disponivel] com o valor ou [Indisponivel] com o motivo,
/// que já é o texto mostrado ao tutor quando couber.
sealed class Resultado<T> {
  const Resultado();

  /// O valor, se disponível; senão `null`.
  T? get valorOuNulo => switch (this) {
        Disponivel(:final valor) => valor,
        Indisponivel() => null,
      };

  bool get disponivel => this is Disponivel<T>;
}

final class Disponivel<T> extends Resultado<T> {
  const Disponivel(this.valor);

  final T valor;

  @override
  bool operator ==(Object other) => other is Disponivel<T> && other.valor == valor;

  @override
  int get hashCode => Object.hash(Disponivel, valor);

  @override
  String toString() => 'Disponivel($valor)';
}

final class Indisponivel<T> extends Resultado<T> {
  const Indisponivel(this.motivo);

  final String motivo;

  @override
  bool operator ==(Object other) => other is Indisponivel<T> && other.motivo == motivo;

  @override
  int get hashCode => Object.hash(Indisponivel, motivo);

  @override
  String toString() => 'Indisponivel($motivo)';
}
