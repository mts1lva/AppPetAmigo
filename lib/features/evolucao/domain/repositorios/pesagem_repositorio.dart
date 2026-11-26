import '../entidades/pesagem.dart';

/// Pesagens de um pet. Dart puro.
///
/// O P1 criou [observarUltima] para o Início e a meta (M1); o P4 completa na
/// P4-1.1, mantendo a assinatura. Toda gravação é **uma transação** que também
/// chama a `FilaSync`. Excluir vira lápide (`excluido = true`).
abstract interface class PesagemRepositorio {
  /// Emite a pesagem mais recente do pet (ignorando as excluídas) e cada
  /// mudança; `null` sem pesagem.
  Stream<Pesagem?> observarUltima(String petId);

  /// Todas as pesagens do pet, da mais antiga para a mais recente. A primeira
  /// é o **peso inicial** (U2-06).
  Stream<List<Pesagem>> observarTodas(String petId);

  /// Cria a pesagem ou, se o id já existe, grava a alteração (`versao + 1`).
  Future<void> salvar(Pesagem pesagem, {required DateTime agora});

  /// Lápide da pesagem. Não faz nada se ela não existe ou já foi excluída.
  Future<void> excluir(String id, {required DateTime agora});
}
