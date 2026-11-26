import 'remoto_sync.dart';

/// Implementação em memória de [RemotoSync] para testes unitários e para o
/// teste oficial T5 (`pacote-5` → Teste oficial T5).
final class FakeRemoto implements RemotoSync {
  FakeRemoto({DateTime Function()? agora}) : _agora = agora ?? DateTime.now;

  final DateTime Function() _agora;

  /// `uid -> colecao -> id -> DocumentoRemoto`.
  final Map<String, Map<String, Map<String, DocumentoRemoto>>> _banco = {};

  /// Estado simulado da rede (`ligarRede` / `desligarRede`).
  bool redeLigada = false;

  /// Total de chamadas a [enviarLote] (incluindo tentativas que falharam).
  int totalTentativasCommit = 0;

  /// Total de commits concluídos com sucesso.
  int totalCommits = 0;

  /// Histórico de lotes gravados (cada item é a lista de escritas de um commit).
  final List<List<EscritaLote>> historicoLotes = [];

  /// Quando preenchido, o próximo [enviarLote] lança esta exceção **sem**
  /// gravar nenhum documento (simula falha atômica do `WriteBatch`).
  Exception? erroNoProximoCommit;

  /// Quando `true`, o próximo [enviarLote] grava os documentos no remoto e
  /// lança exceção em seguida (simula commit confirmado no servidor cuja
  /// resposta se perdeu por queda de Wi-Fi).
  bool falharDepoisDeGravarNoProximoCommit = false;

  @override
  Future<void> ligarRede() async {
    redeLigada = true;
  }

  @override
  Future<void> desligarRede() async {
    redeLigada = false;
  }

  /// Grava diretamente um documento no estado remoto (simula outro aparelho).
  void gravarRemoto(String uid, DocumentoRemoto documento) {
    final colecoes = _banco.putIfAbsent(uid, () => {});
    final docs = colecoes.putIfAbsent(documento.colecao, () => {});
    docs[documento.id] = documento;
  }

  /// Lê um documento gravado no estado remoto.
  DocumentoRemoto? lerRemoto(String uid, String colecao, String id) =>
      _banco[uid]?[colecao]?[id];

  /// Todos os documentos de uma coleção no estado remoto.
  Map<String, DocumentoRemoto> documentosDaColecao(String uid, String colecao) =>
      Map.unmodifiable(_banco[uid]?[colecao] ?? const {});

  @override
  Future<Map<String, DocumentoRemoto>> buscarDocumentos(
    String uid,
    String colecao,
    List<String> ids,
  ) async {
    final docs = _banco[uid]?[colecao];
    if (docs == null || ids.isEmpty) return const {};
    return {
      for (final id in ids)
        if (docs.containsKey(id)) id: docs[id]!,
    };
  }

  @override
  Future<void> enviarLote(String uid, List<EscritaLote> escritas) async {
    if (escritas.length > 500) {
      throw ArgumentError.value(
        escritas.length,
        'escritas',
        'Um WriteBatch aceita no máximo 500 operações.',
      );
    }
    totalTentativasCommit++;

    final erro = erroNoProximoCommit;
    if (erro != null) {
      erroNoProximoCommit = null;
      throw erro;
    }

    final agora = _agora();
    for (final escrita in escritas) {
      gravarRemoto(
        uid,
        DocumentoRemoto(
          colecao: escrita.colecao,
          id: escrita.id,
          dados: Map<String, Object?>.unmodifiable(escrita.dados),
          versao: escrita.versao,
          atualizadoEm: agora,
          dispositivoId: escrita.dispositivoId,
          excluido: escrita.excluido,
        ),
      );
    }

    if (falharDepoisDeGravarNoProximoCommit) {
      falharDepoisDeGravarNoProximoCommit = false;
      throw StateError('Conexão perdida após o commit no servidor.');
    }

    totalCommits++;
    historicoLotes.add(List.unmodifiable(escritas));
  }
}
