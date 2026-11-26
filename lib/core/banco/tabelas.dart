import 'package:drift/drift.dart';

/// Tabelas locais (`docs/specs/comum/dados-e-sync.md` → Tabelas locais).
///
/// **Ninguém edita este esquema fora do P1 na Fase 0.** Depois disso, toda
/// mudança precisa de migração (`schemaVersion` + `MigrationStrategy` em
/// `database.dart`) e de acordo com o grupo.
///
/// Nomes no SQLite: o drift converte para snake_case (`petId` → `pet_id`,
/// `Pesagens` → `pesagens`). As classes de linha terminam em `Linha` para
/// não colidir com as entidades do domínio (`Pet`, `Refeicao`…).

/// Colunas de controle de toda tabela sincronizável.
mixin ColunasControle on Table {
  /// UUID v4 gerado no aparelho e reutilizado como ID do documento no
  /// Firestore.
  TextColumn get id => text()();
  DateTimeColumn get criadoEm => dateTime()();
  DateTimeColumn get atualizadoEm => dateTime()();

  /// Começa em 1 e soma 1 a cada alteração local.
  IntColumn get versao => integer().withDefault(const Constant(1))();

  /// Última versão confirmada no Firestore (`null` = nunca enviado).
  IntColumn get versaoRemota => integer().nullable()();

  /// `local` (cópia desligada), `pendente`, `sincronizado`, `falha`,
  /// `conflito`.
  TextColumn get estadoSync => text().withDefault(const Constant('local'))();

  /// Lápide. As consultas da UI sempre filtram `excluido = false`.
  BoolColumn get excluido => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

// ---------------------------------------------------------------- domínio

/// P1. `especie`: `cao`/`gato`; `sexo`: `macho`/`femea`;
/// `nivelAtividade`: `baixa`/`moderada`/`alta`.
@DataClassName('PetLinha')
class Pets extends Table with ColunasControle {
  TextColumn get nome => text()();
  TextColumn get especie => text()();
  TextColumn get sexo => text()();
  IntColumn get idadeMeses => integer()();
  DateTimeColumn get idadeInformadaEm => dateTime()();
  BoolColumn get castrado => boolean()();
  TextColumn get nivelAtividade => text()();
  TextColumn get fotoArquivo => text().nullable()();
}

/// P2. `arquivado`: excluído do cadastro, preservado para os registros
/// antigos.
///
/// `tipo` (P-32, versão 2): `racao` usa `densidadeKcalPor100g` e
/// `porcaoPadraoG`; `petisco` usa `kcalPorUnidade` e `unidadesHabituais`.
/// Os campos do outro tipo ficam vazios.
@DataClassName('AlimentoLinha')
@TableIndex(name: 'idx_alimentos_pet', columns: {#petId})
class Alimentos extends Table with ColunasControle {
  TextColumn get petId => text().references(Pets, #id, onDelete: KeyAction.cascade)();
  TextColumn get nome => text()();
  TextColumn get tipo => text().withDefault(const Constant('racao'))();
  RealColumn get densidadeKcalPor100g => real().nullable()();
  RealColumn get porcaoPadraoG => real().nullable()();
  RealColumn get kcalPorUnidade => real().nullable()();
  IntColumn get unidadesHabituais => integer().nullable()();
  BoolColumn get arquivado => boolean().withDefault(const Constant(false))();
}

/// P2. Nome e densidade são **cópias** do alimento na ocasião (RF04).
@DataClassName('RefeicaoLinha')
@TableIndex(name: 'idx_refeicoes_pet_data', columns: {#petId, #dataHora})
class Refeicoes extends Table with ColunasControle {
  TextColumn get petId => text().references(Pets, #id, onDelete: KeyAction.cascade)();
  TextColumn get alimentoId => text().nullable()();
  TextColumn get alimentoNome => text()();
  RealColumn get densidadeKcalPor100g => real()();
  RealColumn get quantidadeG => real()();
  RealColumn get energiaKcal => real()();
  DateTimeColumn get dataHora => dateTime()();
}

/// P2. Petiscos e extras. Com petisco cadastrado (P-32, versão 2),
/// `alimentoId` aponta para ele e `unidades` guarda a quantidade; descrição e
/// energia são **cópias** (RF04).
@DataClassName('ExtraLinha')
@TableIndex(name: 'idx_extras_pet_data', columns: {#petId, #dataHora})
class Extras extends Table with ColunasControle {
  TextColumn get petId => text().references(Pets, #id, onDelete: KeyAction.cascade)();
  TextColumn get alimentoId => text().nullable()();
  TextColumn get descricao => text()();
  RealColumn get quantidadeG => real().nullable()();
  IntColumn get unidades => integer().nullable()();
  RealColumn get energiaKcal => real()();
  DateTimeColumn get dataHora => dateTime()();
}

/// P3. `tipo`: `passeio`/`brincadeira`.
@DataClassName('AtividadeLinha')
@TableIndex(name: 'idx_atividades_pet_data', columns: {#petId, #dataHora})
class Atividades extends Table with ColunasControle {
  TextColumn get petId => text().references(Pets, #id, onDelete: KeyAction.cascade)();
  TextColumn get tipo => text()();
  IntColumn get duracaoMin => integer()();
  DateTimeColumn get dataHora => dateTime()();
}

/// P3. `hora`: minutos desde 00:00; `tipo`: `refeicao`/`pesagem`/`atividade`;
/// `notificacaoId`: único e estável (id da notificação agendada).
@DataClassName('LembreteLinha')
@TableIndex(name: 'idx_lembretes_pet', columns: {#petId})
class Lembretes extends Table with ColunasControle {
  TextColumn get petId => text().references(Pets, #id, onDelete: KeyAction.cascade)();
  IntColumn get hora => integer()();
  TextColumn get tipo => text()();
  BoolColumn get ativo => boolean().withDefault(const Constant(true))();
  IntColumn get notificacaoId => integer().unique()();
}

/// P4. A primeira pesagem do pet é o "peso inicial" (U2-06). `conferida`:
/// o tutor manteve um valor suspeito (R06).
@DataClassName('PesagemLinha')
@TableIndex(name: 'idx_pesagens_pet_data', columns: {#petId, #dataHora})
class Pesagens extends Table with ColunasControle {
  TextColumn get petId => text().references(Pets, #id, onDelete: KeyAction.cascade)();
  RealColumn get pesoKg => real()();
  DateTimeColumn get dataHora => dateTime()();
  BoolColumn get conferida => boolean().withDefault(const Constant(false))();
}

/// P4. `ecc`: 1–9 (WSAVA) ou nulo; uma linha vigente por pet.
@DataClassName('ReferenciaLinha')
@TableIndex(name: 'idx_referencias_pet', columns: {#petId})
class Referencias extends Table with ColunasControle {
  TextColumn get petId => text().references(Pets, #id, onDelete: KeyAction.cascade)();
  IntColumn get ecc => integer().nullable()();
  RealColumn get objetivoKg => real().nullable()();
  TextColumn get origem => text()();
  DateTimeColumn get data => dateTime()();
}

// ---------------------------------------------------------------- controle (P5)

/// Fila de sincronização. `operacao`: `upsert`/`excluir`.
///
/// A classe se chama `ItensFilaSync` (e não `FilaSync`) para não colidir com
/// a interface `FilaSync` de `core/sync/fila_sync.dart`; no SQLite a tabela
/// continua `fila_sync`. Acesso: `banco.itensFilaSync`.
@DataClassName('FilaSyncLinha')
@TableIndex(name: 'idx_fila_sync_registro', columns: {#tabela, #registroId})
class ItensFilaSync extends Table {
  @override
  String get tableName => 'fila_sync';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get tabela => text()();
  TextColumn get registroId => text()();
  TextColumn get operacao => text()();
  DateTimeColumn get criadoEm => dateTime()();
  IntColumn get tentativas => integer().withDefault(const Constant(0))();
  TextColumn get ultimoErro => text().nullable()();
}

/// Conflitos detectados na sincronização (tela 17). Um por registro.
@DataClassName('ConflitoLinha')
class Conflitos extends Table {
  TextColumn get tabela => text()();
  TextColumn get registroId => text()();

  /// Documento remoto em JSON.
  TextColumn get dadosRemotos => text()();
  DateTimeColumn get detectadoEm => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {tabela, registroId};
}

/// Chave/valor (`ChavesConfig`). **Não é apagada** pela exclusão integral.
@DataClassName('ConfigLinha')
class Config extends Table {
  TextColumn get chave => text()();
  TextColumn get valor => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {chave};
}
