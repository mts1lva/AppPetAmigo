import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/config_dao.dart';
import 'tabelas.dart';

export 'tabelas.dart';

part 'database.g.dart';

/// Banco local (SQLite via drift): **a fonte de verdade do app**
/// (offline-first). O Firestore é só a cópia remota opcional.
///
/// Gere o código depois de mudar tabelas ou DAOs:
/// `dart run build_runner build`.
///
/// Chaves estrangeiras ligadas (`PRAGMA foreign_keys = ON`): todo registro
/// precisa de um `petId` existente, e apagar um pet de verdade (limpeza da
/// lápide) apaga os registros dele. No pull da cópia remota, os pets vêm
/// antes das outras coleções.
@DriftDatabase(
  tables: [
    Pets,
    Alimentos,
    Refeicoes,
    Extras,
    Atividades,
    Lembretes,
    Pesagens,
    Referencias,
    FilaSync,
    Conflitos,
    Config,
  ],
  daos: [ConfigDao],
)
class BancoLocal extends _$BancoLocal {
  BancoLocal(super.executor);

  /// Banco do app, em `getApplicationDocumentsDirectory()` (área privada).
  factory BancoLocal.abrir() => BancoLocal(driftDatabase(name: 'petamigo'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        beforeOpen: (detalhes) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
