/// Contrato do mapeador de cada coleção (`docs/specs/comum/dados-e-sync.md` →
/// Contrato do mapeador). Cada pacote entrega os seus na própria etapa
/// (P1-3.1 a P4-3.1); o motor do P5 os chama na etapa 5.
///
/// Cada mapeador precisa de um **teste de ida e volta**:
/// `deFirestore(id, paraFirestore(x)) == x`, com um registro de cada tipo.
library;

abstract interface class MapeadorSync<T> {
  /// Nome da coleção no Firestore, igual ao da tabela local (ex.: `refeicoes`;
  /// use `ColecoesSync`).
  String get colecao;

  /// Campos do domínio (inclusive `petId`), com datas como `Timestamp`, sem
  /// os campos de controle locais. O motor acrescenta `versao`,
  /// `atualizadoEm`, `dispositivoId` e `excluido`.
  Map<String, Object?> paraFirestore(T registro);

  T deFirestore(String id, Map<String, Object?> documento);

  /// Resumo curto para a tela 17 Conferir versões (ex.: `30 g • 08:00`).
  String resumoConflito(T registro);

  /// Nome do tipo de registro no singular, para "A mesma refeição foi
  /// editada…" (ex.: `refeição`).
  String get nomeRegistro;
}
