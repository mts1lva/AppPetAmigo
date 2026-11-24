import '../entidades/pesagem.dart';

/// Pesagens de um pet. Dart puro.
///
/// O P1 criou só a leitura que o Início precisa; o P4 completa (gravar,
/// editar, excluir, histórico) na P4-1.1, mantendo [observarUltima].
abstract interface class PesagemRepositorio {
  /// Emite a pesagem mais recente do pet (ignorando as excluídas) e cada
  /// mudança; `null` sem pesagem.
  Stream<Pesagem?> observarUltima(String petId);
}
