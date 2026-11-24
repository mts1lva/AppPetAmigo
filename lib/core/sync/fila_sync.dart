/// Contrato da fila de sincronização (`docs/specs/comum/dados-e-sync.md` →
/// Contrato da fila). Feito pelo P1 na etapa 1 (P5-0.1), porque toda gravação
/// de registro chama a fila desde o primeiro repositório; o P5 entrega a
/// `FilaSyncAtiva` na etapa 5.
///
/// Uso em qualquer repositório (sempre **dentro** da transação do drift):
/// ```dart
/// Future<void> salvar(Refeicao r) => db.transaction(() async {
///   final atual = await dao.buscar(r.id);
///   await dao.gravar(/* … */ versao: (atual?.versao ?? 0) + 1,
///       estadoSync: (await fila.estadoInicial()).name);
///   await fila.enfileirar(ColecoesSync.refeicoes, r.id, OperacaoSync.upsert);
/// });
/// ```
library;

/// Operação enfileirada. O `name` é o valor da coluna `fila_sync.operacao`.
enum OperacaoSync { upsert, excluir }

/// Estado de sincronização de um registro. O `name` é o valor da coluna
/// `estadoSync` das tabelas sincronizáveis.
enum EstadoSync {
  /// Cópia remota desligada.
  local,
  pendente,
  sincronizado,
  falha,
  conflito,
}

/// Nomes das tabelas sincronizáveis, iguais aos das coleções no Firestore
/// (`usuarios/{uid}/<colecao>/{id}`).
abstract final class ColecoesSync {
  static const pets = 'pets';
  static const alimentos = 'alimentos';
  static const refeicoes = 'refeicoes';
  static const extras = 'extras';
  static const atividades = 'atividades';
  static const lembretes = 'lembretes';
  static const pesagens = 'pesagens';
  static const referencias = 'referencias';

  /// Na ordem em que o pull deve aplicar (os pets antes, por causa das chaves
  /// estrangeiras do banco local).
  static const todas = [pets, alimentos, refeicoes, extras, atividades, lembretes, pesagens, referencias];
}

abstract interface class FilaSync {
  /// Estado com que um registro novo ou alterado deve ser gravado:
  /// [EstadoSync.local] com a cópia remota desligada, [EstadoSync.pendente]
  /// com ela ligada.
  Future<EstadoSync> estadoInicial();

  /// Chamar DENTRO da transação que gravou o registro.
  /// Com a cópia remota desligada, não faz nada.
  Future<void> enfileirar(String tabela, String registroId, OperacaoSync op);
}

/// Fila usada enquanto a cópia remota não existe ou está desligada: não
/// grava nada e todo registro fica como [EstadoSync.local].
final class FilaSyncInativa implements FilaSync {
  const FilaSyncInativa();

  @override
  Future<EstadoSync> estadoInicial() async => EstadoSync.local;

  @override
  Future<void> enfileirar(String tabela, String registroId, OperacaoSync op) async {}
}
