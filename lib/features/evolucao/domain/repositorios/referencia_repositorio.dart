import '../entidades/referencia.dart';

/// ECC e objetivo do pet (tela 12). Dart puro.
///
/// **Uma linha vigente por pet** (`dados-e-sync.md`). Toda gravação é uma
/// transação que também chama a `FilaSync`.
abstract interface class ReferenciaRepositorio {
  /// A referência vigente do pet e cada mudança; `null` sem referência.
  Stream<Referencia?> observarVigente(String petId);

  /// Grava a referência como a vigente do pet. Se o id já existe, é uma
  /// alteração (`versao + 1`); qualquer outra linha vigente do mesmo pet vira
  /// lápide, para sobrar uma só.
  Future<void> salvar(Referencia referencia, {required DateTime agora});

  /// "Remover referências": lápide da referência vigente. **Não toca nas
  /// pesagens** (RF10).
  Future<void> remover(String petId, {required DateTime agora});
}
