import 'package:drift/drift.dart';

import '../database.dart';

part 'config_dao.g.dart';

/// Chaves da tabela `config` (`dados-e-sync.md` → Tabelas de controle).
abstract final class ChavesConfig {
  static const copiaRemotaAtiva = 'copiaRemotaAtiva';
  static const uid = 'uid';
  static const ultimoPull = 'ultimoPull';
  static const exclusaoRemotaPendente = 'exclusaoRemotaPendente';
  static const dispositivoId = 'dispositivoId';
  static const petAtualId = 'petAtualId';

  /// JSON: id da sugestão → data em que o tutor tocou "Agora não".
  static const sugestoesAdiadas = 'sugestoesAdiadas';
}

/// Acesso chave/valor à tabela `config`.
@DriftAccessor(tables: [Config])
class ConfigDao extends DatabaseAccessor<BancoLocal> with _$ConfigDaoMixin {
  ConfigDao(super.attachedDatabase);

  SimpleSelectStatement<$ConfigTable, ConfigLinha> _porChave(String chave) =>
      select(config)..where((c) => c.chave.equals(chave));

  /// Emite o valor atual e cada mudança (stream reativo do drift).
  Stream<String?> observar(String chave) =>
      _porChave(chave).watchSingleOrNull().map((linha) => linha?.valor);

  Future<String?> ler(String chave) async => (await _porChave(chave).getSingleOrNull())?.valor;

  /// Grava o valor; `null` remove a chave.
  Future<void> gravar(String chave, String? valor) async {
    if (valor == null) {
      await (delete(config)..where((c) => c.chave.equals(chave))).go();
      return;
    }
    await into(config).insertOnConflictUpdate(
      ConfigCompanion.insert(chave: chave, valor: Value(valor)),
    );
  }
}
