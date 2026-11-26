import '../banco/daos/config_dao.dart';
import '../banco/database.dart';
import 'fila_sync.dart';

/// Implementação ativa da fila de sincronização (`dados-e-sync.md` → Contrato
/// da fila; P5-1.4).
///
/// Quando a cópia remota está desligada (`copiaRemotaAtiva != 'true'`), todos
/// os registros ficam como [EstadoSync.local] e [enfileirar] não grava nada.
/// Quando está ligada, [enfileirar] grava na tabela `fila_sync` dentro da
/// mesma transação do drift aberta pelo repositório chamador.
final class FilaSyncAtiva implements FilaSync {
  FilaSyncAtiva(this._banco, {DateTime Function()? agora})
      : _agora = agora ?? DateTime.now;

  final BancoLocal _banco;
  final DateTime Function() _agora;

  Future<bool> _copiaAtiva() async =>
      await _banco.configDao.ler(ChavesConfig.copiaRemotaAtiva) == 'true';

  @override
  Future<EstadoSync> estadoInicial() async =>
      await _copiaAtiva() ? EstadoSync.pendente : EstadoSync.local;

  @override
  Future<void> enfileirar(String tabela, String registroId, OperacaoSync op) async {
    if (!await _copiaAtiva()) return;
    await _banco.into(_banco.itensFilaSync).insert(
          ItensFilaSyncCompanion.insert(
            tabela: tabela,
            registroId: registroId,
            operacao: op.name,
            criadoEm: _agora(),
          ),
        );
  }
}
