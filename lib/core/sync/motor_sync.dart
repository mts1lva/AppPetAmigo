import 'dart:convert';

import 'package:drift/drift.dart';

import '../banco/daos/config_dao.dart';
import '../banco/database.dart';
import 'fila_sync.dart';
import 'remoto_sync.dart';
import 'wifi.dart';

/// Limite máximo de operações num único `WriteBatch` do Firestore.
const int limiteWriteBatch = 500;

/// Tamanho padrão de leitura da fila por ciclo (`dados-e-sync.md` → Envio em
/// lote: "até 100 itens mais antigos da fila").
const int tamanhoPadraoLote = 100;

/// Resultado resumido de um ciclo de envio do [MotorSync].
final class ResultadoCicloSync {
  const ResultadoCicloSync({
    this.lotesEnviados = 0,
    this.itensSincronizados = 0,
    this.conflitosDetectados = 0,
    this.exclusoesRemotasAplicadas = 0,
    this.falhou = false,
    this.ignoradoSemWifi = false,
  });

  final int lotesEnviados;
  final int itensSincronizados;
  final int conflitosDetectados;
  final int exclusoesRemotasAplicadas;
  final bool falhou;
  final bool ignoradoSemWifi;
}

/// Motor de sincronização em lote (`dados-e-sync.md` → Motor de sincronização;
/// U2-16; P5-1.4).
///
/// Regras garantidas:
/// - Só roda quando a cópia remota está ativa e há Wi-Fi.
/// - Liga a rede no início do ciclo e desliga sempre no `finally`.
/// - Deduplica itens repetidos do mesmo `(tabela, registroId)` mantendo a
///   última operação.
/// - Classifica cada item: exclusão remota vence, exclusão local gera lápide,
///   idempotência por `dispositivoId`, conflito sai do lote sem travar o resto.
/// - Grava os restantes num único lote atômico (<= 500 operações).
/// - Se o commit falhar, nenhum item sai da fila e todos ficam com `falha` e
///   `tentativas + 1`.
final class MotorSync {
  MotorSync({
    required this._banco,
    required this._remoto,
    required this._wifi,
    this.tamanhoLote = tamanhoPadraoLote,
    DateTime Function()? agora,
  })  : assert(tamanhoLote > 0 && tamanhoLote <= limiteWriteBatch),
        _agora = agora ?? DateTime.now;

  final BancoLocal _banco;
  final RemotoSync _remoto;
  final VerificadorWifi _wifi;
  final int tamanhoLote;
  final DateTime Function() _agora;

  /// Tabelas locais sincronizáveis permitidas nas consultas dinâmicas.
  static const _tabelasPermitidas = {
    ColecoesSync.pets,
    ColecoesSync.alimentos,
    ColecoesSync.refeicoes,
    ColecoesSync.extras,
    ColecoesSync.atividades,
    ColecoesSync.lembretes,
    ColecoesSync.pesagens,
    ColecoesSync.referencias,
  };

  /// Colunas de controle locais que não vão no mapa de domínio do documento.
  static const _colunasControle = {
    'id',
    'criado_em',
    'atualizado_em',
    'versao',
    'versao_remota',
    'estado_sync',
    'excluido',
  };

  /// Executa ciclos de envio enquanto houver itens na fila e Wi-Fi ativo.
  Future<ResultadoCicloSync> executarEnvio() async {
    final ativa = await _banco.configDao.ler(ChavesConfig.copiaRemotaAtiva) == 'true';
    final uid = await _banco.configDao.ler(ChavesConfig.uid);
    if (!ativa || uid == null || uid.isEmpty) {
      return const ResultadoCicloSync();
    }

    if (!await _wifi.estaNoWifi()) {
      return const ResultadoCicloSync(ignoradoSemWifi: true);
    }

    final dispositivoId =
        await _banco.configDao.ler(ChavesConfig.dispositivoId) ?? 'aparelho-local';

    var lotesEnviados = 0;
    var itensSincronizados = 0;
    var conflitosDetectados = 0;
    var exclusoesRemotasAplicadas = 0;

    await _remoto.ligarRede();
    try {
      while (await _wifi.estaNoWifi()) {
        final brutos = await (_banco.select(_banco.itensFilaSync)
              ..orderBy([(f) => OrderingTerm.asc(f.id)])
              ..limit(tamanhoLote))
            .get();
        if (brutos.isEmpty) break;

        // 1. LOTE: deduplica itens repetidos do mesmo (tabela, registroId),
        // mantendo a última operação e guardando todos os IDs de fila do grupo.
        final grupos = <(String, String), _ItemAgrupado>{};
        for (final item in brutos) {
          final chave = (item.tabela, item.registroId);
          final existente = grupos[chave];
          if (existente == null) {
            grupos[chave] = _ItemAgrupado(
              tabela: item.tabela,
              registroId: item.registroId,
              operacao: _parseOperacao(item.operacao),
              idsFila: [item.id],
            );
          } else {
            existente.operacao = _parseOperacao(item.operacao);
            existente.idsFila.add(item.id);
          }
        }

        // 2. LEITURA: busca documentos remotos agrupados por coleção (em fatias
        // de até 30 IDs, limite do whereIn do Firestore).
        final idsPorColecao = <String, List<String>>{};
        for (final g in grupos.values) {
          idsPorColecao.putIfAbsent(g.tabela, () => []).add(g.registroId);
        }
        final remotos = <(String, String), DocumentoRemoto>{};
        for (final entrada in idsPorColecao.entries) {
          final colecao = entrada.key;
          final ids = entrada.value;
          for (var i = 0; i < ids.length; i += 30) {
            final fatia = ids.sublist(i, i + 30 > ids.length ? ids.length : i + 30);
            final encontrados = await _remoto.buscarDocumentos(uid, colecao, fatia);
            for (final doc in encontrados.entries) {
              remotos[(colecao, doc.key)] = doc.value;
            }
          }
        }

        // 3. CLASSIFICAÇÃO (local, item a item).
        final paraEnviar = <_ItemParaEnviar>[];
        final paraAplicarExclusaoRemota = <(_ItemAgrupado, DocumentoRemoto)>[];
        final paraConflito = <(_ItemAgrupado, DocumentoRemoto)>[];
        final paraDescartar = <_ItemAgrupado>[];

        for (final grupo in grupos.values) {
          if (!_tabelasPermitidas.contains(grupo.tabela)) {
            paraDescartar.add(grupo);
            continue;
          }
          final local = await _lerRegistroLocal(grupo.tabela, grupo.registroId);
          final remoto = remotos[(grupo.tabela, grupo.registroId)];

          // Precedência da exclusão remota confirmada.
          if (remoto != null && remoto.excluido) {
            paraAplicarExclusaoRemota.add((grupo, remoto));
            continue;
          }

          if (grupo.operacao == OperacaoSync.excluir) {
            final proximaVersao = (remoto?.versao ?? 0) + 1;
            paraEnviar.add(
              _ItemParaEnviar(
                grupo: grupo,
                escrita: EscritaLote(
                  colecao: grupo.tabela,
                  id: grupo.registroId,
                  dados: const {},
                  versao: proximaVersao,
                  dispositivoId: dispositivoId,
                  excluido: true,
                ),
              ),
            );
            continue;
          }

          // Upsert sem registro local (já removido fisicamente) → descarta da fila.
          if (local == null) {
            paraDescartar.add(grupo);
            continue;
          }

          if (remoto == null) {
            paraEnviar.add(
              _ItemParaEnviar(
                grupo: grupo,
                escrita: EscritaLote(
                  colecao: grupo.tabela,
                  id: grupo.registroId,
                  dados: local.dados,
                  versao: local.versao,
                  dispositivoId: dispositivoId,
                  excluido: local.excluido,
                ),
              ),
            );
            continue;
          }

          final mesmoDispositivoSemConfirmacao = remoto.dispositivoId == dispositivoId &&
              ((local.versaoRemota != null && remoto.versao == local.versaoRemota! + 1) ||
                  (local.versaoRemota == null && remoto.versao == local.versao));

          if (mesmoDispositivoSemConfirmacao) {
            paraEnviar.add(
              _ItemParaEnviar(
                grupo: grupo,
                escrita: EscritaLote(
                  colecao: grupo.tabela,
                  id: grupo.registroId,
                  dados: local.dados,
                  versao: remoto.versao,
                  dispositivoId: dispositivoId,
                  excluido: local.excluido,
                ),
              ),
            );
            continue;
          }

          if (local.versaoRemota != null && remoto.versao == local.versaoRemota) {
            paraEnviar.add(
              _ItemParaEnviar(
                grupo: grupo,
                escrita: EscritaLote(
                  colecao: grupo.tabela,
                  id: grupo.registroId,
                  dados: local.dados,
                  versao: remoto.versao + 1,
                  dispositivoId: dispositivoId,
                  excluido: local.excluido,
                ),
              ),
            );
            continue;
          }

          // Versão remota divergente de outro aparelho → conflito (sai do lote).
          paraConflito.add((grupo, remoto));
        }

        // Aplica exclusões remotas, registra conflitos e limpa itens órfãos.
        if (paraAplicarExclusaoRemota.isNotEmpty ||
            paraConflito.isNotEmpty ||
            paraDescartar.isNotEmpty) {
          final agora = _agora();
          await _banco.transaction(() async {
            for (final (grupo, remoto) in paraAplicarExclusaoRemota) {
              await _banco.customStatement(
                'UPDATE ${grupo.tabela} '
                'SET excluido = 1, versao = ?, versao_remota = ?, estado_sync = ? '
                'WHERE id = ?',
                [remoto.versao, remoto.versao, EstadoSync.sincronizado.name, grupo.registroId],
              );
              await _removerIdsFila(grupo.idsFila);
            }
            for (final (grupo, remoto) in paraConflito) {
              await _banco.into(_banco.conflitos).insertOnConflictUpdate(
                    ConflitosCompanion.insert(
                      tabela: grupo.tabela,
                      registroId: grupo.registroId,
                      dadosRemotos: jsonEncode(remoto.paraJson()),
                      detectadoEm: agora,
                    ),
                  );
              await _banco.customStatement(
                'UPDATE ${grupo.tabela} SET estado_sync = ? WHERE id = ?',
                [EstadoSync.conflito.name, grupo.registroId],
              );
              await _removerIdsFila(grupo.idsFila);
            }
            for (final grupo in paraDescartar) {
              await _removerIdsFila(grupo.idsFila);
            }
          });
          exclusoesRemotasAplicadas += paraAplicarExclusaoRemota.length;
          conflitosDetectados += paraConflito.length;
        }

        if (paraEnviar.isEmpty) continue;

        // 4. ESCRITA: um único lote atômico (máximo de 500 operações).
        try {
          await _remoto.enviarLote(
            uid,
            [for (final item in paraEnviar) item.escrita],
          );
        } catch (erro) {
          // 5b. COMMIT FALHOU: nenhum item sai da fila; tentativas++ e falha.
          final tipoErro = erro.runtimeType.toString();
          await _banco.transaction(() async {
            for (final item in paraEnviar) {
              await _banco.customStatement(
                'UPDATE ${item.grupo.tabela} SET estado_sync = ? WHERE id = ?',
                [EstadoSync.falha.name, item.grupo.registroId],
              );
              for (final idFila in item.grupo.idsFila) {
                await _banco.customStatement(
                  'UPDATE fila_sync SET tentativas = tentativas + 1, ultimo_erro = ? WHERE id = ?',
                  [tipoErro, idFila],
                );
              }
            }
          });
          return ResultadoCicloSync(
            lotesEnviados: lotesEnviados,
            itensSincronizados: itensSincronizados,
            conflitosDetectados: conflitosDetectados,
            exclusoesRemotasAplicadas: exclusoesRemotasAplicadas,
            falhou: true,
          );
        }

        // 5a. COMMIT OK: atualiza versaoRemota + estadoSync e remove da fila.
        await _banco.transaction(() async {
          for (final item in paraEnviar) {
            await _banco.customStatement(
              'UPDATE ${item.grupo.tabela} '
              'SET versao_remota = ?, estado_sync = ? '
              'WHERE id = ?',
              [item.escrita.versao, EstadoSync.sincronizado.name, item.grupo.registroId],
            );
            await _removerIdsFila(item.grupo.idsFila);
          }
        });
        lotesEnviados++;
        itensSincronizados += paraEnviar.length;
      }
    } finally {
      await _remoto.desligarRede();
    }

    return ResultadoCicloSync(
      lotesEnviados: lotesEnviados,
      itensSincronizados: itensSincronizados,
      conflitosDetectados: conflitosDetectados,
      exclusoesRemotasAplicadas: exclusoesRemotasAplicadas,
    );
  }

  Future<_RegistroLocal?> _lerRegistroLocal(String tabela, String id) async {
    final linha = await _banco.customSelect(
      'SELECT * FROM $tabela WHERE id = ?',
      variables: [Variable.withString(id)],
    ).getSingleOrNull();
    if (linha == null) return null;

    final dados = <String, Object?>{
      for (final entry in linha.data.entries)
        if (!_colunasControle.contains(entry.key)) entry.key: entry.value,
    };

    return _RegistroLocal(
      versao: linha.read<int>('versao'),
      versaoRemota: linha.readNullable<int>('versao_remota'),
      excluido: linha.read<int>('excluido') != 0,
      dados: dados,
    );
  }

  Future<void> _removerIdsFila(List<int> ids) async {
    if (ids.isEmpty) return;
    await (_banco.delete(_banco.itensFilaSync)..where((f) => f.id.isIn(ids))).go();
  }

  OperacaoSync _parseOperacao(String valor) =>
      valor == OperacaoSync.excluir.name ? OperacaoSync.excluir : OperacaoSync.upsert;
}

final class _ItemAgrupado {
  _ItemAgrupado({
    required this.tabela,
    required this.registroId,
    required this.operacao,
    required this.idsFila,
  });

  final String tabela;
  final String registroId;
  OperacaoSync operacao;
  final List<int> idsFila;
}

final class _ItemParaEnviar {
  const _ItemParaEnviar({required this.grupo, required this.escrita});

  final _ItemAgrupado grupo;
  final EscritaLote escrita;
}

final class _RegistroLocal {
  const _RegistroLocal({
    required this.versao,
    required this.versaoRemota,
    required this.excluido,
    required this.dados,
  });

  final int versao;
  final int? versaoRemota;
  final bool excluido;
  final Map<String, Object?> dados;
}
