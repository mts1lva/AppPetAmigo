/// Evita que o reagendamento global intercale cancelamentos com um salvamento.
final class SerializadorLembretes {
  Future<void> _anterior = Future.value();

  Future<T> executar<T>(Future<T> Function() acao) {
    final proxima = _anterior.then((_) => acao());
    _anterior = proxima.then<void>(
      (_) {},
      onError: (Object erro, StackTrace stack) {},
    );
    return proxima;
  }
}
