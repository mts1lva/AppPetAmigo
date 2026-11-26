/// Contratos de comunicação com a cópia remota (`dados-e-sync.md` → Motor de
/// sincronização).
///
/// Na P5-1.4 o motor usa [FakeRemoto] em memória; na P5-3.1 entra o
/// `FirebaseRemoto` real sobre `cloud_firestore` sem mudar o motor.
library;

/// Documento lido da cópia remota (`usuarios/{uid}/{colecao}/{id}`).
final class DocumentoRemoto {
  const DocumentoRemoto({
    required this.colecao,
    required this.id,
    required this.dados,
    required this.versao,
    required this.atualizadoEm,
    required this.dispositivoId,
    required this.excluido,
  });

  final String colecao;
  final String id;
  final Map<String, Object?> dados;
  final int versao;
  final DateTime atualizadoEm;
  final String dispositivoId;
  final bool excluido;

  Map<String, Object?> paraJson() => {
        'colecao': colecao,
        'id': id,
        'dados': dados,
        'versao': versao,
        'atualizadoEm': atualizadoEm.toIso8601String(),
        'dispositivoId': dispositivoId,
        'excluido': excluido,
      };
}

/// Uma operação de escrita dentro de um lote atômico (`WriteBatch`).
final class EscritaLote {
  const EscritaLote({
    required this.colecao,
    required this.id,
    required this.dados,
    required this.versao,
    required this.dispositivoId,
    required this.excluido,
  });

  final String colecao;
  final String id;
  final Map<String, Object?> dados;
  final int versao;
  final String dispositivoId;
  final bool excluido;
}

/// Abstração da camada remota usada pelo [MotorSync].
abstract interface class RemotoSync {
  /// Liga a rede do cliente remoto no início de um ciclo no Wi-Fi.
  Future<void> ligarRede();

  /// Desliga a rede do cliente remoto ao terminar o ciclo ou se o Wi-Fi cair.
  Future<void> desligarRede();

  /// Busca os documentos remotos existentes para os [ids] pedidos na [colecao].
  Future<Map<String, DocumentoRemoto>> buscarDocumentos(
    String uid,
    String colecao,
    List<String> ids,
  );

  /// Grava todas as [escritas] num único lote atômico (máximo de 500).
  Future<void> enviarLote(String uid, List<EscritaLote> escritas);
}
