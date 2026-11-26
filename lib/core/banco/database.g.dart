// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $PetsTable extends Pets with TableInfo<$PetsTable, PetLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versaoMeta = const VerificationMeta('versao');
  @override
  late final GeneratedColumn<int> versao = GeneratedColumn<int>(
    'versao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _versaoRemotaMeta = const VerificationMeta(
    'versaoRemota',
  );
  @override
  late final GeneratedColumn<int> versaoRemota = GeneratedColumn<int>(
    'versao_remota',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _excluidoMeta = const VerificationMeta(
    'excluido',
  );
  @override
  late final GeneratedColumn<bool> excluido = GeneratedColumn<bool>(
    'excluido',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("excluido" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _especieMeta = const VerificationMeta(
    'especie',
  );
  @override
  late final GeneratedColumn<String> especie = GeneratedColumn<String>(
    'especie',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sexoMeta = const VerificationMeta('sexo');
  @override
  late final GeneratedColumn<String> sexo = GeneratedColumn<String>(
    'sexo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idadeMesesMeta = const VerificationMeta(
    'idadeMeses',
  );
  @override
  late final GeneratedColumn<int> idadeMeses = GeneratedColumn<int>(
    'idade_meses',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idadeInformadaEmMeta = const VerificationMeta(
    'idadeInformadaEm',
  );
  @override
  late final GeneratedColumn<DateTime> idadeInformadaEm =
      GeneratedColumn<DateTime>(
        'idade_informada_em',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _castradoMeta = const VerificationMeta(
    'castrado',
  );
  @override
  late final GeneratedColumn<bool> castrado = GeneratedColumn<bool>(
    'castrado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("castrado" IN (0, 1))',
    ),
  );
  static const VerificationMeta _nivelAtividadeMeta = const VerificationMeta(
    'nivelAtividade',
  );
  @override
  late final GeneratedColumn<String> nivelAtividade = GeneratedColumn<String>(
    'nivel_atividade',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fotoArquivoMeta = const VerificationMeta(
    'fotoArquivo',
  );
  @override
  late final GeneratedColumn<String> fotoArquivo = GeneratedColumn<String>(
    'foto_arquivo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    nome,
    especie,
    sexo,
    idadeMeses,
    idadeInformadaEm,
    castrado,
    nivelAtividade,
    fotoArquivo,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pets';
  @override
  VerificationContext validateIntegrity(
    Insertable<PetLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('versao')) {
      context.handle(
        _versaoMeta,
        versao.isAcceptableOrUnknown(data['versao']!, _versaoMeta),
      );
    }
    if (data.containsKey('versao_remota')) {
      context.handle(
        _versaoRemotaMeta,
        versaoRemota.isAcceptableOrUnknown(
          data['versao_remota']!,
          _versaoRemotaMeta,
        ),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('excluido')) {
      context.handle(
        _excluidoMeta,
        excluido.isAcceptableOrUnknown(data['excluido']!, _excluidoMeta),
      );
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('especie')) {
      context.handle(
        _especieMeta,
        especie.isAcceptableOrUnknown(data['especie']!, _especieMeta),
      );
    } else if (isInserting) {
      context.missing(_especieMeta);
    }
    if (data.containsKey('sexo')) {
      context.handle(
        _sexoMeta,
        sexo.isAcceptableOrUnknown(data['sexo']!, _sexoMeta),
      );
    } else if (isInserting) {
      context.missing(_sexoMeta);
    }
    if (data.containsKey('idade_meses')) {
      context.handle(
        _idadeMesesMeta,
        idadeMeses.isAcceptableOrUnknown(data['idade_meses']!, _idadeMesesMeta),
      );
    } else if (isInserting) {
      context.missing(_idadeMesesMeta);
    }
    if (data.containsKey('idade_informada_em')) {
      context.handle(
        _idadeInformadaEmMeta,
        idadeInformadaEm.isAcceptableOrUnknown(
          data['idade_informada_em']!,
          _idadeInformadaEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_idadeInformadaEmMeta);
    }
    if (data.containsKey('castrado')) {
      context.handle(
        _castradoMeta,
        castrado.isAcceptableOrUnknown(data['castrado']!, _castradoMeta),
      );
    } else if (isInserting) {
      context.missing(_castradoMeta);
    }
    if (data.containsKey('nivel_atividade')) {
      context.handle(
        _nivelAtividadeMeta,
        nivelAtividade.isAcceptableOrUnknown(
          data['nivel_atividade']!,
          _nivelAtividadeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nivelAtividadeMeta);
    }
    if (data.containsKey('foto_arquivo')) {
      context.handle(
        _fotoArquivoMeta,
        fotoArquivo.isAcceptableOrUnknown(
          data['foto_arquivo']!,
          _fotoArquivoMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PetLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PetLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      versao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao'],
      )!,
      versaoRemota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao_remota'],
      ),
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      excluido: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}excluido'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      especie: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}especie'],
      )!,
      sexo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sexo'],
      )!,
      idadeMeses: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}idade_meses'],
      )!,
      idadeInformadaEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}idade_informada_em'],
      )!,
      castrado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}castrado'],
      )!,
      nivelAtividade: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nivel_atividade'],
      )!,
      fotoArquivo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}foto_arquivo'],
      ),
    );
  }

  @override
  $PetsTable createAlias(String alias) {
    return $PetsTable(attachedDatabase, alias);
  }
}

class PetLinha extends DataClass implements Insertable<PetLinha> {
  /// UUID v4 gerado no aparelho e reutilizado como ID do documento no
  /// Firestore.
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// Começa em 1 e soma 1 a cada alteração local.
  final int versao;

  /// Última versão confirmada no Firestore (`null` = nunca enviado).
  final int? versaoRemota;

  /// `local` (cópia desligada), `pendente`, `sincronizado`, `falha`,
  /// `conflito`.
  final String estadoSync;

  /// Lápide. As consultas da UI sempre filtram `excluido = false`.
  final bool excluido;
  final String nome;
  final String especie;
  final String sexo;
  final int idadeMeses;
  final DateTime idadeInformadaEm;
  final bool castrado;
  final String nivelAtividade;
  final String? fotoArquivo;
  const PetLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.versao,
    this.versaoRemota,
    required this.estadoSync,
    required this.excluido,
    required this.nome,
    required this.especie,
    required this.sexo,
    required this.idadeMeses,
    required this.idadeInformadaEm,
    required this.castrado,
    required this.nivelAtividade,
    this.fotoArquivo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['versao'] = Variable<int>(versao);
    if (!nullToAbsent || versaoRemota != null) {
      map['versao_remota'] = Variable<int>(versaoRemota);
    }
    map['estado_sync'] = Variable<String>(estadoSync);
    map['excluido'] = Variable<bool>(excluido);
    map['nome'] = Variable<String>(nome);
    map['especie'] = Variable<String>(especie);
    map['sexo'] = Variable<String>(sexo);
    map['idade_meses'] = Variable<int>(idadeMeses);
    map['idade_informada_em'] = Variable<DateTime>(idadeInformadaEm);
    map['castrado'] = Variable<bool>(castrado);
    map['nivel_atividade'] = Variable<String>(nivelAtividade);
    if (!nullToAbsent || fotoArquivo != null) {
      map['foto_arquivo'] = Variable<String>(fotoArquivo);
    }
    return map;
  }

  PetsCompanion toCompanion(bool nullToAbsent) {
    return PetsCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      versao: Value(versao),
      versaoRemota: versaoRemota == null && nullToAbsent
          ? const Value.absent()
          : Value(versaoRemota),
      estadoSync: Value(estadoSync),
      excluido: Value(excluido),
      nome: Value(nome),
      especie: Value(especie),
      sexo: Value(sexo),
      idadeMeses: Value(idadeMeses),
      idadeInformadaEm: Value(idadeInformadaEm),
      castrado: Value(castrado),
      nivelAtividade: Value(nivelAtividade),
      fotoArquivo: fotoArquivo == null && nullToAbsent
          ? const Value.absent()
          : Value(fotoArquivo),
    );
  }

  factory PetLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PetLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      versao: serializer.fromJson<int>(json['versao']),
      versaoRemota: serializer.fromJson<int?>(json['versaoRemota']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      excluido: serializer.fromJson<bool>(json['excluido']),
      nome: serializer.fromJson<String>(json['nome']),
      especie: serializer.fromJson<String>(json['especie']),
      sexo: serializer.fromJson<String>(json['sexo']),
      idadeMeses: serializer.fromJson<int>(json['idadeMeses']),
      idadeInformadaEm: serializer.fromJson<DateTime>(json['idadeInformadaEm']),
      castrado: serializer.fromJson<bool>(json['castrado']),
      nivelAtividade: serializer.fromJson<String>(json['nivelAtividade']),
      fotoArquivo: serializer.fromJson<String?>(json['fotoArquivo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'versao': serializer.toJson<int>(versao),
      'versaoRemota': serializer.toJson<int?>(versaoRemota),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'excluido': serializer.toJson<bool>(excluido),
      'nome': serializer.toJson<String>(nome),
      'especie': serializer.toJson<String>(especie),
      'sexo': serializer.toJson<String>(sexo),
      'idadeMeses': serializer.toJson<int>(idadeMeses),
      'idadeInformadaEm': serializer.toJson<DateTime>(idadeInformadaEm),
      'castrado': serializer.toJson<bool>(castrado),
      'nivelAtividade': serializer.toJson<String>(nivelAtividade),
      'fotoArquivo': serializer.toJson<String?>(fotoArquivo),
    };
  }

  PetLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? versao,
    Value<int?> versaoRemota = const Value.absent(),
    String? estadoSync,
    bool? excluido,
    String? nome,
    String? especie,
    String? sexo,
    int? idadeMeses,
    DateTime? idadeInformadaEm,
    bool? castrado,
    String? nivelAtividade,
    Value<String?> fotoArquivo = const Value.absent(),
  }) => PetLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    versao: versao ?? this.versao,
    versaoRemota: versaoRemota.present ? versaoRemota.value : this.versaoRemota,
    estadoSync: estadoSync ?? this.estadoSync,
    excluido: excluido ?? this.excluido,
    nome: nome ?? this.nome,
    especie: especie ?? this.especie,
    sexo: sexo ?? this.sexo,
    idadeMeses: idadeMeses ?? this.idadeMeses,
    idadeInformadaEm: idadeInformadaEm ?? this.idadeInformadaEm,
    castrado: castrado ?? this.castrado,
    nivelAtividade: nivelAtividade ?? this.nivelAtividade,
    fotoArquivo: fotoArquivo.present ? fotoArquivo.value : this.fotoArquivo,
  );
  PetLinha copyWithCompanion(PetsCompanion data) {
    return PetLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      versao: data.versao.present ? data.versao.value : this.versao,
      versaoRemota: data.versaoRemota.present
          ? data.versaoRemota.value
          : this.versaoRemota,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      excluido: data.excluido.present ? data.excluido.value : this.excluido,
      nome: data.nome.present ? data.nome.value : this.nome,
      especie: data.especie.present ? data.especie.value : this.especie,
      sexo: data.sexo.present ? data.sexo.value : this.sexo,
      idadeMeses: data.idadeMeses.present
          ? data.idadeMeses.value
          : this.idadeMeses,
      idadeInformadaEm: data.idadeInformadaEm.present
          ? data.idadeInformadaEm.value
          : this.idadeInformadaEm,
      castrado: data.castrado.present ? data.castrado.value : this.castrado,
      nivelAtividade: data.nivelAtividade.present
          ? data.nivelAtividade.value
          : this.nivelAtividade,
      fotoArquivo: data.fotoArquivo.present
          ? data.fotoArquivo.value
          : this.fotoArquivo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PetLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('nome: $nome, ')
          ..write('especie: $especie, ')
          ..write('sexo: $sexo, ')
          ..write('idadeMeses: $idadeMeses, ')
          ..write('idadeInformadaEm: $idadeInformadaEm, ')
          ..write('castrado: $castrado, ')
          ..write('nivelAtividade: $nivelAtividade, ')
          ..write('fotoArquivo: $fotoArquivo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    nome,
    especie,
    sexo,
    idadeMeses,
    idadeInformadaEm,
    castrado,
    nivelAtividade,
    fotoArquivo,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PetLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.versao == this.versao &&
          other.versaoRemota == this.versaoRemota &&
          other.estadoSync == this.estadoSync &&
          other.excluido == this.excluido &&
          other.nome == this.nome &&
          other.especie == this.especie &&
          other.sexo == this.sexo &&
          other.idadeMeses == this.idadeMeses &&
          other.idadeInformadaEm == this.idadeInformadaEm &&
          other.castrado == this.castrado &&
          other.nivelAtividade == this.nivelAtividade &&
          other.fotoArquivo == this.fotoArquivo);
}

class PetsCompanion extends UpdateCompanion<PetLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> versao;
  final Value<int?> versaoRemota;
  final Value<String> estadoSync;
  final Value<bool> excluido;
  final Value<String> nome;
  final Value<String> especie;
  final Value<String> sexo;
  final Value<int> idadeMeses;
  final Value<DateTime> idadeInformadaEm;
  final Value<bool> castrado;
  final Value<String> nivelAtividade;
  final Value<String?> fotoArquivo;
  final Value<int> rowid;
  const PetsCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    this.nome = const Value.absent(),
    this.especie = const Value.absent(),
    this.sexo = const Value.absent(),
    this.idadeMeses = const Value.absent(),
    this.idadeInformadaEm = const Value.absent(),
    this.castrado = const Value.absent(),
    this.nivelAtividade = const Value.absent(),
    this.fotoArquivo = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PetsCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    required String nome,
    required String especie,
    required String sexo,
    required int idadeMeses,
    required DateTime idadeInformadaEm,
    required bool castrado,
    required String nivelAtividade,
    this.fotoArquivo = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       nome = Value(nome),
       especie = Value(especie),
       sexo = Value(sexo),
       idadeMeses = Value(idadeMeses),
       idadeInformadaEm = Value(idadeInformadaEm),
       castrado = Value(castrado),
       nivelAtividade = Value(nivelAtividade);
  static Insertable<PetLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? versao,
    Expression<int>? versaoRemota,
    Expression<String>? estadoSync,
    Expression<bool>? excluido,
    Expression<String>? nome,
    Expression<String>? especie,
    Expression<String>? sexo,
    Expression<int>? idadeMeses,
    Expression<DateTime>? idadeInformadaEm,
    Expression<bool>? castrado,
    Expression<String>? nivelAtividade,
    Expression<String>? fotoArquivo,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (versao != null) 'versao': versao,
      if (versaoRemota != null) 'versao_remota': versaoRemota,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (excluido != null) 'excluido': excluido,
      if (nome != null) 'nome': nome,
      if (especie != null) 'especie': especie,
      if (sexo != null) 'sexo': sexo,
      if (idadeMeses != null) 'idade_meses': idadeMeses,
      if (idadeInformadaEm != null) 'idade_informada_em': idadeInformadaEm,
      if (castrado != null) 'castrado': castrado,
      if (nivelAtividade != null) 'nivel_atividade': nivelAtividade,
      if (fotoArquivo != null) 'foto_arquivo': fotoArquivo,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PetsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? versao,
    Value<int?>? versaoRemota,
    Value<String>? estadoSync,
    Value<bool>? excluido,
    Value<String>? nome,
    Value<String>? especie,
    Value<String>? sexo,
    Value<int>? idadeMeses,
    Value<DateTime>? idadeInformadaEm,
    Value<bool>? castrado,
    Value<String>? nivelAtividade,
    Value<String?>? fotoArquivo,
    Value<int>? rowid,
  }) {
    return PetsCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      versao: versao ?? this.versao,
      versaoRemota: versaoRemota ?? this.versaoRemota,
      estadoSync: estadoSync ?? this.estadoSync,
      excluido: excluido ?? this.excluido,
      nome: nome ?? this.nome,
      especie: especie ?? this.especie,
      sexo: sexo ?? this.sexo,
      idadeMeses: idadeMeses ?? this.idadeMeses,
      idadeInformadaEm: idadeInformadaEm ?? this.idadeInformadaEm,
      castrado: castrado ?? this.castrado,
      nivelAtividade: nivelAtividade ?? this.nivelAtividade,
      fotoArquivo: fotoArquivo ?? this.fotoArquivo,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (versao.present) {
      map['versao'] = Variable<int>(versao.value);
    }
    if (versaoRemota.present) {
      map['versao_remota'] = Variable<int>(versaoRemota.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (excluido.present) {
      map['excluido'] = Variable<bool>(excluido.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (especie.present) {
      map['especie'] = Variable<String>(especie.value);
    }
    if (sexo.present) {
      map['sexo'] = Variable<String>(sexo.value);
    }
    if (idadeMeses.present) {
      map['idade_meses'] = Variable<int>(idadeMeses.value);
    }
    if (idadeInformadaEm.present) {
      map['idade_informada_em'] = Variable<DateTime>(idadeInformadaEm.value);
    }
    if (castrado.present) {
      map['castrado'] = Variable<bool>(castrado.value);
    }
    if (nivelAtividade.present) {
      map['nivel_atividade'] = Variable<String>(nivelAtividade.value);
    }
    if (fotoArquivo.present) {
      map['foto_arquivo'] = Variable<String>(fotoArquivo.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PetsCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('nome: $nome, ')
          ..write('especie: $especie, ')
          ..write('sexo: $sexo, ')
          ..write('idadeMeses: $idadeMeses, ')
          ..write('idadeInformadaEm: $idadeInformadaEm, ')
          ..write('castrado: $castrado, ')
          ..write('nivelAtividade: $nivelAtividade, ')
          ..write('fotoArquivo: $fotoArquivo, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AlimentosTable extends Alimentos
    with TableInfo<$AlimentosTable, AlimentoLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AlimentosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versaoMeta = const VerificationMeta('versao');
  @override
  late final GeneratedColumn<int> versao = GeneratedColumn<int>(
    'versao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _versaoRemotaMeta = const VerificationMeta(
    'versaoRemota',
  );
  @override
  late final GeneratedColumn<int> versaoRemota = GeneratedColumn<int>(
    'versao_remota',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _excluidoMeta = const VerificationMeta(
    'excluido',
  );
  @override
  late final GeneratedColumn<bool> excluido = GeneratedColumn<bool>(
    'excluido',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("excluido" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nomeMeta = const VerificationMeta('nome');
  @override
  late final GeneratedColumn<String> nome = GeneratedColumn<String>(
    'nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('racao'),
  );
  static const VerificationMeta _densidadeKcalPor100gMeta =
      const VerificationMeta('densidadeKcalPor100g');
  @override
  late final GeneratedColumn<double> densidadeKcalPor100g =
      GeneratedColumn<double>(
        'densidade_kcal_por100g',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _porcaoPadraoGMeta = const VerificationMeta(
    'porcaoPadraoG',
  );
  @override
  late final GeneratedColumn<double> porcaoPadraoG = GeneratedColumn<double>(
    'porcao_padrao_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kcalPorUnidadeMeta = const VerificationMeta(
    'kcalPorUnidade',
  );
  @override
  late final GeneratedColumn<double> kcalPorUnidade = GeneratedColumn<double>(
    'kcal_por_unidade',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unidadesHabituaisMeta = const VerificationMeta(
    'unidadesHabituais',
  );
  @override
  late final GeneratedColumn<int> unidadesHabituais = GeneratedColumn<int>(
    'unidades_habituais',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _arquivadoMeta = const VerificationMeta(
    'arquivado',
  );
  @override
  late final GeneratedColumn<bool> arquivado = GeneratedColumn<bool>(
    'arquivado',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("arquivado" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    nome,
    tipo,
    densidadeKcalPor100g,
    porcaoPadraoG,
    kcalPorUnidade,
    unidadesHabituais,
    arquivado,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'alimentos';
  @override
  VerificationContext validateIntegrity(
    Insertable<AlimentoLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('versao')) {
      context.handle(
        _versaoMeta,
        versao.isAcceptableOrUnknown(data['versao']!, _versaoMeta),
      );
    }
    if (data.containsKey('versao_remota')) {
      context.handle(
        _versaoRemotaMeta,
        versaoRemota.isAcceptableOrUnknown(
          data['versao_remota']!,
          _versaoRemotaMeta,
        ),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('excluido')) {
      context.handle(
        _excluidoMeta,
        excluido.isAcceptableOrUnknown(data['excluido']!, _excluidoMeta),
      );
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('nome')) {
      context.handle(
        _nomeMeta,
        nome.isAcceptableOrUnknown(data['nome']!, _nomeMeta),
      );
    } else if (isInserting) {
      context.missing(_nomeMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    }
    if (data.containsKey('densidade_kcal_por100g')) {
      context.handle(
        _densidadeKcalPor100gMeta,
        densidadeKcalPor100g.isAcceptableOrUnknown(
          data['densidade_kcal_por100g']!,
          _densidadeKcalPor100gMeta,
        ),
      );
    }
    if (data.containsKey('porcao_padrao_g')) {
      context.handle(
        _porcaoPadraoGMeta,
        porcaoPadraoG.isAcceptableOrUnknown(
          data['porcao_padrao_g']!,
          _porcaoPadraoGMeta,
        ),
      );
    }
    if (data.containsKey('kcal_por_unidade')) {
      context.handle(
        _kcalPorUnidadeMeta,
        kcalPorUnidade.isAcceptableOrUnknown(
          data['kcal_por_unidade']!,
          _kcalPorUnidadeMeta,
        ),
      );
    }
    if (data.containsKey('unidades_habituais')) {
      context.handle(
        _unidadesHabituaisMeta,
        unidadesHabituais.isAcceptableOrUnknown(
          data['unidades_habituais']!,
          _unidadesHabituaisMeta,
        ),
      );
    }
    if (data.containsKey('arquivado')) {
      context.handle(
        _arquivadoMeta,
        arquivado.isAcceptableOrUnknown(data['arquivado']!, _arquivadoMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AlimentoLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AlimentoLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      versao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao'],
      )!,
      versaoRemota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao_remota'],
      ),
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      excluido: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}excluido'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      nome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nome'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      densidadeKcalPor100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}densidade_kcal_por100g'],
      ),
      porcaoPadraoG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}porcao_padrao_g'],
      ),
      kcalPorUnidade: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_por_unidade'],
      ),
      unidadesHabituais: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unidades_habituais'],
      ),
      arquivado: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}arquivado'],
      )!,
    );
  }

  @override
  $AlimentosTable createAlias(String alias) {
    return $AlimentosTable(attachedDatabase, alias);
  }
}

class AlimentoLinha extends DataClass implements Insertable<AlimentoLinha> {
  /// UUID v4 gerado no aparelho e reutilizado como ID do documento no
  /// Firestore.
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// Começa em 1 e soma 1 a cada alteração local.
  final int versao;

  /// Última versão confirmada no Firestore (`null` = nunca enviado).
  final int? versaoRemota;

  /// `local` (cópia desligada), `pendente`, `sincronizado`, `falha`,
  /// `conflito`.
  final String estadoSync;

  /// Lápide. As consultas da UI sempre filtram `excluido = false`.
  final bool excluido;
  final String petId;
  final String nome;
  final String tipo;
  final double? densidadeKcalPor100g;
  final double? porcaoPadraoG;
  final double? kcalPorUnidade;
  final int? unidadesHabituais;
  final bool arquivado;
  const AlimentoLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.versao,
    this.versaoRemota,
    required this.estadoSync,
    required this.excluido,
    required this.petId,
    required this.nome,
    required this.tipo,
    this.densidadeKcalPor100g,
    this.porcaoPadraoG,
    this.kcalPorUnidade,
    this.unidadesHabituais,
    required this.arquivado,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['versao'] = Variable<int>(versao);
    if (!nullToAbsent || versaoRemota != null) {
      map['versao_remota'] = Variable<int>(versaoRemota);
    }
    map['estado_sync'] = Variable<String>(estadoSync);
    map['excluido'] = Variable<bool>(excluido);
    map['pet_id'] = Variable<String>(petId);
    map['nome'] = Variable<String>(nome);
    map['tipo'] = Variable<String>(tipo);
    if (!nullToAbsent || densidadeKcalPor100g != null) {
      map['densidade_kcal_por100g'] = Variable<double>(densidadeKcalPor100g);
    }
    if (!nullToAbsent || porcaoPadraoG != null) {
      map['porcao_padrao_g'] = Variable<double>(porcaoPadraoG);
    }
    if (!nullToAbsent || kcalPorUnidade != null) {
      map['kcal_por_unidade'] = Variable<double>(kcalPorUnidade);
    }
    if (!nullToAbsent || unidadesHabituais != null) {
      map['unidades_habituais'] = Variable<int>(unidadesHabituais);
    }
    map['arquivado'] = Variable<bool>(arquivado);
    return map;
  }

  AlimentosCompanion toCompanion(bool nullToAbsent) {
    return AlimentosCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      versao: Value(versao),
      versaoRemota: versaoRemota == null && nullToAbsent
          ? const Value.absent()
          : Value(versaoRemota),
      estadoSync: Value(estadoSync),
      excluido: Value(excluido),
      petId: Value(petId),
      nome: Value(nome),
      tipo: Value(tipo),
      densidadeKcalPor100g: densidadeKcalPor100g == null && nullToAbsent
          ? const Value.absent()
          : Value(densidadeKcalPor100g),
      porcaoPadraoG: porcaoPadraoG == null && nullToAbsent
          ? const Value.absent()
          : Value(porcaoPadraoG),
      kcalPorUnidade: kcalPorUnidade == null && nullToAbsent
          ? const Value.absent()
          : Value(kcalPorUnidade),
      unidadesHabituais: unidadesHabituais == null && nullToAbsent
          ? const Value.absent()
          : Value(unidadesHabituais),
      arquivado: Value(arquivado),
    );
  }

  factory AlimentoLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AlimentoLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      versao: serializer.fromJson<int>(json['versao']),
      versaoRemota: serializer.fromJson<int?>(json['versaoRemota']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      excluido: serializer.fromJson<bool>(json['excluido']),
      petId: serializer.fromJson<String>(json['petId']),
      nome: serializer.fromJson<String>(json['nome']),
      tipo: serializer.fromJson<String>(json['tipo']),
      densidadeKcalPor100g: serializer.fromJson<double?>(
        json['densidadeKcalPor100g'],
      ),
      porcaoPadraoG: serializer.fromJson<double?>(json['porcaoPadraoG']),
      kcalPorUnidade: serializer.fromJson<double?>(json['kcalPorUnidade']),
      unidadesHabituais: serializer.fromJson<int?>(json['unidadesHabituais']),
      arquivado: serializer.fromJson<bool>(json['arquivado']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'versao': serializer.toJson<int>(versao),
      'versaoRemota': serializer.toJson<int?>(versaoRemota),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'excluido': serializer.toJson<bool>(excluido),
      'petId': serializer.toJson<String>(petId),
      'nome': serializer.toJson<String>(nome),
      'tipo': serializer.toJson<String>(tipo),
      'densidadeKcalPor100g': serializer.toJson<double?>(densidadeKcalPor100g),
      'porcaoPadraoG': serializer.toJson<double?>(porcaoPadraoG),
      'kcalPorUnidade': serializer.toJson<double?>(kcalPorUnidade),
      'unidadesHabituais': serializer.toJson<int?>(unidadesHabituais),
      'arquivado': serializer.toJson<bool>(arquivado),
    };
  }

  AlimentoLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? versao,
    Value<int?> versaoRemota = const Value.absent(),
    String? estadoSync,
    bool? excluido,
    String? petId,
    String? nome,
    String? tipo,
    Value<double?> densidadeKcalPor100g = const Value.absent(),
    Value<double?> porcaoPadraoG = const Value.absent(),
    Value<double?> kcalPorUnidade = const Value.absent(),
    Value<int?> unidadesHabituais = const Value.absent(),
    bool? arquivado,
  }) => AlimentoLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    versao: versao ?? this.versao,
    versaoRemota: versaoRemota.present ? versaoRemota.value : this.versaoRemota,
    estadoSync: estadoSync ?? this.estadoSync,
    excluido: excluido ?? this.excluido,
    petId: petId ?? this.petId,
    nome: nome ?? this.nome,
    tipo: tipo ?? this.tipo,
    densidadeKcalPor100g: densidadeKcalPor100g.present
        ? densidadeKcalPor100g.value
        : this.densidadeKcalPor100g,
    porcaoPadraoG: porcaoPadraoG.present
        ? porcaoPadraoG.value
        : this.porcaoPadraoG,
    kcalPorUnidade: kcalPorUnidade.present
        ? kcalPorUnidade.value
        : this.kcalPorUnidade,
    unidadesHabituais: unidadesHabituais.present
        ? unidadesHabituais.value
        : this.unidadesHabituais,
    arquivado: arquivado ?? this.arquivado,
  );
  AlimentoLinha copyWithCompanion(AlimentosCompanion data) {
    return AlimentoLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      versao: data.versao.present ? data.versao.value : this.versao,
      versaoRemota: data.versaoRemota.present
          ? data.versaoRemota.value
          : this.versaoRemota,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      excluido: data.excluido.present ? data.excluido.value : this.excluido,
      petId: data.petId.present ? data.petId.value : this.petId,
      nome: data.nome.present ? data.nome.value : this.nome,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      densidadeKcalPor100g: data.densidadeKcalPor100g.present
          ? data.densidadeKcalPor100g.value
          : this.densidadeKcalPor100g,
      porcaoPadraoG: data.porcaoPadraoG.present
          ? data.porcaoPadraoG.value
          : this.porcaoPadraoG,
      kcalPorUnidade: data.kcalPorUnidade.present
          ? data.kcalPorUnidade.value
          : this.kcalPorUnidade,
      unidadesHabituais: data.unidadesHabituais.present
          ? data.unidadesHabituais.value
          : this.unidadesHabituais,
      arquivado: data.arquivado.present ? data.arquivado.value : this.arquivado,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AlimentoLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('densidadeKcalPor100g: $densidadeKcalPor100g, ')
          ..write('porcaoPadraoG: $porcaoPadraoG, ')
          ..write('kcalPorUnidade: $kcalPorUnidade, ')
          ..write('unidadesHabituais: $unidadesHabituais, ')
          ..write('arquivado: $arquivado')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    nome,
    tipo,
    densidadeKcalPor100g,
    porcaoPadraoG,
    kcalPorUnidade,
    unidadesHabituais,
    arquivado,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AlimentoLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.versao == this.versao &&
          other.versaoRemota == this.versaoRemota &&
          other.estadoSync == this.estadoSync &&
          other.excluido == this.excluido &&
          other.petId == this.petId &&
          other.nome == this.nome &&
          other.tipo == this.tipo &&
          other.densidadeKcalPor100g == this.densidadeKcalPor100g &&
          other.porcaoPadraoG == this.porcaoPadraoG &&
          other.kcalPorUnidade == this.kcalPorUnidade &&
          other.unidadesHabituais == this.unidadesHabituais &&
          other.arquivado == this.arquivado);
}

class AlimentosCompanion extends UpdateCompanion<AlimentoLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> versao;
  final Value<int?> versaoRemota;
  final Value<String> estadoSync;
  final Value<bool> excluido;
  final Value<String> petId;
  final Value<String> nome;
  final Value<String> tipo;
  final Value<double?> densidadeKcalPor100g;
  final Value<double?> porcaoPadraoG;
  final Value<double?> kcalPorUnidade;
  final Value<int?> unidadesHabituais;
  final Value<bool> arquivado;
  final Value<int> rowid;
  const AlimentosCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    this.petId = const Value.absent(),
    this.nome = const Value.absent(),
    this.tipo = const Value.absent(),
    this.densidadeKcalPor100g = const Value.absent(),
    this.porcaoPadraoG = const Value.absent(),
    this.kcalPorUnidade = const Value.absent(),
    this.unidadesHabituais = const Value.absent(),
    this.arquivado = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AlimentosCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    required String petId,
    required String nome,
    this.tipo = const Value.absent(),
    this.densidadeKcalPor100g = const Value.absent(),
    this.porcaoPadraoG = const Value.absent(),
    this.kcalPorUnidade = const Value.absent(),
    this.unidadesHabituais = const Value.absent(),
    this.arquivado = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       petId = Value(petId),
       nome = Value(nome);
  static Insertable<AlimentoLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? versao,
    Expression<int>? versaoRemota,
    Expression<String>? estadoSync,
    Expression<bool>? excluido,
    Expression<String>? petId,
    Expression<String>? nome,
    Expression<String>? tipo,
    Expression<double>? densidadeKcalPor100g,
    Expression<double>? porcaoPadraoG,
    Expression<double>? kcalPorUnidade,
    Expression<int>? unidadesHabituais,
    Expression<bool>? arquivado,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (versao != null) 'versao': versao,
      if (versaoRemota != null) 'versao_remota': versaoRemota,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (excluido != null) 'excluido': excluido,
      if (petId != null) 'pet_id': petId,
      if (nome != null) 'nome': nome,
      if (tipo != null) 'tipo': tipo,
      if (densidadeKcalPor100g != null)
        'densidade_kcal_por100g': densidadeKcalPor100g,
      if (porcaoPadraoG != null) 'porcao_padrao_g': porcaoPadraoG,
      if (kcalPorUnidade != null) 'kcal_por_unidade': kcalPorUnidade,
      if (unidadesHabituais != null) 'unidades_habituais': unidadesHabituais,
      if (arquivado != null) 'arquivado': arquivado,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AlimentosCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? versao,
    Value<int?>? versaoRemota,
    Value<String>? estadoSync,
    Value<bool>? excluido,
    Value<String>? petId,
    Value<String>? nome,
    Value<String>? tipo,
    Value<double?>? densidadeKcalPor100g,
    Value<double?>? porcaoPadraoG,
    Value<double?>? kcalPorUnidade,
    Value<int?>? unidadesHabituais,
    Value<bool>? arquivado,
    Value<int>? rowid,
  }) {
    return AlimentosCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      versao: versao ?? this.versao,
      versaoRemota: versaoRemota ?? this.versaoRemota,
      estadoSync: estadoSync ?? this.estadoSync,
      excluido: excluido ?? this.excluido,
      petId: petId ?? this.petId,
      nome: nome ?? this.nome,
      tipo: tipo ?? this.tipo,
      densidadeKcalPor100g: densidadeKcalPor100g ?? this.densidadeKcalPor100g,
      porcaoPadraoG: porcaoPadraoG ?? this.porcaoPadraoG,
      kcalPorUnidade: kcalPorUnidade ?? this.kcalPorUnidade,
      unidadesHabituais: unidadesHabituais ?? this.unidadesHabituais,
      arquivado: arquivado ?? this.arquivado,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (versao.present) {
      map['versao'] = Variable<int>(versao.value);
    }
    if (versaoRemota.present) {
      map['versao_remota'] = Variable<int>(versaoRemota.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (excluido.present) {
      map['excluido'] = Variable<bool>(excluido.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (nome.present) {
      map['nome'] = Variable<String>(nome.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (densidadeKcalPor100g.present) {
      map['densidade_kcal_por100g'] = Variable<double>(
        densidadeKcalPor100g.value,
      );
    }
    if (porcaoPadraoG.present) {
      map['porcao_padrao_g'] = Variable<double>(porcaoPadraoG.value);
    }
    if (kcalPorUnidade.present) {
      map['kcal_por_unidade'] = Variable<double>(kcalPorUnidade.value);
    }
    if (unidadesHabituais.present) {
      map['unidades_habituais'] = Variable<int>(unidadesHabituais.value);
    }
    if (arquivado.present) {
      map['arquivado'] = Variable<bool>(arquivado.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AlimentosCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('nome: $nome, ')
          ..write('tipo: $tipo, ')
          ..write('densidadeKcalPor100g: $densidadeKcalPor100g, ')
          ..write('porcaoPadraoG: $porcaoPadraoG, ')
          ..write('kcalPorUnidade: $kcalPorUnidade, ')
          ..write('unidadesHabituais: $unidadesHabituais, ')
          ..write('arquivado: $arquivado, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RefeicoesTable extends Refeicoes
    with TableInfo<$RefeicoesTable, RefeicaoLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RefeicoesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versaoMeta = const VerificationMeta('versao');
  @override
  late final GeneratedColumn<int> versao = GeneratedColumn<int>(
    'versao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _versaoRemotaMeta = const VerificationMeta(
    'versaoRemota',
  );
  @override
  late final GeneratedColumn<int> versaoRemota = GeneratedColumn<int>(
    'versao_remota',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _excluidoMeta = const VerificationMeta(
    'excluido',
  );
  @override
  late final GeneratedColumn<bool> excluido = GeneratedColumn<bool>(
    'excluido',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("excluido" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _alimentoIdMeta = const VerificationMeta(
    'alimentoId',
  );
  @override
  late final GeneratedColumn<String> alimentoId = GeneratedColumn<String>(
    'alimento_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _alimentoNomeMeta = const VerificationMeta(
    'alimentoNome',
  );
  @override
  late final GeneratedColumn<String> alimentoNome = GeneratedColumn<String>(
    'alimento_nome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _densidadeKcalPor100gMeta =
      const VerificationMeta('densidadeKcalPor100g');
  @override
  late final GeneratedColumn<double> densidadeKcalPor100g =
      GeneratedColumn<double>(
        'densidade_kcal_por100g',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _quantidadeGMeta = const VerificationMeta(
    'quantidadeG',
  );
  @override
  late final GeneratedColumn<double> quantidadeG = GeneratedColumn<double>(
    'quantidade_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energiaKcalMeta = const VerificationMeta(
    'energiaKcal',
  );
  @override
  late final GeneratedColumn<double> energiaKcal = GeneratedColumn<double>(
    'energia_kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataHoraMeta = const VerificationMeta(
    'dataHora',
  );
  @override
  late final GeneratedColumn<DateTime> dataHora = GeneratedColumn<DateTime>(
    'data_hora',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    alimentoId,
    alimentoNome,
    densidadeKcalPor100g,
    quantidadeG,
    energiaKcal,
    dataHora,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'refeicoes';
  @override
  VerificationContext validateIntegrity(
    Insertable<RefeicaoLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('versao')) {
      context.handle(
        _versaoMeta,
        versao.isAcceptableOrUnknown(data['versao']!, _versaoMeta),
      );
    }
    if (data.containsKey('versao_remota')) {
      context.handle(
        _versaoRemotaMeta,
        versaoRemota.isAcceptableOrUnknown(
          data['versao_remota']!,
          _versaoRemotaMeta,
        ),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('excluido')) {
      context.handle(
        _excluidoMeta,
        excluido.isAcceptableOrUnknown(data['excluido']!, _excluidoMeta),
      );
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('alimento_id')) {
      context.handle(
        _alimentoIdMeta,
        alimentoId.isAcceptableOrUnknown(data['alimento_id']!, _alimentoIdMeta),
      );
    }
    if (data.containsKey('alimento_nome')) {
      context.handle(
        _alimentoNomeMeta,
        alimentoNome.isAcceptableOrUnknown(
          data['alimento_nome']!,
          _alimentoNomeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_alimentoNomeMeta);
    }
    if (data.containsKey('densidade_kcal_por100g')) {
      context.handle(
        _densidadeKcalPor100gMeta,
        densidadeKcalPor100g.isAcceptableOrUnknown(
          data['densidade_kcal_por100g']!,
          _densidadeKcalPor100gMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_densidadeKcalPor100gMeta);
    }
    if (data.containsKey('quantidade_g')) {
      context.handle(
        _quantidadeGMeta,
        quantidadeG.isAcceptableOrUnknown(
          data['quantidade_g']!,
          _quantidadeGMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantidadeGMeta);
    }
    if (data.containsKey('energia_kcal')) {
      context.handle(
        _energiaKcalMeta,
        energiaKcal.isAcceptableOrUnknown(
          data['energia_kcal']!,
          _energiaKcalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_energiaKcalMeta);
    }
    if (data.containsKey('data_hora')) {
      context.handle(
        _dataHoraMeta,
        dataHora.isAcceptableOrUnknown(data['data_hora']!, _dataHoraMeta),
      );
    } else if (isInserting) {
      context.missing(_dataHoraMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RefeicaoLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RefeicaoLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      versao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao'],
      )!,
      versaoRemota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao_remota'],
      ),
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      excluido: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}excluido'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      alimentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alimento_id'],
      ),
      alimentoNome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alimento_nome'],
      )!,
      densidadeKcalPor100g: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}densidade_kcal_por100g'],
      )!,
      quantidadeG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantidade_g'],
      )!,
      energiaKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energia_kcal'],
      )!,
      dataHora: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_hora'],
      )!,
    );
  }

  @override
  $RefeicoesTable createAlias(String alias) {
    return $RefeicoesTable(attachedDatabase, alias);
  }
}

class RefeicaoLinha extends DataClass implements Insertable<RefeicaoLinha> {
  /// UUID v4 gerado no aparelho e reutilizado como ID do documento no
  /// Firestore.
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// Começa em 1 e soma 1 a cada alteração local.
  final int versao;

  /// Última versão confirmada no Firestore (`null` = nunca enviado).
  final int? versaoRemota;

  /// `local` (cópia desligada), `pendente`, `sincronizado`, `falha`,
  /// `conflito`.
  final String estadoSync;

  /// Lápide. As consultas da UI sempre filtram `excluido = false`.
  final bool excluido;
  final String petId;
  final String? alimentoId;
  final String alimentoNome;
  final double densidadeKcalPor100g;
  final double quantidadeG;
  final double energiaKcal;
  final DateTime dataHora;
  const RefeicaoLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.versao,
    this.versaoRemota,
    required this.estadoSync,
    required this.excluido,
    required this.petId,
    this.alimentoId,
    required this.alimentoNome,
    required this.densidadeKcalPor100g,
    required this.quantidadeG,
    required this.energiaKcal,
    required this.dataHora,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['versao'] = Variable<int>(versao);
    if (!nullToAbsent || versaoRemota != null) {
      map['versao_remota'] = Variable<int>(versaoRemota);
    }
    map['estado_sync'] = Variable<String>(estadoSync);
    map['excluido'] = Variable<bool>(excluido);
    map['pet_id'] = Variable<String>(petId);
    if (!nullToAbsent || alimentoId != null) {
      map['alimento_id'] = Variable<String>(alimentoId);
    }
    map['alimento_nome'] = Variable<String>(alimentoNome);
    map['densidade_kcal_por100g'] = Variable<double>(densidadeKcalPor100g);
    map['quantidade_g'] = Variable<double>(quantidadeG);
    map['energia_kcal'] = Variable<double>(energiaKcal);
    map['data_hora'] = Variable<DateTime>(dataHora);
    return map;
  }

  RefeicoesCompanion toCompanion(bool nullToAbsent) {
    return RefeicoesCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      versao: Value(versao),
      versaoRemota: versaoRemota == null && nullToAbsent
          ? const Value.absent()
          : Value(versaoRemota),
      estadoSync: Value(estadoSync),
      excluido: Value(excluido),
      petId: Value(petId),
      alimentoId: alimentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(alimentoId),
      alimentoNome: Value(alimentoNome),
      densidadeKcalPor100g: Value(densidadeKcalPor100g),
      quantidadeG: Value(quantidadeG),
      energiaKcal: Value(energiaKcal),
      dataHora: Value(dataHora),
    );
  }

  factory RefeicaoLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RefeicaoLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      versao: serializer.fromJson<int>(json['versao']),
      versaoRemota: serializer.fromJson<int?>(json['versaoRemota']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      excluido: serializer.fromJson<bool>(json['excluido']),
      petId: serializer.fromJson<String>(json['petId']),
      alimentoId: serializer.fromJson<String?>(json['alimentoId']),
      alimentoNome: serializer.fromJson<String>(json['alimentoNome']),
      densidadeKcalPor100g: serializer.fromJson<double>(
        json['densidadeKcalPor100g'],
      ),
      quantidadeG: serializer.fromJson<double>(json['quantidadeG']),
      energiaKcal: serializer.fromJson<double>(json['energiaKcal']),
      dataHora: serializer.fromJson<DateTime>(json['dataHora']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'versao': serializer.toJson<int>(versao),
      'versaoRemota': serializer.toJson<int?>(versaoRemota),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'excluido': serializer.toJson<bool>(excluido),
      'petId': serializer.toJson<String>(petId),
      'alimentoId': serializer.toJson<String?>(alimentoId),
      'alimentoNome': serializer.toJson<String>(alimentoNome),
      'densidadeKcalPor100g': serializer.toJson<double>(densidadeKcalPor100g),
      'quantidadeG': serializer.toJson<double>(quantidadeG),
      'energiaKcal': serializer.toJson<double>(energiaKcal),
      'dataHora': serializer.toJson<DateTime>(dataHora),
    };
  }

  RefeicaoLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? versao,
    Value<int?> versaoRemota = const Value.absent(),
    String? estadoSync,
    bool? excluido,
    String? petId,
    Value<String?> alimentoId = const Value.absent(),
    String? alimentoNome,
    double? densidadeKcalPor100g,
    double? quantidadeG,
    double? energiaKcal,
    DateTime? dataHora,
  }) => RefeicaoLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    versao: versao ?? this.versao,
    versaoRemota: versaoRemota.present ? versaoRemota.value : this.versaoRemota,
    estadoSync: estadoSync ?? this.estadoSync,
    excluido: excluido ?? this.excluido,
    petId: petId ?? this.petId,
    alimentoId: alimentoId.present ? alimentoId.value : this.alimentoId,
    alimentoNome: alimentoNome ?? this.alimentoNome,
    densidadeKcalPor100g: densidadeKcalPor100g ?? this.densidadeKcalPor100g,
    quantidadeG: quantidadeG ?? this.quantidadeG,
    energiaKcal: energiaKcal ?? this.energiaKcal,
    dataHora: dataHora ?? this.dataHora,
  );
  RefeicaoLinha copyWithCompanion(RefeicoesCompanion data) {
    return RefeicaoLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      versao: data.versao.present ? data.versao.value : this.versao,
      versaoRemota: data.versaoRemota.present
          ? data.versaoRemota.value
          : this.versaoRemota,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      excluido: data.excluido.present ? data.excluido.value : this.excluido,
      petId: data.petId.present ? data.petId.value : this.petId,
      alimentoId: data.alimentoId.present
          ? data.alimentoId.value
          : this.alimentoId,
      alimentoNome: data.alimentoNome.present
          ? data.alimentoNome.value
          : this.alimentoNome,
      densidadeKcalPor100g: data.densidadeKcalPor100g.present
          ? data.densidadeKcalPor100g.value
          : this.densidadeKcalPor100g,
      quantidadeG: data.quantidadeG.present
          ? data.quantidadeG.value
          : this.quantidadeG,
      energiaKcal: data.energiaKcal.present
          ? data.energiaKcal.value
          : this.energiaKcal,
      dataHora: data.dataHora.present ? data.dataHora.value : this.dataHora,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RefeicaoLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('alimentoId: $alimentoId, ')
          ..write('alimentoNome: $alimentoNome, ')
          ..write('densidadeKcalPor100g: $densidadeKcalPor100g, ')
          ..write('quantidadeG: $quantidadeG, ')
          ..write('energiaKcal: $energiaKcal, ')
          ..write('dataHora: $dataHora')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    alimentoId,
    alimentoNome,
    densidadeKcalPor100g,
    quantidadeG,
    energiaKcal,
    dataHora,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RefeicaoLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.versao == this.versao &&
          other.versaoRemota == this.versaoRemota &&
          other.estadoSync == this.estadoSync &&
          other.excluido == this.excluido &&
          other.petId == this.petId &&
          other.alimentoId == this.alimentoId &&
          other.alimentoNome == this.alimentoNome &&
          other.densidadeKcalPor100g == this.densidadeKcalPor100g &&
          other.quantidadeG == this.quantidadeG &&
          other.energiaKcal == this.energiaKcal &&
          other.dataHora == this.dataHora);
}

class RefeicoesCompanion extends UpdateCompanion<RefeicaoLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> versao;
  final Value<int?> versaoRemota;
  final Value<String> estadoSync;
  final Value<bool> excluido;
  final Value<String> petId;
  final Value<String?> alimentoId;
  final Value<String> alimentoNome;
  final Value<double> densidadeKcalPor100g;
  final Value<double> quantidadeG;
  final Value<double> energiaKcal;
  final Value<DateTime> dataHora;
  final Value<int> rowid;
  const RefeicoesCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    this.petId = const Value.absent(),
    this.alimentoId = const Value.absent(),
    this.alimentoNome = const Value.absent(),
    this.densidadeKcalPor100g = const Value.absent(),
    this.quantidadeG = const Value.absent(),
    this.energiaKcal = const Value.absent(),
    this.dataHora = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RefeicoesCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    required String petId,
    this.alimentoId = const Value.absent(),
    required String alimentoNome,
    required double densidadeKcalPor100g,
    required double quantidadeG,
    required double energiaKcal,
    required DateTime dataHora,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       petId = Value(petId),
       alimentoNome = Value(alimentoNome),
       densidadeKcalPor100g = Value(densidadeKcalPor100g),
       quantidadeG = Value(quantidadeG),
       energiaKcal = Value(energiaKcal),
       dataHora = Value(dataHora);
  static Insertable<RefeicaoLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? versao,
    Expression<int>? versaoRemota,
    Expression<String>? estadoSync,
    Expression<bool>? excluido,
    Expression<String>? petId,
    Expression<String>? alimentoId,
    Expression<String>? alimentoNome,
    Expression<double>? densidadeKcalPor100g,
    Expression<double>? quantidadeG,
    Expression<double>? energiaKcal,
    Expression<DateTime>? dataHora,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (versao != null) 'versao': versao,
      if (versaoRemota != null) 'versao_remota': versaoRemota,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (excluido != null) 'excluido': excluido,
      if (petId != null) 'pet_id': petId,
      if (alimentoId != null) 'alimento_id': alimentoId,
      if (alimentoNome != null) 'alimento_nome': alimentoNome,
      if (densidadeKcalPor100g != null)
        'densidade_kcal_por100g': densidadeKcalPor100g,
      if (quantidadeG != null) 'quantidade_g': quantidadeG,
      if (energiaKcal != null) 'energia_kcal': energiaKcal,
      if (dataHora != null) 'data_hora': dataHora,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RefeicoesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? versao,
    Value<int?>? versaoRemota,
    Value<String>? estadoSync,
    Value<bool>? excluido,
    Value<String>? petId,
    Value<String?>? alimentoId,
    Value<String>? alimentoNome,
    Value<double>? densidadeKcalPor100g,
    Value<double>? quantidadeG,
    Value<double>? energiaKcal,
    Value<DateTime>? dataHora,
    Value<int>? rowid,
  }) {
    return RefeicoesCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      versao: versao ?? this.versao,
      versaoRemota: versaoRemota ?? this.versaoRemota,
      estadoSync: estadoSync ?? this.estadoSync,
      excluido: excluido ?? this.excluido,
      petId: petId ?? this.petId,
      alimentoId: alimentoId ?? this.alimentoId,
      alimentoNome: alimentoNome ?? this.alimentoNome,
      densidadeKcalPor100g: densidadeKcalPor100g ?? this.densidadeKcalPor100g,
      quantidadeG: quantidadeG ?? this.quantidadeG,
      energiaKcal: energiaKcal ?? this.energiaKcal,
      dataHora: dataHora ?? this.dataHora,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (versao.present) {
      map['versao'] = Variable<int>(versao.value);
    }
    if (versaoRemota.present) {
      map['versao_remota'] = Variable<int>(versaoRemota.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (excluido.present) {
      map['excluido'] = Variable<bool>(excluido.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (alimentoId.present) {
      map['alimento_id'] = Variable<String>(alimentoId.value);
    }
    if (alimentoNome.present) {
      map['alimento_nome'] = Variable<String>(alimentoNome.value);
    }
    if (densidadeKcalPor100g.present) {
      map['densidade_kcal_por100g'] = Variable<double>(
        densidadeKcalPor100g.value,
      );
    }
    if (quantidadeG.present) {
      map['quantidade_g'] = Variable<double>(quantidadeG.value);
    }
    if (energiaKcal.present) {
      map['energia_kcal'] = Variable<double>(energiaKcal.value);
    }
    if (dataHora.present) {
      map['data_hora'] = Variable<DateTime>(dataHora.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RefeicoesCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('alimentoId: $alimentoId, ')
          ..write('alimentoNome: $alimentoNome, ')
          ..write('densidadeKcalPor100g: $densidadeKcalPor100g, ')
          ..write('quantidadeG: $quantidadeG, ')
          ..write('energiaKcal: $energiaKcal, ')
          ..write('dataHora: $dataHora, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExtrasTable extends Extras with TableInfo<$ExtrasTable, ExtraLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExtrasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versaoMeta = const VerificationMeta('versao');
  @override
  late final GeneratedColumn<int> versao = GeneratedColumn<int>(
    'versao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _versaoRemotaMeta = const VerificationMeta(
    'versaoRemota',
  );
  @override
  late final GeneratedColumn<int> versaoRemota = GeneratedColumn<int>(
    'versao_remota',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _excluidoMeta = const VerificationMeta(
    'excluido',
  );
  @override
  late final GeneratedColumn<bool> excluido = GeneratedColumn<bool>(
    'excluido',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("excluido" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _alimentoIdMeta = const VerificationMeta(
    'alimentoId',
  );
  @override
  late final GeneratedColumn<String> alimentoId = GeneratedColumn<String>(
    'alimento_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descricaoMeta = const VerificationMeta(
    'descricao',
  );
  @override
  late final GeneratedColumn<String> descricao = GeneratedColumn<String>(
    'descricao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantidadeGMeta = const VerificationMeta(
    'quantidadeG',
  );
  @override
  late final GeneratedColumn<double> quantidadeG = GeneratedColumn<double>(
    'quantidade_g',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unidadesMeta = const VerificationMeta(
    'unidades',
  );
  @override
  late final GeneratedColumn<int> unidades = GeneratedColumn<int>(
    'unidades',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energiaKcalMeta = const VerificationMeta(
    'energiaKcal',
  );
  @override
  late final GeneratedColumn<double> energiaKcal = GeneratedColumn<double>(
    'energia_kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataHoraMeta = const VerificationMeta(
    'dataHora',
  );
  @override
  late final GeneratedColumn<DateTime> dataHora = GeneratedColumn<DateTime>(
    'data_hora',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    alimentoId,
    descricao,
    quantidadeG,
    unidades,
    energiaKcal,
    dataHora,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'extras';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExtraLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('versao')) {
      context.handle(
        _versaoMeta,
        versao.isAcceptableOrUnknown(data['versao']!, _versaoMeta),
      );
    }
    if (data.containsKey('versao_remota')) {
      context.handle(
        _versaoRemotaMeta,
        versaoRemota.isAcceptableOrUnknown(
          data['versao_remota']!,
          _versaoRemotaMeta,
        ),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('excluido')) {
      context.handle(
        _excluidoMeta,
        excluido.isAcceptableOrUnknown(data['excluido']!, _excluidoMeta),
      );
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('alimento_id')) {
      context.handle(
        _alimentoIdMeta,
        alimentoId.isAcceptableOrUnknown(data['alimento_id']!, _alimentoIdMeta),
      );
    }
    if (data.containsKey('descricao')) {
      context.handle(
        _descricaoMeta,
        descricao.isAcceptableOrUnknown(data['descricao']!, _descricaoMeta),
      );
    } else if (isInserting) {
      context.missing(_descricaoMeta);
    }
    if (data.containsKey('quantidade_g')) {
      context.handle(
        _quantidadeGMeta,
        quantidadeG.isAcceptableOrUnknown(
          data['quantidade_g']!,
          _quantidadeGMeta,
        ),
      );
    }
    if (data.containsKey('unidades')) {
      context.handle(
        _unidadesMeta,
        unidades.isAcceptableOrUnknown(data['unidades']!, _unidadesMeta),
      );
    }
    if (data.containsKey('energia_kcal')) {
      context.handle(
        _energiaKcalMeta,
        energiaKcal.isAcceptableOrUnknown(
          data['energia_kcal']!,
          _energiaKcalMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_energiaKcalMeta);
    }
    if (data.containsKey('data_hora')) {
      context.handle(
        _dataHoraMeta,
        dataHora.isAcceptableOrUnknown(data['data_hora']!, _dataHoraMeta),
      );
    } else if (isInserting) {
      context.missing(_dataHoraMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExtraLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExtraLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      versao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao'],
      )!,
      versaoRemota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao_remota'],
      ),
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      excluido: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}excluido'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      alimentoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alimento_id'],
      ),
      descricao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descricao'],
      )!,
      quantidadeG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantidade_g'],
      ),
      unidades: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unidades'],
      ),
      energiaKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energia_kcal'],
      )!,
      dataHora: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_hora'],
      )!,
    );
  }

  @override
  $ExtrasTable createAlias(String alias) {
    return $ExtrasTable(attachedDatabase, alias);
  }
}

class ExtraLinha extends DataClass implements Insertable<ExtraLinha> {
  /// UUID v4 gerado no aparelho e reutilizado como ID do documento no
  /// Firestore.
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// Começa em 1 e soma 1 a cada alteração local.
  final int versao;

  /// Última versão confirmada no Firestore (`null` = nunca enviado).
  final int? versaoRemota;

  /// `local` (cópia desligada), `pendente`, `sincronizado`, `falha`,
  /// `conflito`.
  final String estadoSync;

  /// Lápide. As consultas da UI sempre filtram `excluido = false`.
  final bool excluido;
  final String petId;
  final String? alimentoId;
  final String descricao;
  final double? quantidadeG;
  final int? unidades;
  final double energiaKcal;
  final DateTime dataHora;
  const ExtraLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.versao,
    this.versaoRemota,
    required this.estadoSync,
    required this.excluido,
    required this.petId,
    this.alimentoId,
    required this.descricao,
    this.quantidadeG,
    this.unidades,
    required this.energiaKcal,
    required this.dataHora,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['versao'] = Variable<int>(versao);
    if (!nullToAbsent || versaoRemota != null) {
      map['versao_remota'] = Variable<int>(versaoRemota);
    }
    map['estado_sync'] = Variable<String>(estadoSync);
    map['excluido'] = Variable<bool>(excluido);
    map['pet_id'] = Variable<String>(petId);
    if (!nullToAbsent || alimentoId != null) {
      map['alimento_id'] = Variable<String>(alimentoId);
    }
    map['descricao'] = Variable<String>(descricao);
    if (!nullToAbsent || quantidadeG != null) {
      map['quantidade_g'] = Variable<double>(quantidadeG);
    }
    if (!nullToAbsent || unidades != null) {
      map['unidades'] = Variable<int>(unidades);
    }
    map['energia_kcal'] = Variable<double>(energiaKcal);
    map['data_hora'] = Variable<DateTime>(dataHora);
    return map;
  }

  ExtrasCompanion toCompanion(bool nullToAbsent) {
    return ExtrasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      versao: Value(versao),
      versaoRemota: versaoRemota == null && nullToAbsent
          ? const Value.absent()
          : Value(versaoRemota),
      estadoSync: Value(estadoSync),
      excluido: Value(excluido),
      petId: Value(petId),
      alimentoId: alimentoId == null && nullToAbsent
          ? const Value.absent()
          : Value(alimentoId),
      descricao: Value(descricao),
      quantidadeG: quantidadeG == null && nullToAbsent
          ? const Value.absent()
          : Value(quantidadeG),
      unidades: unidades == null && nullToAbsent
          ? const Value.absent()
          : Value(unidades),
      energiaKcal: Value(energiaKcal),
      dataHora: Value(dataHora),
    );
  }

  factory ExtraLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExtraLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      versao: serializer.fromJson<int>(json['versao']),
      versaoRemota: serializer.fromJson<int?>(json['versaoRemota']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      excluido: serializer.fromJson<bool>(json['excluido']),
      petId: serializer.fromJson<String>(json['petId']),
      alimentoId: serializer.fromJson<String?>(json['alimentoId']),
      descricao: serializer.fromJson<String>(json['descricao']),
      quantidadeG: serializer.fromJson<double?>(json['quantidadeG']),
      unidades: serializer.fromJson<int?>(json['unidades']),
      energiaKcal: serializer.fromJson<double>(json['energiaKcal']),
      dataHora: serializer.fromJson<DateTime>(json['dataHora']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'versao': serializer.toJson<int>(versao),
      'versaoRemota': serializer.toJson<int?>(versaoRemota),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'excluido': serializer.toJson<bool>(excluido),
      'petId': serializer.toJson<String>(petId),
      'alimentoId': serializer.toJson<String?>(alimentoId),
      'descricao': serializer.toJson<String>(descricao),
      'quantidadeG': serializer.toJson<double?>(quantidadeG),
      'unidades': serializer.toJson<int?>(unidades),
      'energiaKcal': serializer.toJson<double>(energiaKcal),
      'dataHora': serializer.toJson<DateTime>(dataHora),
    };
  }

  ExtraLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? versao,
    Value<int?> versaoRemota = const Value.absent(),
    String? estadoSync,
    bool? excluido,
    String? petId,
    Value<String?> alimentoId = const Value.absent(),
    String? descricao,
    Value<double?> quantidadeG = const Value.absent(),
    Value<int?> unidades = const Value.absent(),
    double? energiaKcal,
    DateTime? dataHora,
  }) => ExtraLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    versao: versao ?? this.versao,
    versaoRemota: versaoRemota.present ? versaoRemota.value : this.versaoRemota,
    estadoSync: estadoSync ?? this.estadoSync,
    excluido: excluido ?? this.excluido,
    petId: petId ?? this.petId,
    alimentoId: alimentoId.present ? alimentoId.value : this.alimentoId,
    descricao: descricao ?? this.descricao,
    quantidadeG: quantidadeG.present ? quantidadeG.value : this.quantidadeG,
    unidades: unidades.present ? unidades.value : this.unidades,
    energiaKcal: energiaKcal ?? this.energiaKcal,
    dataHora: dataHora ?? this.dataHora,
  );
  ExtraLinha copyWithCompanion(ExtrasCompanion data) {
    return ExtraLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      versao: data.versao.present ? data.versao.value : this.versao,
      versaoRemota: data.versaoRemota.present
          ? data.versaoRemota.value
          : this.versaoRemota,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      excluido: data.excluido.present ? data.excluido.value : this.excluido,
      petId: data.petId.present ? data.petId.value : this.petId,
      alimentoId: data.alimentoId.present
          ? data.alimentoId.value
          : this.alimentoId,
      descricao: data.descricao.present ? data.descricao.value : this.descricao,
      quantidadeG: data.quantidadeG.present
          ? data.quantidadeG.value
          : this.quantidadeG,
      unidades: data.unidades.present ? data.unidades.value : this.unidades,
      energiaKcal: data.energiaKcal.present
          ? data.energiaKcal.value
          : this.energiaKcal,
      dataHora: data.dataHora.present ? data.dataHora.value : this.dataHora,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExtraLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('alimentoId: $alimentoId, ')
          ..write('descricao: $descricao, ')
          ..write('quantidadeG: $quantidadeG, ')
          ..write('unidades: $unidades, ')
          ..write('energiaKcal: $energiaKcal, ')
          ..write('dataHora: $dataHora')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    alimentoId,
    descricao,
    quantidadeG,
    unidades,
    energiaKcal,
    dataHora,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExtraLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.versao == this.versao &&
          other.versaoRemota == this.versaoRemota &&
          other.estadoSync == this.estadoSync &&
          other.excluido == this.excluido &&
          other.petId == this.petId &&
          other.alimentoId == this.alimentoId &&
          other.descricao == this.descricao &&
          other.quantidadeG == this.quantidadeG &&
          other.unidades == this.unidades &&
          other.energiaKcal == this.energiaKcal &&
          other.dataHora == this.dataHora);
}

class ExtrasCompanion extends UpdateCompanion<ExtraLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> versao;
  final Value<int?> versaoRemota;
  final Value<String> estadoSync;
  final Value<bool> excluido;
  final Value<String> petId;
  final Value<String?> alimentoId;
  final Value<String> descricao;
  final Value<double?> quantidadeG;
  final Value<int?> unidades;
  final Value<double> energiaKcal;
  final Value<DateTime> dataHora;
  final Value<int> rowid;
  const ExtrasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    this.petId = const Value.absent(),
    this.alimentoId = const Value.absent(),
    this.descricao = const Value.absent(),
    this.quantidadeG = const Value.absent(),
    this.unidades = const Value.absent(),
    this.energiaKcal = const Value.absent(),
    this.dataHora = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExtrasCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    required String petId,
    this.alimentoId = const Value.absent(),
    required String descricao,
    this.quantidadeG = const Value.absent(),
    this.unidades = const Value.absent(),
    required double energiaKcal,
    required DateTime dataHora,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       petId = Value(petId),
       descricao = Value(descricao),
       energiaKcal = Value(energiaKcal),
       dataHora = Value(dataHora);
  static Insertable<ExtraLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? versao,
    Expression<int>? versaoRemota,
    Expression<String>? estadoSync,
    Expression<bool>? excluido,
    Expression<String>? petId,
    Expression<String>? alimentoId,
    Expression<String>? descricao,
    Expression<double>? quantidadeG,
    Expression<int>? unidades,
    Expression<double>? energiaKcal,
    Expression<DateTime>? dataHora,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (versao != null) 'versao': versao,
      if (versaoRemota != null) 'versao_remota': versaoRemota,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (excluido != null) 'excluido': excluido,
      if (petId != null) 'pet_id': petId,
      if (alimentoId != null) 'alimento_id': alimentoId,
      if (descricao != null) 'descricao': descricao,
      if (quantidadeG != null) 'quantidade_g': quantidadeG,
      if (unidades != null) 'unidades': unidades,
      if (energiaKcal != null) 'energia_kcal': energiaKcal,
      if (dataHora != null) 'data_hora': dataHora,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExtrasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? versao,
    Value<int?>? versaoRemota,
    Value<String>? estadoSync,
    Value<bool>? excluido,
    Value<String>? petId,
    Value<String?>? alimentoId,
    Value<String>? descricao,
    Value<double?>? quantidadeG,
    Value<int?>? unidades,
    Value<double>? energiaKcal,
    Value<DateTime>? dataHora,
    Value<int>? rowid,
  }) {
    return ExtrasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      versao: versao ?? this.versao,
      versaoRemota: versaoRemota ?? this.versaoRemota,
      estadoSync: estadoSync ?? this.estadoSync,
      excluido: excluido ?? this.excluido,
      petId: petId ?? this.petId,
      alimentoId: alimentoId ?? this.alimentoId,
      descricao: descricao ?? this.descricao,
      quantidadeG: quantidadeG ?? this.quantidadeG,
      unidades: unidades ?? this.unidades,
      energiaKcal: energiaKcal ?? this.energiaKcal,
      dataHora: dataHora ?? this.dataHora,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (versao.present) {
      map['versao'] = Variable<int>(versao.value);
    }
    if (versaoRemota.present) {
      map['versao_remota'] = Variable<int>(versaoRemota.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (excluido.present) {
      map['excluido'] = Variable<bool>(excluido.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (alimentoId.present) {
      map['alimento_id'] = Variable<String>(alimentoId.value);
    }
    if (descricao.present) {
      map['descricao'] = Variable<String>(descricao.value);
    }
    if (quantidadeG.present) {
      map['quantidade_g'] = Variable<double>(quantidadeG.value);
    }
    if (unidades.present) {
      map['unidades'] = Variable<int>(unidades.value);
    }
    if (energiaKcal.present) {
      map['energia_kcal'] = Variable<double>(energiaKcal.value);
    }
    if (dataHora.present) {
      map['data_hora'] = Variable<DateTime>(dataHora.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExtrasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('alimentoId: $alimentoId, ')
          ..write('descricao: $descricao, ')
          ..write('quantidadeG: $quantidadeG, ')
          ..write('unidades: $unidades, ')
          ..write('energiaKcal: $energiaKcal, ')
          ..write('dataHora: $dataHora, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AtividadesTable extends Atividades
    with TableInfo<$AtividadesTable, AtividadeLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AtividadesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versaoMeta = const VerificationMeta('versao');
  @override
  late final GeneratedColumn<int> versao = GeneratedColumn<int>(
    'versao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _versaoRemotaMeta = const VerificationMeta(
    'versaoRemota',
  );
  @override
  late final GeneratedColumn<int> versaoRemota = GeneratedColumn<int>(
    'versao_remota',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _excluidoMeta = const VerificationMeta(
    'excluido',
  );
  @override
  late final GeneratedColumn<bool> excluido = GeneratedColumn<bool>(
    'excluido',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("excluido" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _duracaoMinMeta = const VerificationMeta(
    'duracaoMin',
  );
  @override
  late final GeneratedColumn<int> duracaoMin = GeneratedColumn<int>(
    'duracao_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataHoraMeta = const VerificationMeta(
    'dataHora',
  );
  @override
  late final GeneratedColumn<DateTime> dataHora = GeneratedColumn<DateTime>(
    'data_hora',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    tipo,
    duracaoMin,
    dataHora,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'atividades';
  @override
  VerificationContext validateIntegrity(
    Insertable<AtividadeLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('versao')) {
      context.handle(
        _versaoMeta,
        versao.isAcceptableOrUnknown(data['versao']!, _versaoMeta),
      );
    }
    if (data.containsKey('versao_remota')) {
      context.handle(
        _versaoRemotaMeta,
        versaoRemota.isAcceptableOrUnknown(
          data['versao_remota']!,
          _versaoRemotaMeta,
        ),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('excluido')) {
      context.handle(
        _excluidoMeta,
        excluido.isAcceptableOrUnknown(data['excluido']!, _excluidoMeta),
      );
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('duracao_min')) {
      context.handle(
        _duracaoMinMeta,
        duracaoMin.isAcceptableOrUnknown(data['duracao_min']!, _duracaoMinMeta),
      );
    } else if (isInserting) {
      context.missing(_duracaoMinMeta);
    }
    if (data.containsKey('data_hora')) {
      context.handle(
        _dataHoraMeta,
        dataHora.isAcceptableOrUnknown(data['data_hora']!, _dataHoraMeta),
      );
    } else if (isInserting) {
      context.missing(_dataHoraMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AtividadeLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AtividadeLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      versao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao'],
      )!,
      versaoRemota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao_remota'],
      ),
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      excluido: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}excluido'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      duracaoMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duracao_min'],
      )!,
      dataHora: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_hora'],
      )!,
    );
  }

  @override
  $AtividadesTable createAlias(String alias) {
    return $AtividadesTable(attachedDatabase, alias);
  }
}

class AtividadeLinha extends DataClass implements Insertable<AtividadeLinha> {
  /// UUID v4 gerado no aparelho e reutilizado como ID do documento no
  /// Firestore.
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// Começa em 1 e soma 1 a cada alteração local.
  final int versao;

  /// Última versão confirmada no Firestore (`null` = nunca enviado).
  final int? versaoRemota;

  /// `local` (cópia desligada), `pendente`, `sincronizado`, `falha`,
  /// `conflito`.
  final String estadoSync;

  /// Lápide. As consultas da UI sempre filtram `excluido = false`.
  final bool excluido;
  final String petId;
  final String tipo;
  final int duracaoMin;
  final DateTime dataHora;
  const AtividadeLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.versao,
    this.versaoRemota,
    required this.estadoSync,
    required this.excluido,
    required this.petId,
    required this.tipo,
    required this.duracaoMin,
    required this.dataHora,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['versao'] = Variable<int>(versao);
    if (!nullToAbsent || versaoRemota != null) {
      map['versao_remota'] = Variable<int>(versaoRemota);
    }
    map['estado_sync'] = Variable<String>(estadoSync);
    map['excluido'] = Variable<bool>(excluido);
    map['pet_id'] = Variable<String>(petId);
    map['tipo'] = Variable<String>(tipo);
    map['duracao_min'] = Variable<int>(duracaoMin);
    map['data_hora'] = Variable<DateTime>(dataHora);
    return map;
  }

  AtividadesCompanion toCompanion(bool nullToAbsent) {
    return AtividadesCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      versao: Value(versao),
      versaoRemota: versaoRemota == null && nullToAbsent
          ? const Value.absent()
          : Value(versaoRemota),
      estadoSync: Value(estadoSync),
      excluido: Value(excluido),
      petId: Value(petId),
      tipo: Value(tipo),
      duracaoMin: Value(duracaoMin),
      dataHora: Value(dataHora),
    );
  }

  factory AtividadeLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AtividadeLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      versao: serializer.fromJson<int>(json['versao']),
      versaoRemota: serializer.fromJson<int?>(json['versaoRemota']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      excluido: serializer.fromJson<bool>(json['excluido']),
      petId: serializer.fromJson<String>(json['petId']),
      tipo: serializer.fromJson<String>(json['tipo']),
      duracaoMin: serializer.fromJson<int>(json['duracaoMin']),
      dataHora: serializer.fromJson<DateTime>(json['dataHora']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'versao': serializer.toJson<int>(versao),
      'versaoRemota': serializer.toJson<int?>(versaoRemota),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'excluido': serializer.toJson<bool>(excluido),
      'petId': serializer.toJson<String>(petId),
      'tipo': serializer.toJson<String>(tipo),
      'duracaoMin': serializer.toJson<int>(duracaoMin),
      'dataHora': serializer.toJson<DateTime>(dataHora),
    };
  }

  AtividadeLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? versao,
    Value<int?> versaoRemota = const Value.absent(),
    String? estadoSync,
    bool? excluido,
    String? petId,
    String? tipo,
    int? duracaoMin,
    DateTime? dataHora,
  }) => AtividadeLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    versao: versao ?? this.versao,
    versaoRemota: versaoRemota.present ? versaoRemota.value : this.versaoRemota,
    estadoSync: estadoSync ?? this.estadoSync,
    excluido: excluido ?? this.excluido,
    petId: petId ?? this.petId,
    tipo: tipo ?? this.tipo,
    duracaoMin: duracaoMin ?? this.duracaoMin,
    dataHora: dataHora ?? this.dataHora,
  );
  AtividadeLinha copyWithCompanion(AtividadesCompanion data) {
    return AtividadeLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      versao: data.versao.present ? data.versao.value : this.versao,
      versaoRemota: data.versaoRemota.present
          ? data.versaoRemota.value
          : this.versaoRemota,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      excluido: data.excluido.present ? data.excluido.value : this.excluido,
      petId: data.petId.present ? data.petId.value : this.petId,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      duracaoMin: data.duracaoMin.present
          ? data.duracaoMin.value
          : this.duracaoMin,
      dataHora: data.dataHora.present ? data.dataHora.value : this.dataHora,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AtividadeLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('tipo: $tipo, ')
          ..write('duracaoMin: $duracaoMin, ')
          ..write('dataHora: $dataHora')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    tipo,
    duracaoMin,
    dataHora,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AtividadeLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.versao == this.versao &&
          other.versaoRemota == this.versaoRemota &&
          other.estadoSync == this.estadoSync &&
          other.excluido == this.excluido &&
          other.petId == this.petId &&
          other.tipo == this.tipo &&
          other.duracaoMin == this.duracaoMin &&
          other.dataHora == this.dataHora);
}

class AtividadesCompanion extends UpdateCompanion<AtividadeLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> versao;
  final Value<int?> versaoRemota;
  final Value<String> estadoSync;
  final Value<bool> excluido;
  final Value<String> petId;
  final Value<String> tipo;
  final Value<int> duracaoMin;
  final Value<DateTime> dataHora;
  final Value<int> rowid;
  const AtividadesCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    this.petId = const Value.absent(),
    this.tipo = const Value.absent(),
    this.duracaoMin = const Value.absent(),
    this.dataHora = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AtividadesCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    required String petId,
    required String tipo,
    required int duracaoMin,
    required DateTime dataHora,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       petId = Value(petId),
       tipo = Value(tipo),
       duracaoMin = Value(duracaoMin),
       dataHora = Value(dataHora);
  static Insertable<AtividadeLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? versao,
    Expression<int>? versaoRemota,
    Expression<String>? estadoSync,
    Expression<bool>? excluido,
    Expression<String>? petId,
    Expression<String>? tipo,
    Expression<int>? duracaoMin,
    Expression<DateTime>? dataHora,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (versao != null) 'versao': versao,
      if (versaoRemota != null) 'versao_remota': versaoRemota,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (excluido != null) 'excluido': excluido,
      if (petId != null) 'pet_id': petId,
      if (tipo != null) 'tipo': tipo,
      if (duracaoMin != null) 'duracao_min': duracaoMin,
      if (dataHora != null) 'data_hora': dataHora,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AtividadesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? versao,
    Value<int?>? versaoRemota,
    Value<String>? estadoSync,
    Value<bool>? excluido,
    Value<String>? petId,
    Value<String>? tipo,
    Value<int>? duracaoMin,
    Value<DateTime>? dataHora,
    Value<int>? rowid,
  }) {
    return AtividadesCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      versao: versao ?? this.versao,
      versaoRemota: versaoRemota ?? this.versaoRemota,
      estadoSync: estadoSync ?? this.estadoSync,
      excluido: excluido ?? this.excluido,
      petId: petId ?? this.petId,
      tipo: tipo ?? this.tipo,
      duracaoMin: duracaoMin ?? this.duracaoMin,
      dataHora: dataHora ?? this.dataHora,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (versao.present) {
      map['versao'] = Variable<int>(versao.value);
    }
    if (versaoRemota.present) {
      map['versao_remota'] = Variable<int>(versaoRemota.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (excluido.present) {
      map['excluido'] = Variable<bool>(excluido.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (duracaoMin.present) {
      map['duracao_min'] = Variable<int>(duracaoMin.value);
    }
    if (dataHora.present) {
      map['data_hora'] = Variable<DateTime>(dataHora.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AtividadesCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('tipo: $tipo, ')
          ..write('duracaoMin: $duracaoMin, ')
          ..write('dataHora: $dataHora, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LembretesTable extends Lembretes
    with TableInfo<$LembretesTable, LembreteLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LembretesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versaoMeta = const VerificationMeta('versao');
  @override
  late final GeneratedColumn<int> versao = GeneratedColumn<int>(
    'versao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _versaoRemotaMeta = const VerificationMeta(
    'versaoRemota',
  );
  @override
  late final GeneratedColumn<int> versaoRemota = GeneratedColumn<int>(
    'versao_remota',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _excluidoMeta = const VerificationMeta(
    'excluido',
  );
  @override
  late final GeneratedColumn<bool> excluido = GeneratedColumn<bool>(
    'excluido',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("excluido" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _horaMeta = const VerificationMeta('hora');
  @override
  late final GeneratedColumn<int> hora = GeneratedColumn<int>(
    'hora',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tipoMeta = const VerificationMeta('tipo');
  @override
  late final GeneratedColumn<String> tipo = GeneratedColumn<String>(
    'tipo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ativoMeta = const VerificationMeta('ativo');
  @override
  late final GeneratedColumn<bool> ativo = GeneratedColumn<bool>(
    'ativo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("ativo" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _notificacaoIdMeta = const VerificationMeta(
    'notificacaoId',
  );
  @override
  late final GeneratedColumn<int> notificacaoId = GeneratedColumn<int>(
    'notificacao_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    hora,
    tipo,
    ativo,
    notificacaoId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lembretes';
  @override
  VerificationContext validateIntegrity(
    Insertable<LembreteLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('versao')) {
      context.handle(
        _versaoMeta,
        versao.isAcceptableOrUnknown(data['versao']!, _versaoMeta),
      );
    }
    if (data.containsKey('versao_remota')) {
      context.handle(
        _versaoRemotaMeta,
        versaoRemota.isAcceptableOrUnknown(
          data['versao_remota']!,
          _versaoRemotaMeta,
        ),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('excluido')) {
      context.handle(
        _excluidoMeta,
        excluido.isAcceptableOrUnknown(data['excluido']!, _excluidoMeta),
      );
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('hora')) {
      context.handle(
        _horaMeta,
        hora.isAcceptableOrUnknown(data['hora']!, _horaMeta),
      );
    } else if (isInserting) {
      context.missing(_horaMeta);
    }
    if (data.containsKey('tipo')) {
      context.handle(
        _tipoMeta,
        tipo.isAcceptableOrUnknown(data['tipo']!, _tipoMeta),
      );
    } else if (isInserting) {
      context.missing(_tipoMeta);
    }
    if (data.containsKey('ativo')) {
      context.handle(
        _ativoMeta,
        ativo.isAcceptableOrUnknown(data['ativo']!, _ativoMeta),
      );
    }
    if (data.containsKey('notificacao_id')) {
      context.handle(
        _notificacaoIdMeta,
        notificacaoId.isAcceptableOrUnknown(
          data['notificacao_id']!,
          _notificacaoIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificacaoIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LembreteLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LembreteLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      versao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao'],
      )!,
      versaoRemota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao_remota'],
      ),
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      excluido: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}excluido'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      hora: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hora'],
      )!,
      tipo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tipo'],
      )!,
      ativo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}ativo'],
      )!,
      notificacaoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notificacao_id'],
      )!,
    );
  }

  @override
  $LembretesTable createAlias(String alias) {
    return $LembretesTable(attachedDatabase, alias);
  }
}

class LembreteLinha extends DataClass implements Insertable<LembreteLinha> {
  /// UUID v4 gerado no aparelho e reutilizado como ID do documento no
  /// Firestore.
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// Começa em 1 e soma 1 a cada alteração local.
  final int versao;

  /// Última versão confirmada no Firestore (`null` = nunca enviado).
  final int? versaoRemota;

  /// `local` (cópia desligada), `pendente`, `sincronizado`, `falha`,
  /// `conflito`.
  final String estadoSync;

  /// Lápide. As consultas da UI sempre filtram `excluido = false`.
  final bool excluido;
  final String petId;
  final int hora;
  final String tipo;
  final bool ativo;
  final int notificacaoId;
  const LembreteLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.versao,
    this.versaoRemota,
    required this.estadoSync,
    required this.excluido,
    required this.petId,
    required this.hora,
    required this.tipo,
    required this.ativo,
    required this.notificacaoId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['versao'] = Variable<int>(versao);
    if (!nullToAbsent || versaoRemota != null) {
      map['versao_remota'] = Variable<int>(versaoRemota);
    }
    map['estado_sync'] = Variable<String>(estadoSync);
    map['excluido'] = Variable<bool>(excluido);
    map['pet_id'] = Variable<String>(petId);
    map['hora'] = Variable<int>(hora);
    map['tipo'] = Variable<String>(tipo);
    map['ativo'] = Variable<bool>(ativo);
    map['notificacao_id'] = Variable<int>(notificacaoId);
    return map;
  }

  LembretesCompanion toCompanion(bool nullToAbsent) {
    return LembretesCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      versao: Value(versao),
      versaoRemota: versaoRemota == null && nullToAbsent
          ? const Value.absent()
          : Value(versaoRemota),
      estadoSync: Value(estadoSync),
      excluido: Value(excluido),
      petId: Value(petId),
      hora: Value(hora),
      tipo: Value(tipo),
      ativo: Value(ativo),
      notificacaoId: Value(notificacaoId),
    );
  }

  factory LembreteLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LembreteLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      versao: serializer.fromJson<int>(json['versao']),
      versaoRemota: serializer.fromJson<int?>(json['versaoRemota']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      excluido: serializer.fromJson<bool>(json['excluido']),
      petId: serializer.fromJson<String>(json['petId']),
      hora: serializer.fromJson<int>(json['hora']),
      tipo: serializer.fromJson<String>(json['tipo']),
      ativo: serializer.fromJson<bool>(json['ativo']),
      notificacaoId: serializer.fromJson<int>(json['notificacaoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'versao': serializer.toJson<int>(versao),
      'versaoRemota': serializer.toJson<int?>(versaoRemota),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'excluido': serializer.toJson<bool>(excluido),
      'petId': serializer.toJson<String>(petId),
      'hora': serializer.toJson<int>(hora),
      'tipo': serializer.toJson<String>(tipo),
      'ativo': serializer.toJson<bool>(ativo),
      'notificacaoId': serializer.toJson<int>(notificacaoId),
    };
  }

  LembreteLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? versao,
    Value<int?> versaoRemota = const Value.absent(),
    String? estadoSync,
    bool? excluido,
    String? petId,
    int? hora,
    String? tipo,
    bool? ativo,
    int? notificacaoId,
  }) => LembreteLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    versao: versao ?? this.versao,
    versaoRemota: versaoRemota.present ? versaoRemota.value : this.versaoRemota,
    estadoSync: estadoSync ?? this.estadoSync,
    excluido: excluido ?? this.excluido,
    petId: petId ?? this.petId,
    hora: hora ?? this.hora,
    tipo: tipo ?? this.tipo,
    ativo: ativo ?? this.ativo,
    notificacaoId: notificacaoId ?? this.notificacaoId,
  );
  LembreteLinha copyWithCompanion(LembretesCompanion data) {
    return LembreteLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      versao: data.versao.present ? data.versao.value : this.versao,
      versaoRemota: data.versaoRemota.present
          ? data.versaoRemota.value
          : this.versaoRemota,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      excluido: data.excluido.present ? data.excluido.value : this.excluido,
      petId: data.petId.present ? data.petId.value : this.petId,
      hora: data.hora.present ? data.hora.value : this.hora,
      tipo: data.tipo.present ? data.tipo.value : this.tipo,
      ativo: data.ativo.present ? data.ativo.value : this.ativo,
      notificacaoId: data.notificacaoId.present
          ? data.notificacaoId.value
          : this.notificacaoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LembreteLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('hora: $hora, ')
          ..write('tipo: $tipo, ')
          ..write('ativo: $ativo, ')
          ..write('notificacaoId: $notificacaoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    hora,
    tipo,
    ativo,
    notificacaoId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LembreteLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.versao == this.versao &&
          other.versaoRemota == this.versaoRemota &&
          other.estadoSync == this.estadoSync &&
          other.excluido == this.excluido &&
          other.petId == this.petId &&
          other.hora == this.hora &&
          other.tipo == this.tipo &&
          other.ativo == this.ativo &&
          other.notificacaoId == this.notificacaoId);
}

class LembretesCompanion extends UpdateCompanion<LembreteLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> versao;
  final Value<int?> versaoRemota;
  final Value<String> estadoSync;
  final Value<bool> excluido;
  final Value<String> petId;
  final Value<int> hora;
  final Value<String> tipo;
  final Value<bool> ativo;
  final Value<int> notificacaoId;
  final Value<int> rowid;
  const LembretesCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    this.petId = const Value.absent(),
    this.hora = const Value.absent(),
    this.tipo = const Value.absent(),
    this.ativo = const Value.absent(),
    this.notificacaoId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LembretesCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    required String petId,
    required int hora,
    required String tipo,
    this.ativo = const Value.absent(),
    required int notificacaoId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       petId = Value(petId),
       hora = Value(hora),
       tipo = Value(tipo),
       notificacaoId = Value(notificacaoId);
  static Insertable<LembreteLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? versao,
    Expression<int>? versaoRemota,
    Expression<String>? estadoSync,
    Expression<bool>? excluido,
    Expression<String>? petId,
    Expression<int>? hora,
    Expression<String>? tipo,
    Expression<bool>? ativo,
    Expression<int>? notificacaoId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (versao != null) 'versao': versao,
      if (versaoRemota != null) 'versao_remota': versaoRemota,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (excluido != null) 'excluido': excluido,
      if (petId != null) 'pet_id': petId,
      if (hora != null) 'hora': hora,
      if (tipo != null) 'tipo': tipo,
      if (ativo != null) 'ativo': ativo,
      if (notificacaoId != null) 'notificacao_id': notificacaoId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LembretesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? versao,
    Value<int?>? versaoRemota,
    Value<String>? estadoSync,
    Value<bool>? excluido,
    Value<String>? petId,
    Value<int>? hora,
    Value<String>? tipo,
    Value<bool>? ativo,
    Value<int>? notificacaoId,
    Value<int>? rowid,
  }) {
    return LembretesCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      versao: versao ?? this.versao,
      versaoRemota: versaoRemota ?? this.versaoRemota,
      estadoSync: estadoSync ?? this.estadoSync,
      excluido: excluido ?? this.excluido,
      petId: petId ?? this.petId,
      hora: hora ?? this.hora,
      tipo: tipo ?? this.tipo,
      ativo: ativo ?? this.ativo,
      notificacaoId: notificacaoId ?? this.notificacaoId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (versao.present) {
      map['versao'] = Variable<int>(versao.value);
    }
    if (versaoRemota.present) {
      map['versao_remota'] = Variable<int>(versaoRemota.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (excluido.present) {
      map['excluido'] = Variable<bool>(excluido.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (hora.present) {
      map['hora'] = Variable<int>(hora.value);
    }
    if (tipo.present) {
      map['tipo'] = Variable<String>(tipo.value);
    }
    if (ativo.present) {
      map['ativo'] = Variable<bool>(ativo.value);
    }
    if (notificacaoId.present) {
      map['notificacao_id'] = Variable<int>(notificacaoId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LembretesCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('hora: $hora, ')
          ..write('tipo: $tipo, ')
          ..write('ativo: $ativo, ')
          ..write('notificacaoId: $notificacaoId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PesagensTable extends Pesagens
    with TableInfo<$PesagensTable, PesagemLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PesagensTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versaoMeta = const VerificationMeta('versao');
  @override
  late final GeneratedColumn<int> versao = GeneratedColumn<int>(
    'versao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _versaoRemotaMeta = const VerificationMeta(
    'versaoRemota',
  );
  @override
  late final GeneratedColumn<int> versaoRemota = GeneratedColumn<int>(
    'versao_remota',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _excluidoMeta = const VerificationMeta(
    'excluido',
  );
  @override
  late final GeneratedColumn<bool> excluido = GeneratedColumn<bool>(
    'excluido',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("excluido" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _pesoKgMeta = const VerificationMeta('pesoKg');
  @override
  late final GeneratedColumn<double> pesoKg = GeneratedColumn<double>(
    'peso_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataHoraMeta = const VerificationMeta(
    'dataHora',
  );
  @override
  late final GeneratedColumn<DateTime> dataHora = GeneratedColumn<DateTime>(
    'data_hora',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _conferidaMeta = const VerificationMeta(
    'conferida',
  );
  @override
  late final GeneratedColumn<bool> conferida = GeneratedColumn<bool>(
    'conferida',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("conferida" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    pesoKg,
    dataHora,
    conferida,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pesagens';
  @override
  VerificationContext validateIntegrity(
    Insertable<PesagemLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('versao')) {
      context.handle(
        _versaoMeta,
        versao.isAcceptableOrUnknown(data['versao']!, _versaoMeta),
      );
    }
    if (data.containsKey('versao_remota')) {
      context.handle(
        _versaoRemotaMeta,
        versaoRemota.isAcceptableOrUnknown(
          data['versao_remota']!,
          _versaoRemotaMeta,
        ),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('excluido')) {
      context.handle(
        _excluidoMeta,
        excluido.isAcceptableOrUnknown(data['excluido']!, _excluidoMeta),
      );
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('peso_kg')) {
      context.handle(
        _pesoKgMeta,
        pesoKg.isAcceptableOrUnknown(data['peso_kg']!, _pesoKgMeta),
      );
    } else if (isInserting) {
      context.missing(_pesoKgMeta);
    }
    if (data.containsKey('data_hora')) {
      context.handle(
        _dataHoraMeta,
        dataHora.isAcceptableOrUnknown(data['data_hora']!, _dataHoraMeta),
      );
    } else if (isInserting) {
      context.missing(_dataHoraMeta);
    }
    if (data.containsKey('conferida')) {
      context.handle(
        _conferidaMeta,
        conferida.isAcceptableOrUnknown(data['conferida']!, _conferidaMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PesagemLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PesagemLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      versao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao'],
      )!,
      versaoRemota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao_remota'],
      ),
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      excluido: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}excluido'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      pesoKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peso_kg'],
      )!,
      dataHora: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data_hora'],
      )!,
      conferida: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}conferida'],
      )!,
    );
  }

  @override
  $PesagensTable createAlias(String alias) {
    return $PesagensTable(attachedDatabase, alias);
  }
}

class PesagemLinha extends DataClass implements Insertable<PesagemLinha> {
  /// UUID v4 gerado no aparelho e reutilizado como ID do documento no
  /// Firestore.
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// Começa em 1 e soma 1 a cada alteração local.
  final int versao;

  /// Última versão confirmada no Firestore (`null` = nunca enviado).
  final int? versaoRemota;

  /// `local` (cópia desligada), `pendente`, `sincronizado`, `falha`,
  /// `conflito`.
  final String estadoSync;

  /// Lápide. As consultas da UI sempre filtram `excluido = false`.
  final bool excluido;
  final String petId;
  final double pesoKg;
  final DateTime dataHora;
  final bool conferida;
  const PesagemLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.versao,
    this.versaoRemota,
    required this.estadoSync,
    required this.excluido,
    required this.petId,
    required this.pesoKg,
    required this.dataHora,
    required this.conferida,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['versao'] = Variable<int>(versao);
    if (!nullToAbsent || versaoRemota != null) {
      map['versao_remota'] = Variable<int>(versaoRemota);
    }
    map['estado_sync'] = Variable<String>(estadoSync);
    map['excluido'] = Variable<bool>(excluido);
    map['pet_id'] = Variable<String>(petId);
    map['peso_kg'] = Variable<double>(pesoKg);
    map['data_hora'] = Variable<DateTime>(dataHora);
    map['conferida'] = Variable<bool>(conferida);
    return map;
  }

  PesagensCompanion toCompanion(bool nullToAbsent) {
    return PesagensCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      versao: Value(versao),
      versaoRemota: versaoRemota == null && nullToAbsent
          ? const Value.absent()
          : Value(versaoRemota),
      estadoSync: Value(estadoSync),
      excluido: Value(excluido),
      petId: Value(petId),
      pesoKg: Value(pesoKg),
      dataHora: Value(dataHora),
      conferida: Value(conferida),
    );
  }

  factory PesagemLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PesagemLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      versao: serializer.fromJson<int>(json['versao']),
      versaoRemota: serializer.fromJson<int?>(json['versaoRemota']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      excluido: serializer.fromJson<bool>(json['excluido']),
      petId: serializer.fromJson<String>(json['petId']),
      pesoKg: serializer.fromJson<double>(json['pesoKg']),
      dataHora: serializer.fromJson<DateTime>(json['dataHora']),
      conferida: serializer.fromJson<bool>(json['conferida']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'versao': serializer.toJson<int>(versao),
      'versaoRemota': serializer.toJson<int?>(versaoRemota),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'excluido': serializer.toJson<bool>(excluido),
      'petId': serializer.toJson<String>(petId),
      'pesoKg': serializer.toJson<double>(pesoKg),
      'dataHora': serializer.toJson<DateTime>(dataHora),
      'conferida': serializer.toJson<bool>(conferida),
    };
  }

  PesagemLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? versao,
    Value<int?> versaoRemota = const Value.absent(),
    String? estadoSync,
    bool? excluido,
    String? petId,
    double? pesoKg,
    DateTime? dataHora,
    bool? conferida,
  }) => PesagemLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    versao: versao ?? this.versao,
    versaoRemota: versaoRemota.present ? versaoRemota.value : this.versaoRemota,
    estadoSync: estadoSync ?? this.estadoSync,
    excluido: excluido ?? this.excluido,
    petId: petId ?? this.petId,
    pesoKg: pesoKg ?? this.pesoKg,
    dataHora: dataHora ?? this.dataHora,
    conferida: conferida ?? this.conferida,
  );
  PesagemLinha copyWithCompanion(PesagensCompanion data) {
    return PesagemLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      versao: data.versao.present ? data.versao.value : this.versao,
      versaoRemota: data.versaoRemota.present
          ? data.versaoRemota.value
          : this.versaoRemota,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      excluido: data.excluido.present ? data.excluido.value : this.excluido,
      petId: data.petId.present ? data.petId.value : this.petId,
      pesoKg: data.pesoKg.present ? data.pesoKg.value : this.pesoKg,
      dataHora: data.dataHora.present ? data.dataHora.value : this.dataHora,
      conferida: data.conferida.present ? data.conferida.value : this.conferida,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PesagemLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('pesoKg: $pesoKg, ')
          ..write('dataHora: $dataHora, ')
          ..write('conferida: $conferida')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    pesoKg,
    dataHora,
    conferida,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PesagemLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.versao == this.versao &&
          other.versaoRemota == this.versaoRemota &&
          other.estadoSync == this.estadoSync &&
          other.excluido == this.excluido &&
          other.petId == this.petId &&
          other.pesoKg == this.pesoKg &&
          other.dataHora == this.dataHora &&
          other.conferida == this.conferida);
}

class PesagensCompanion extends UpdateCompanion<PesagemLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> versao;
  final Value<int?> versaoRemota;
  final Value<String> estadoSync;
  final Value<bool> excluido;
  final Value<String> petId;
  final Value<double> pesoKg;
  final Value<DateTime> dataHora;
  final Value<bool> conferida;
  final Value<int> rowid;
  const PesagensCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    this.petId = const Value.absent(),
    this.pesoKg = const Value.absent(),
    this.dataHora = const Value.absent(),
    this.conferida = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PesagensCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    required String petId,
    required double pesoKg,
    required DateTime dataHora,
    this.conferida = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       petId = Value(petId),
       pesoKg = Value(pesoKg),
       dataHora = Value(dataHora);
  static Insertable<PesagemLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? versao,
    Expression<int>? versaoRemota,
    Expression<String>? estadoSync,
    Expression<bool>? excluido,
    Expression<String>? petId,
    Expression<double>? pesoKg,
    Expression<DateTime>? dataHora,
    Expression<bool>? conferida,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (versao != null) 'versao': versao,
      if (versaoRemota != null) 'versao_remota': versaoRemota,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (excluido != null) 'excluido': excluido,
      if (petId != null) 'pet_id': petId,
      if (pesoKg != null) 'peso_kg': pesoKg,
      if (dataHora != null) 'data_hora': dataHora,
      if (conferida != null) 'conferida': conferida,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PesagensCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? versao,
    Value<int?>? versaoRemota,
    Value<String>? estadoSync,
    Value<bool>? excluido,
    Value<String>? petId,
    Value<double>? pesoKg,
    Value<DateTime>? dataHora,
    Value<bool>? conferida,
    Value<int>? rowid,
  }) {
    return PesagensCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      versao: versao ?? this.versao,
      versaoRemota: versaoRemota ?? this.versaoRemota,
      estadoSync: estadoSync ?? this.estadoSync,
      excluido: excluido ?? this.excluido,
      petId: petId ?? this.petId,
      pesoKg: pesoKg ?? this.pesoKg,
      dataHora: dataHora ?? this.dataHora,
      conferida: conferida ?? this.conferida,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (versao.present) {
      map['versao'] = Variable<int>(versao.value);
    }
    if (versaoRemota.present) {
      map['versao_remota'] = Variable<int>(versaoRemota.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (excluido.present) {
      map['excluido'] = Variable<bool>(excluido.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (pesoKg.present) {
      map['peso_kg'] = Variable<double>(pesoKg.value);
    }
    if (dataHora.present) {
      map['data_hora'] = Variable<DateTime>(dataHora.value);
    }
    if (conferida.present) {
      map['conferida'] = Variable<bool>(conferida.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PesagensCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('pesoKg: $pesoKg, ')
          ..write('dataHora: $dataHora, ')
          ..write('conferida: $conferida, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReferenciasTable extends Referencias
    with TableInfo<$ReferenciasTable, ReferenciaLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReferenciasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _atualizadoEmMeta = const VerificationMeta(
    'atualizadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> atualizadoEm = GeneratedColumn<DateTime>(
    'atualizado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versaoMeta = const VerificationMeta('versao');
  @override
  late final GeneratedColumn<int> versao = GeneratedColumn<int>(
    'versao',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _versaoRemotaMeta = const VerificationMeta(
    'versaoRemota',
  );
  @override
  late final GeneratedColumn<int> versaoRemota = GeneratedColumn<int>(
    'versao_remota',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estadoSyncMeta = const VerificationMeta(
    'estadoSync',
  );
  @override
  late final GeneratedColumn<String> estadoSync = GeneratedColumn<String>(
    'estado_sync',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('local'),
  );
  static const VerificationMeta _excluidoMeta = const VerificationMeta(
    'excluido',
  );
  @override
  late final GeneratedColumn<bool> excluido = GeneratedColumn<bool>(
    'excluido',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("excluido" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _petIdMeta = const VerificationMeta('petId');
  @override
  late final GeneratedColumn<String> petId = GeneratedColumn<String>(
    'pet_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES pets (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _eccMeta = const VerificationMeta('ecc');
  @override
  late final GeneratedColumn<int> ecc = GeneratedColumn<int>(
    'ecc',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _objetivoKgMeta = const VerificationMeta(
    'objetivoKg',
  );
  @override
  late final GeneratedColumn<double> objetivoKg = GeneratedColumn<double>(
    'objetivo_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _origemMeta = const VerificationMeta('origem');
  @override
  late final GeneratedColumn<String> origem = GeneratedColumn<String>(
    'origem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<DateTime> data = GeneratedColumn<DateTime>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    ecc,
    objetivoKg,
    origem,
    data,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'referencias';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReferenciaLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('atualizado_em')) {
      context.handle(
        _atualizadoEmMeta,
        atualizadoEm.isAcceptableOrUnknown(
          data['atualizado_em']!,
          _atualizadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_atualizadoEmMeta);
    }
    if (data.containsKey('versao')) {
      context.handle(
        _versaoMeta,
        versao.isAcceptableOrUnknown(data['versao']!, _versaoMeta),
      );
    }
    if (data.containsKey('versao_remota')) {
      context.handle(
        _versaoRemotaMeta,
        versaoRemota.isAcceptableOrUnknown(
          data['versao_remota']!,
          _versaoRemotaMeta,
        ),
      );
    }
    if (data.containsKey('estado_sync')) {
      context.handle(
        _estadoSyncMeta,
        estadoSync.isAcceptableOrUnknown(data['estado_sync']!, _estadoSyncMeta),
      );
    }
    if (data.containsKey('excluido')) {
      context.handle(
        _excluidoMeta,
        excluido.isAcceptableOrUnknown(data['excluido']!, _excluidoMeta),
      );
    }
    if (data.containsKey('pet_id')) {
      context.handle(
        _petIdMeta,
        petId.isAcceptableOrUnknown(data['pet_id']!, _petIdMeta),
      );
    } else if (isInserting) {
      context.missing(_petIdMeta);
    }
    if (data.containsKey('ecc')) {
      context.handle(
        _eccMeta,
        ecc.isAcceptableOrUnknown(data['ecc']!, _eccMeta),
      );
    }
    if (data.containsKey('objetivo_kg')) {
      context.handle(
        _objetivoKgMeta,
        objetivoKg.isAcceptableOrUnknown(data['objetivo_kg']!, _objetivoKgMeta),
      );
    }
    if (data.containsKey('origem')) {
      context.handle(
        _origemMeta,
        origem.isAcceptableOrUnknown(data['origem']!, _origemMeta),
      );
    } else if (isInserting) {
      context.missing(_origemMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReferenciaLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReferenciaLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      atualizadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}atualizado_em'],
      )!,
      versao: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao'],
      )!,
      versaoRemota: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}versao_remota'],
      ),
      estadoSync: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}estado_sync'],
      )!,
      excluido: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}excluido'],
      )!,
      petId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pet_id'],
      )!,
      ecc: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ecc'],
      ),
      objetivoKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}objetivo_kg'],
      ),
      origem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}origem'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $ReferenciasTable createAlias(String alias) {
    return $ReferenciasTable(attachedDatabase, alias);
  }
}

class ReferenciaLinha extends DataClass implements Insertable<ReferenciaLinha> {
  /// UUID v4 gerado no aparelho e reutilizado como ID do documento no
  /// Firestore.
  final String id;
  final DateTime criadoEm;
  final DateTime atualizadoEm;

  /// Começa em 1 e soma 1 a cada alteração local.
  final int versao;

  /// Última versão confirmada no Firestore (`null` = nunca enviado).
  final int? versaoRemota;

  /// `local` (cópia desligada), `pendente`, `sincronizado`, `falha`,
  /// `conflito`.
  final String estadoSync;

  /// Lápide. As consultas da UI sempre filtram `excluido = false`.
  final bool excluido;
  final String petId;
  final int? ecc;
  final double? objetivoKg;
  final String origem;
  final DateTime data;
  const ReferenciaLinha({
    required this.id,
    required this.criadoEm,
    required this.atualizadoEm,
    required this.versao,
    this.versaoRemota,
    required this.estadoSync,
    required this.excluido,
    required this.petId,
    this.ecc,
    this.objetivoKg,
    required this.origem,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['atualizado_em'] = Variable<DateTime>(atualizadoEm);
    map['versao'] = Variable<int>(versao);
    if (!nullToAbsent || versaoRemota != null) {
      map['versao_remota'] = Variable<int>(versaoRemota);
    }
    map['estado_sync'] = Variable<String>(estadoSync);
    map['excluido'] = Variable<bool>(excluido);
    map['pet_id'] = Variable<String>(petId);
    if (!nullToAbsent || ecc != null) {
      map['ecc'] = Variable<int>(ecc);
    }
    if (!nullToAbsent || objetivoKg != null) {
      map['objetivo_kg'] = Variable<double>(objetivoKg);
    }
    map['origem'] = Variable<String>(origem);
    map['data'] = Variable<DateTime>(data);
    return map;
  }

  ReferenciasCompanion toCompanion(bool nullToAbsent) {
    return ReferenciasCompanion(
      id: Value(id),
      criadoEm: Value(criadoEm),
      atualizadoEm: Value(atualizadoEm),
      versao: Value(versao),
      versaoRemota: versaoRemota == null && nullToAbsent
          ? const Value.absent()
          : Value(versaoRemota),
      estadoSync: Value(estadoSync),
      excluido: Value(excluido),
      petId: Value(petId),
      ecc: ecc == null && nullToAbsent ? const Value.absent() : Value(ecc),
      objetivoKg: objetivoKg == null && nullToAbsent
          ? const Value.absent()
          : Value(objetivoKg),
      origem: Value(origem),
      data: Value(data),
    );
  }

  factory ReferenciaLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReferenciaLinha(
      id: serializer.fromJson<String>(json['id']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      atualizadoEm: serializer.fromJson<DateTime>(json['atualizadoEm']),
      versao: serializer.fromJson<int>(json['versao']),
      versaoRemota: serializer.fromJson<int?>(json['versaoRemota']),
      estadoSync: serializer.fromJson<String>(json['estadoSync']),
      excluido: serializer.fromJson<bool>(json['excluido']),
      petId: serializer.fromJson<String>(json['petId']),
      ecc: serializer.fromJson<int?>(json['ecc']),
      objetivoKg: serializer.fromJson<double?>(json['objetivoKg']),
      origem: serializer.fromJson<String>(json['origem']),
      data: serializer.fromJson<DateTime>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'atualizadoEm': serializer.toJson<DateTime>(atualizadoEm),
      'versao': serializer.toJson<int>(versao),
      'versaoRemota': serializer.toJson<int?>(versaoRemota),
      'estadoSync': serializer.toJson<String>(estadoSync),
      'excluido': serializer.toJson<bool>(excluido),
      'petId': serializer.toJson<String>(petId),
      'ecc': serializer.toJson<int?>(ecc),
      'objetivoKg': serializer.toJson<double?>(objetivoKg),
      'origem': serializer.toJson<String>(origem),
      'data': serializer.toJson<DateTime>(data),
    };
  }

  ReferenciaLinha copyWith({
    String? id,
    DateTime? criadoEm,
    DateTime? atualizadoEm,
    int? versao,
    Value<int?> versaoRemota = const Value.absent(),
    String? estadoSync,
    bool? excluido,
    String? petId,
    Value<int?> ecc = const Value.absent(),
    Value<double?> objetivoKg = const Value.absent(),
    String? origem,
    DateTime? data,
  }) => ReferenciaLinha(
    id: id ?? this.id,
    criadoEm: criadoEm ?? this.criadoEm,
    atualizadoEm: atualizadoEm ?? this.atualizadoEm,
    versao: versao ?? this.versao,
    versaoRemota: versaoRemota.present ? versaoRemota.value : this.versaoRemota,
    estadoSync: estadoSync ?? this.estadoSync,
    excluido: excluido ?? this.excluido,
    petId: petId ?? this.petId,
    ecc: ecc.present ? ecc.value : this.ecc,
    objetivoKg: objetivoKg.present ? objetivoKg.value : this.objetivoKg,
    origem: origem ?? this.origem,
    data: data ?? this.data,
  );
  ReferenciaLinha copyWithCompanion(ReferenciasCompanion data) {
    return ReferenciaLinha(
      id: data.id.present ? data.id.value : this.id,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      atualizadoEm: data.atualizadoEm.present
          ? data.atualizadoEm.value
          : this.atualizadoEm,
      versao: data.versao.present ? data.versao.value : this.versao,
      versaoRemota: data.versaoRemota.present
          ? data.versaoRemota.value
          : this.versaoRemota,
      estadoSync: data.estadoSync.present
          ? data.estadoSync.value
          : this.estadoSync,
      excluido: data.excluido.present ? data.excluido.value : this.excluido,
      petId: data.petId.present ? data.petId.value : this.petId,
      ecc: data.ecc.present ? data.ecc.value : this.ecc,
      objetivoKg: data.objetivoKg.present
          ? data.objetivoKg.value
          : this.objetivoKg,
      origem: data.origem.present ? data.origem.value : this.origem,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReferenciaLinha(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('ecc: $ecc, ')
          ..write('objetivoKg: $objetivoKg, ')
          ..write('origem: $origem, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    criadoEm,
    atualizadoEm,
    versao,
    versaoRemota,
    estadoSync,
    excluido,
    petId,
    ecc,
    objetivoKg,
    origem,
    data,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReferenciaLinha &&
          other.id == this.id &&
          other.criadoEm == this.criadoEm &&
          other.atualizadoEm == this.atualizadoEm &&
          other.versao == this.versao &&
          other.versaoRemota == this.versaoRemota &&
          other.estadoSync == this.estadoSync &&
          other.excluido == this.excluido &&
          other.petId == this.petId &&
          other.ecc == this.ecc &&
          other.objetivoKg == this.objetivoKg &&
          other.origem == this.origem &&
          other.data == this.data);
}

class ReferenciasCompanion extends UpdateCompanion<ReferenciaLinha> {
  final Value<String> id;
  final Value<DateTime> criadoEm;
  final Value<DateTime> atualizadoEm;
  final Value<int> versao;
  final Value<int?> versaoRemota;
  final Value<String> estadoSync;
  final Value<bool> excluido;
  final Value<String> petId;
  final Value<int?> ecc;
  final Value<double?> objetivoKg;
  final Value<String> origem;
  final Value<DateTime> data;
  final Value<int> rowid;
  const ReferenciasCompanion({
    this.id = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.atualizadoEm = const Value.absent(),
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    this.petId = const Value.absent(),
    this.ecc = const Value.absent(),
    this.objetivoKg = const Value.absent(),
    this.origem = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReferenciasCompanion.insert({
    required String id,
    required DateTime criadoEm,
    required DateTime atualizadoEm,
    this.versao = const Value.absent(),
    this.versaoRemota = const Value.absent(),
    this.estadoSync = const Value.absent(),
    this.excluido = const Value.absent(),
    required String petId,
    this.ecc = const Value.absent(),
    this.objetivoKg = const Value.absent(),
    required String origem,
    required DateTime data,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       criadoEm = Value(criadoEm),
       atualizadoEm = Value(atualizadoEm),
       petId = Value(petId),
       origem = Value(origem),
       data = Value(data);
  static Insertable<ReferenciaLinha> custom({
    Expression<String>? id,
    Expression<DateTime>? criadoEm,
    Expression<DateTime>? atualizadoEm,
    Expression<int>? versao,
    Expression<int>? versaoRemota,
    Expression<String>? estadoSync,
    Expression<bool>? excluido,
    Expression<String>? petId,
    Expression<int>? ecc,
    Expression<double>? objetivoKg,
    Expression<String>? origem,
    Expression<DateTime>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (atualizadoEm != null) 'atualizado_em': atualizadoEm,
      if (versao != null) 'versao': versao,
      if (versaoRemota != null) 'versao_remota': versaoRemota,
      if (estadoSync != null) 'estado_sync': estadoSync,
      if (excluido != null) 'excluido': excluido,
      if (petId != null) 'pet_id': petId,
      if (ecc != null) 'ecc': ecc,
      if (objetivoKg != null) 'objetivo_kg': objetivoKg,
      if (origem != null) 'origem': origem,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReferenciasCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? criadoEm,
    Value<DateTime>? atualizadoEm,
    Value<int>? versao,
    Value<int?>? versaoRemota,
    Value<String>? estadoSync,
    Value<bool>? excluido,
    Value<String>? petId,
    Value<int?>? ecc,
    Value<double?>? objetivoKg,
    Value<String>? origem,
    Value<DateTime>? data,
    Value<int>? rowid,
  }) {
    return ReferenciasCompanion(
      id: id ?? this.id,
      criadoEm: criadoEm ?? this.criadoEm,
      atualizadoEm: atualizadoEm ?? this.atualizadoEm,
      versao: versao ?? this.versao,
      versaoRemota: versaoRemota ?? this.versaoRemota,
      estadoSync: estadoSync ?? this.estadoSync,
      excluido: excluido ?? this.excluido,
      petId: petId ?? this.petId,
      ecc: ecc ?? this.ecc,
      objetivoKg: objetivoKg ?? this.objetivoKg,
      origem: origem ?? this.origem,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (atualizadoEm.present) {
      map['atualizado_em'] = Variable<DateTime>(atualizadoEm.value);
    }
    if (versao.present) {
      map['versao'] = Variable<int>(versao.value);
    }
    if (versaoRemota.present) {
      map['versao_remota'] = Variable<int>(versaoRemota.value);
    }
    if (estadoSync.present) {
      map['estado_sync'] = Variable<String>(estadoSync.value);
    }
    if (excluido.present) {
      map['excluido'] = Variable<bool>(excluido.value);
    }
    if (petId.present) {
      map['pet_id'] = Variable<String>(petId.value);
    }
    if (ecc.present) {
      map['ecc'] = Variable<int>(ecc.value);
    }
    if (objetivoKg.present) {
      map['objetivo_kg'] = Variable<double>(objetivoKg.value);
    }
    if (origem.present) {
      map['origem'] = Variable<String>(origem.value);
    }
    if (data.present) {
      map['data'] = Variable<DateTime>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReferenciasCompanion(')
          ..write('id: $id, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('atualizadoEm: $atualizadoEm, ')
          ..write('versao: $versao, ')
          ..write('versaoRemota: $versaoRemota, ')
          ..write('estadoSync: $estadoSync, ')
          ..write('excluido: $excluido, ')
          ..write('petId: $petId, ')
          ..write('ecc: $ecc, ')
          ..write('objetivoKg: $objetivoKg, ')
          ..write('origem: $origem, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ItensFilaSyncTable extends ItensFilaSync
    with TableInfo<$ItensFilaSyncTable, FilaSyncLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ItensFilaSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _tabelaMeta = const VerificationMeta('tabela');
  @override
  late final GeneratedColumn<String> tabela = GeneratedColumn<String>(
    'tabela',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registroIdMeta = const VerificationMeta(
    'registroId',
  );
  @override
  late final GeneratedColumn<String> registroId = GeneratedColumn<String>(
    'registro_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operacaoMeta = const VerificationMeta(
    'operacao',
  );
  @override
  late final GeneratedColumn<String> operacao = GeneratedColumn<String>(
    'operacao',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _criadoEmMeta = const VerificationMeta(
    'criadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> criadoEm = GeneratedColumn<DateTime>(
    'criado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tentativasMeta = const VerificationMeta(
    'tentativas',
  );
  @override
  late final GeneratedColumn<int> tentativas = GeneratedColumn<int>(
    'tentativas',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ultimoErroMeta = const VerificationMeta(
    'ultimoErro',
  );
  @override
  late final GeneratedColumn<String> ultimoErro = GeneratedColumn<String>(
    'ultimo_erro',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tabela,
    registroId,
    operacao,
    criadoEm,
    tentativas,
    ultimoErro,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fila_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<FilaSyncLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('tabela')) {
      context.handle(
        _tabelaMeta,
        tabela.isAcceptableOrUnknown(data['tabela']!, _tabelaMeta),
      );
    } else if (isInserting) {
      context.missing(_tabelaMeta);
    }
    if (data.containsKey('registro_id')) {
      context.handle(
        _registroIdMeta,
        registroId.isAcceptableOrUnknown(data['registro_id']!, _registroIdMeta),
      );
    } else if (isInserting) {
      context.missing(_registroIdMeta);
    }
    if (data.containsKey('operacao')) {
      context.handle(
        _operacaoMeta,
        operacao.isAcceptableOrUnknown(data['operacao']!, _operacaoMeta),
      );
    } else if (isInserting) {
      context.missing(_operacaoMeta);
    }
    if (data.containsKey('criado_em')) {
      context.handle(
        _criadoEmMeta,
        criadoEm.isAcceptableOrUnknown(data['criado_em']!, _criadoEmMeta),
      );
    } else if (isInserting) {
      context.missing(_criadoEmMeta);
    }
    if (data.containsKey('tentativas')) {
      context.handle(
        _tentativasMeta,
        tentativas.isAcceptableOrUnknown(data['tentativas']!, _tentativasMeta),
      );
    }
    if (data.containsKey('ultimo_erro')) {
      context.handle(
        _ultimoErroMeta,
        ultimoErro.isAcceptableOrUnknown(data['ultimo_erro']!, _ultimoErroMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FilaSyncLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FilaSyncLinha(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      tabela: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tabela'],
      )!,
      registroId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registro_id'],
      )!,
      operacao: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operacao'],
      )!,
      criadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}criado_em'],
      )!,
      tentativas: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tentativas'],
      )!,
      ultimoErro: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ultimo_erro'],
      ),
    );
  }

  @override
  $ItensFilaSyncTable createAlias(String alias) {
    return $ItensFilaSyncTable(attachedDatabase, alias);
  }
}

class FilaSyncLinha extends DataClass implements Insertable<FilaSyncLinha> {
  final int id;
  final String tabela;
  final String registroId;
  final String operacao;
  final DateTime criadoEm;
  final int tentativas;
  final String? ultimoErro;
  const FilaSyncLinha({
    required this.id,
    required this.tabela,
    required this.registroId,
    required this.operacao,
    required this.criadoEm,
    required this.tentativas,
    this.ultimoErro,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['tabela'] = Variable<String>(tabela);
    map['registro_id'] = Variable<String>(registroId);
    map['operacao'] = Variable<String>(operacao);
    map['criado_em'] = Variable<DateTime>(criadoEm);
    map['tentativas'] = Variable<int>(tentativas);
    if (!nullToAbsent || ultimoErro != null) {
      map['ultimo_erro'] = Variable<String>(ultimoErro);
    }
    return map;
  }

  ItensFilaSyncCompanion toCompanion(bool nullToAbsent) {
    return ItensFilaSyncCompanion(
      id: Value(id),
      tabela: Value(tabela),
      registroId: Value(registroId),
      operacao: Value(operacao),
      criadoEm: Value(criadoEm),
      tentativas: Value(tentativas),
      ultimoErro: ultimoErro == null && nullToAbsent
          ? const Value.absent()
          : Value(ultimoErro),
    );
  }

  factory FilaSyncLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FilaSyncLinha(
      id: serializer.fromJson<int>(json['id']),
      tabela: serializer.fromJson<String>(json['tabela']),
      registroId: serializer.fromJson<String>(json['registroId']),
      operacao: serializer.fromJson<String>(json['operacao']),
      criadoEm: serializer.fromJson<DateTime>(json['criadoEm']),
      tentativas: serializer.fromJson<int>(json['tentativas']),
      ultimoErro: serializer.fromJson<String?>(json['ultimoErro']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'tabela': serializer.toJson<String>(tabela),
      'registroId': serializer.toJson<String>(registroId),
      'operacao': serializer.toJson<String>(operacao),
      'criadoEm': serializer.toJson<DateTime>(criadoEm),
      'tentativas': serializer.toJson<int>(tentativas),
      'ultimoErro': serializer.toJson<String?>(ultimoErro),
    };
  }

  FilaSyncLinha copyWith({
    int? id,
    String? tabela,
    String? registroId,
    String? operacao,
    DateTime? criadoEm,
    int? tentativas,
    Value<String?> ultimoErro = const Value.absent(),
  }) => FilaSyncLinha(
    id: id ?? this.id,
    tabela: tabela ?? this.tabela,
    registroId: registroId ?? this.registroId,
    operacao: operacao ?? this.operacao,
    criadoEm: criadoEm ?? this.criadoEm,
    tentativas: tentativas ?? this.tentativas,
    ultimoErro: ultimoErro.present ? ultimoErro.value : this.ultimoErro,
  );
  FilaSyncLinha copyWithCompanion(ItensFilaSyncCompanion data) {
    return FilaSyncLinha(
      id: data.id.present ? data.id.value : this.id,
      tabela: data.tabela.present ? data.tabela.value : this.tabela,
      registroId: data.registroId.present
          ? data.registroId.value
          : this.registroId,
      operacao: data.operacao.present ? data.operacao.value : this.operacao,
      criadoEm: data.criadoEm.present ? data.criadoEm.value : this.criadoEm,
      tentativas: data.tentativas.present
          ? data.tentativas.value
          : this.tentativas,
      ultimoErro: data.ultimoErro.present
          ? data.ultimoErro.value
          : this.ultimoErro,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FilaSyncLinha(')
          ..write('id: $id, ')
          ..write('tabela: $tabela, ')
          ..write('registroId: $registroId, ')
          ..write('operacao: $operacao, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('tentativas: $tentativas, ')
          ..write('ultimoErro: $ultimoErro')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tabela,
    registroId,
    operacao,
    criadoEm,
    tentativas,
    ultimoErro,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FilaSyncLinha &&
          other.id == this.id &&
          other.tabela == this.tabela &&
          other.registroId == this.registroId &&
          other.operacao == this.operacao &&
          other.criadoEm == this.criadoEm &&
          other.tentativas == this.tentativas &&
          other.ultimoErro == this.ultimoErro);
}

class ItensFilaSyncCompanion extends UpdateCompanion<FilaSyncLinha> {
  final Value<int> id;
  final Value<String> tabela;
  final Value<String> registroId;
  final Value<String> operacao;
  final Value<DateTime> criadoEm;
  final Value<int> tentativas;
  final Value<String?> ultimoErro;
  const ItensFilaSyncCompanion({
    this.id = const Value.absent(),
    this.tabela = const Value.absent(),
    this.registroId = const Value.absent(),
    this.operacao = const Value.absent(),
    this.criadoEm = const Value.absent(),
    this.tentativas = const Value.absent(),
    this.ultimoErro = const Value.absent(),
  });
  ItensFilaSyncCompanion.insert({
    this.id = const Value.absent(),
    required String tabela,
    required String registroId,
    required String operacao,
    required DateTime criadoEm,
    this.tentativas = const Value.absent(),
    this.ultimoErro = const Value.absent(),
  }) : tabela = Value(tabela),
       registroId = Value(registroId),
       operacao = Value(operacao),
       criadoEm = Value(criadoEm);
  static Insertable<FilaSyncLinha> custom({
    Expression<int>? id,
    Expression<String>? tabela,
    Expression<String>? registroId,
    Expression<String>? operacao,
    Expression<DateTime>? criadoEm,
    Expression<int>? tentativas,
    Expression<String>? ultimoErro,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tabela != null) 'tabela': tabela,
      if (registroId != null) 'registro_id': registroId,
      if (operacao != null) 'operacao': operacao,
      if (criadoEm != null) 'criado_em': criadoEm,
      if (tentativas != null) 'tentativas': tentativas,
      if (ultimoErro != null) 'ultimo_erro': ultimoErro,
    });
  }

  ItensFilaSyncCompanion copyWith({
    Value<int>? id,
    Value<String>? tabela,
    Value<String>? registroId,
    Value<String>? operacao,
    Value<DateTime>? criadoEm,
    Value<int>? tentativas,
    Value<String?>? ultimoErro,
  }) {
    return ItensFilaSyncCompanion(
      id: id ?? this.id,
      tabela: tabela ?? this.tabela,
      registroId: registroId ?? this.registroId,
      operacao: operacao ?? this.operacao,
      criadoEm: criadoEm ?? this.criadoEm,
      tentativas: tentativas ?? this.tentativas,
      ultimoErro: ultimoErro ?? this.ultimoErro,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (tabela.present) {
      map['tabela'] = Variable<String>(tabela.value);
    }
    if (registroId.present) {
      map['registro_id'] = Variable<String>(registroId.value);
    }
    if (operacao.present) {
      map['operacao'] = Variable<String>(operacao.value);
    }
    if (criadoEm.present) {
      map['criado_em'] = Variable<DateTime>(criadoEm.value);
    }
    if (tentativas.present) {
      map['tentativas'] = Variable<int>(tentativas.value);
    }
    if (ultimoErro.present) {
      map['ultimo_erro'] = Variable<String>(ultimoErro.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ItensFilaSyncCompanion(')
          ..write('id: $id, ')
          ..write('tabela: $tabela, ')
          ..write('registroId: $registroId, ')
          ..write('operacao: $operacao, ')
          ..write('criadoEm: $criadoEm, ')
          ..write('tentativas: $tentativas, ')
          ..write('ultimoErro: $ultimoErro')
          ..write(')'))
        .toString();
  }
}

class $ConflitosTable extends Conflitos
    with TableInfo<$ConflitosTable, ConflitoLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflitosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tabelaMeta = const VerificationMeta('tabela');
  @override
  late final GeneratedColumn<String> tabela = GeneratedColumn<String>(
    'tabela',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _registroIdMeta = const VerificationMeta(
    'registroId',
  );
  @override
  late final GeneratedColumn<String> registroId = GeneratedColumn<String>(
    'registro_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dadosRemotosMeta = const VerificationMeta(
    'dadosRemotos',
  );
  @override
  late final GeneratedColumn<String> dadosRemotos = GeneratedColumn<String>(
    'dados_remotos',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _detectadoEmMeta = const VerificationMeta(
    'detectadoEm',
  );
  @override
  late final GeneratedColumn<DateTime> detectadoEm = GeneratedColumn<DateTime>(
    'detectado_em',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    tabela,
    registroId,
    dadosRemotos,
    detectadoEm,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflitos';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflitoLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('tabela')) {
      context.handle(
        _tabelaMeta,
        tabela.isAcceptableOrUnknown(data['tabela']!, _tabelaMeta),
      );
    } else if (isInserting) {
      context.missing(_tabelaMeta);
    }
    if (data.containsKey('registro_id')) {
      context.handle(
        _registroIdMeta,
        registroId.isAcceptableOrUnknown(data['registro_id']!, _registroIdMeta),
      );
    } else if (isInserting) {
      context.missing(_registroIdMeta);
    }
    if (data.containsKey('dados_remotos')) {
      context.handle(
        _dadosRemotosMeta,
        dadosRemotos.isAcceptableOrUnknown(
          data['dados_remotos']!,
          _dadosRemotosMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dadosRemotosMeta);
    }
    if (data.containsKey('detectado_em')) {
      context.handle(
        _detectadoEmMeta,
        detectadoEm.isAcceptableOrUnknown(
          data['detectado_em']!,
          _detectadoEmMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_detectadoEmMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {tabela, registroId};
  @override
  ConflitoLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflitoLinha(
      tabela: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tabela'],
      )!,
      registroId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}registro_id'],
      )!,
      dadosRemotos: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dados_remotos'],
      )!,
      detectadoEm: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detectado_em'],
      )!,
    );
  }

  @override
  $ConflitosTable createAlias(String alias) {
    return $ConflitosTable(attachedDatabase, alias);
  }
}

class ConflitoLinha extends DataClass implements Insertable<ConflitoLinha> {
  final String tabela;
  final String registroId;

  /// Documento remoto em JSON.
  final String dadosRemotos;
  final DateTime detectadoEm;
  const ConflitoLinha({
    required this.tabela,
    required this.registroId,
    required this.dadosRemotos,
    required this.detectadoEm,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['tabela'] = Variable<String>(tabela);
    map['registro_id'] = Variable<String>(registroId);
    map['dados_remotos'] = Variable<String>(dadosRemotos);
    map['detectado_em'] = Variable<DateTime>(detectadoEm);
    return map;
  }

  ConflitosCompanion toCompanion(bool nullToAbsent) {
    return ConflitosCompanion(
      tabela: Value(tabela),
      registroId: Value(registroId),
      dadosRemotos: Value(dadosRemotos),
      detectadoEm: Value(detectadoEm),
    );
  }

  factory ConflitoLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflitoLinha(
      tabela: serializer.fromJson<String>(json['tabela']),
      registroId: serializer.fromJson<String>(json['registroId']),
      dadosRemotos: serializer.fromJson<String>(json['dadosRemotos']),
      detectadoEm: serializer.fromJson<DateTime>(json['detectadoEm']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'tabela': serializer.toJson<String>(tabela),
      'registroId': serializer.toJson<String>(registroId),
      'dadosRemotos': serializer.toJson<String>(dadosRemotos),
      'detectadoEm': serializer.toJson<DateTime>(detectadoEm),
    };
  }

  ConflitoLinha copyWith({
    String? tabela,
    String? registroId,
    String? dadosRemotos,
    DateTime? detectadoEm,
  }) => ConflitoLinha(
    tabela: tabela ?? this.tabela,
    registroId: registroId ?? this.registroId,
    dadosRemotos: dadosRemotos ?? this.dadosRemotos,
    detectadoEm: detectadoEm ?? this.detectadoEm,
  );
  ConflitoLinha copyWithCompanion(ConflitosCompanion data) {
    return ConflitoLinha(
      tabela: data.tabela.present ? data.tabela.value : this.tabela,
      registroId: data.registroId.present
          ? data.registroId.value
          : this.registroId,
      dadosRemotos: data.dadosRemotos.present
          ? data.dadosRemotos.value
          : this.dadosRemotos,
      detectadoEm: data.detectadoEm.present
          ? data.detectadoEm.value
          : this.detectadoEm,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflitoLinha(')
          ..write('tabela: $tabela, ')
          ..write('registroId: $registroId, ')
          ..write('dadosRemotos: $dadosRemotos, ')
          ..write('detectadoEm: $detectadoEm')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(tabela, registroId, dadosRemotos, detectadoEm);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflitoLinha &&
          other.tabela == this.tabela &&
          other.registroId == this.registroId &&
          other.dadosRemotos == this.dadosRemotos &&
          other.detectadoEm == this.detectadoEm);
}

class ConflitosCompanion extends UpdateCompanion<ConflitoLinha> {
  final Value<String> tabela;
  final Value<String> registroId;
  final Value<String> dadosRemotos;
  final Value<DateTime> detectadoEm;
  final Value<int> rowid;
  const ConflitosCompanion({
    this.tabela = const Value.absent(),
    this.registroId = const Value.absent(),
    this.dadosRemotos = const Value.absent(),
    this.detectadoEm = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConflitosCompanion.insert({
    required String tabela,
    required String registroId,
    required String dadosRemotos,
    required DateTime detectadoEm,
    this.rowid = const Value.absent(),
  }) : tabela = Value(tabela),
       registroId = Value(registroId),
       dadosRemotos = Value(dadosRemotos),
       detectadoEm = Value(detectadoEm);
  static Insertable<ConflitoLinha> custom({
    Expression<String>? tabela,
    Expression<String>? registroId,
    Expression<String>? dadosRemotos,
    Expression<DateTime>? detectadoEm,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (tabela != null) 'tabela': tabela,
      if (registroId != null) 'registro_id': registroId,
      if (dadosRemotos != null) 'dados_remotos': dadosRemotos,
      if (detectadoEm != null) 'detectado_em': detectadoEm,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConflitosCompanion copyWith({
    Value<String>? tabela,
    Value<String>? registroId,
    Value<String>? dadosRemotos,
    Value<DateTime>? detectadoEm,
    Value<int>? rowid,
  }) {
    return ConflitosCompanion(
      tabela: tabela ?? this.tabela,
      registroId: registroId ?? this.registroId,
      dadosRemotos: dadosRemotos ?? this.dadosRemotos,
      detectadoEm: detectadoEm ?? this.detectadoEm,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (tabela.present) {
      map['tabela'] = Variable<String>(tabela.value);
    }
    if (registroId.present) {
      map['registro_id'] = Variable<String>(registroId.value);
    }
    if (dadosRemotos.present) {
      map['dados_remotos'] = Variable<String>(dadosRemotos.value);
    }
    if (detectadoEm.present) {
      map['detectado_em'] = Variable<DateTime>(detectadoEm.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflitosCompanion(')
          ..write('tabela: $tabela, ')
          ..write('registroId: $registroId, ')
          ..write('dadosRemotos: $dadosRemotos, ')
          ..write('detectadoEm: $detectadoEm, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConfigTable extends Config with TableInfo<$ConfigTable, ConfigLinha> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chaveMeta = const VerificationMeta('chave');
  @override
  late final GeneratedColumn<String> chave = GeneratedColumn<String>(
    'chave',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valorMeta = const VerificationMeta('valor');
  @override
  late final GeneratedColumn<String> valor = GeneratedColumn<String>(
    'valor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [chave, valor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'config';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigLinha> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chave')) {
      context.handle(
        _chaveMeta,
        chave.isAcceptableOrUnknown(data['chave']!, _chaveMeta),
      );
    } else if (isInserting) {
      context.missing(_chaveMeta);
    }
    if (data.containsKey('valor')) {
      context.handle(
        _valorMeta,
        valor.isAcceptableOrUnknown(data['valor']!, _valorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chave};
  @override
  ConfigLinha map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigLinha(
      chave: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chave'],
      )!,
      valor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}valor'],
      ),
    );
  }

  @override
  $ConfigTable createAlias(String alias) {
    return $ConfigTable(attachedDatabase, alias);
  }
}

class ConfigLinha extends DataClass implements Insertable<ConfigLinha> {
  final String chave;
  final String? valor;
  const ConfigLinha({required this.chave, this.valor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chave'] = Variable<String>(chave);
    if (!nullToAbsent || valor != null) {
      map['valor'] = Variable<String>(valor);
    }
    return map;
  }

  ConfigCompanion toCompanion(bool nullToAbsent) {
    return ConfigCompanion(
      chave: Value(chave),
      valor: valor == null && nullToAbsent
          ? const Value.absent()
          : Value(valor),
    );
  }

  factory ConfigLinha.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigLinha(
      chave: serializer.fromJson<String>(json['chave']),
      valor: serializer.fromJson<String?>(json['valor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chave': serializer.toJson<String>(chave),
      'valor': serializer.toJson<String?>(valor),
    };
  }

  ConfigLinha copyWith({
    String? chave,
    Value<String?> valor = const Value.absent(),
  }) => ConfigLinha(
    chave: chave ?? this.chave,
    valor: valor.present ? valor.value : this.valor,
  );
  ConfigLinha copyWithCompanion(ConfigCompanion data) {
    return ConfigLinha(
      chave: data.chave.present ? data.chave.value : this.chave,
      valor: data.valor.present ? data.valor.value : this.valor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigLinha(')
          ..write('chave: $chave, ')
          ..write('valor: $valor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(chave, valor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigLinha &&
          other.chave == this.chave &&
          other.valor == this.valor);
}

class ConfigCompanion extends UpdateCompanion<ConfigLinha> {
  final Value<String> chave;
  final Value<String?> valor;
  final Value<int> rowid;
  const ConfigCompanion({
    this.chave = const Value.absent(),
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfigCompanion.insert({
    required String chave,
    this.valor = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chave = Value(chave);
  static Insertable<ConfigLinha> custom({
    Expression<String>? chave,
    Expression<String>? valor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chave != null) 'chave': chave,
      if (valor != null) 'valor': valor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfigCompanion copyWith({
    Value<String>? chave,
    Value<String?>? valor,
    Value<int>? rowid,
  }) {
    return ConfigCompanion(
      chave: chave ?? this.chave,
      valor: valor ?? this.valor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chave.present) {
      map['chave'] = Variable<String>(chave.value);
    }
    if (valor.present) {
      map['valor'] = Variable<String>(valor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigCompanion(')
          ..write('chave: $chave, ')
          ..write('valor: $valor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BancoLocal extends GeneratedDatabase {
  _$BancoLocal(QueryExecutor e) : super(e);
  $BancoLocalManager get managers => $BancoLocalManager(this);
  late final $PetsTable pets = $PetsTable(this);
  late final $AlimentosTable alimentos = $AlimentosTable(this);
  late final $RefeicoesTable refeicoes = $RefeicoesTable(this);
  late final $ExtrasTable extras = $ExtrasTable(this);
  late final $AtividadesTable atividades = $AtividadesTable(this);
  late final $LembretesTable lembretes = $LembretesTable(this);
  late final $PesagensTable pesagens = $PesagensTable(this);
  late final $ReferenciasTable referencias = $ReferenciasTable(this);
  late final $ItensFilaSyncTable itensFilaSync = $ItensFilaSyncTable(this);
  late final $ConflitosTable conflitos = $ConflitosTable(this);
  late final $ConfigTable config = $ConfigTable(this);
  late final Index idxAlimentosPet = Index(
    'idx_alimentos_pet',
    'CREATE INDEX idx_alimentos_pet ON alimentos (pet_id)',
  );
  late final Index idxRefeicoesPetData = Index(
    'idx_refeicoes_pet_data',
    'CREATE INDEX idx_refeicoes_pet_data ON refeicoes (pet_id, data_hora)',
  );
  late final Index idxExtrasPetData = Index(
    'idx_extras_pet_data',
    'CREATE INDEX idx_extras_pet_data ON extras (pet_id, data_hora)',
  );
  late final Index idxAtividadesPetData = Index(
    'idx_atividades_pet_data',
    'CREATE INDEX idx_atividades_pet_data ON atividades (pet_id, data_hora)',
  );
  late final Index idxLembretesPet = Index(
    'idx_lembretes_pet',
    'CREATE INDEX idx_lembretes_pet ON lembretes (pet_id)',
  );
  late final Index idxPesagensPetData = Index(
    'idx_pesagens_pet_data',
    'CREATE INDEX idx_pesagens_pet_data ON pesagens (pet_id, data_hora)',
  );
  late final Index idxReferenciasPet = Index(
    'idx_referencias_pet',
    'CREATE INDEX idx_referencias_pet ON referencias (pet_id)',
  );
  late final Index idxFilaSyncRegistro = Index(
    'idx_fila_sync_registro',
    'CREATE INDEX idx_fila_sync_registro ON fila_sync (tabela, registro_id)',
  );
  late final ConfigDao configDao = ConfigDao(this as BancoLocal);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    pets,
    alimentos,
    refeicoes,
    extras,
    atividades,
    lembretes,
    pesagens,
    referencias,
    itensFilaSync,
    conflitos,
    config,
    idxAlimentosPet,
    idxRefeicoesPetData,
    idxExtrasPetData,
    idxAtividadesPetData,
    idxLembretesPet,
    idxPesagensPetData,
    idxReferenciasPet,
    idxFilaSyncRegistro,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('alimentos', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('refeicoes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('extras', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('atividades', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('lembretes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('pesagens', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'pets',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('referencias', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$PetsTableCreateCompanionBuilder = PetsCompanion Function({
  required String id,
  required DateTime criadoEm,
  required DateTime atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  required String nome,
  required String especie,
  required String sexo,
  required int idadeMeses,
  required DateTime idadeInformadaEm,
  required bool castrado,
  required String nivelAtividade,
  Value<String?> fotoArquivo,
  Value<int> rowid,
});
typedef $$PetsTableUpdateCompanionBuilder = PetsCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  Value<String> nome,
  Value<String> especie,
  Value<String> sexo,
  Value<int> idadeMeses,
  Value<DateTime> idadeInformadaEm,
  Value<bool> castrado,
  Value<String> nivelAtividade,
  Value<String?> fotoArquivo,
  Value<int> rowid,
});

final class $$PetsTableReferences
    extends BaseReferences<_$BancoLocal, $PetsTable, PetLinha> {
  $$PetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$AlimentosTable, List<AlimentoLinha>>
  _alimentosRefsTable(_$BancoLocal db) => MultiTypedResultKey.fromTable(
    db.alimentos,
    aliasName: 'pets__id__alimentos__pet_id',
  );

  $$AlimentosTableProcessedTableManager get alimentosRefs {
    final manager = $$AlimentosTableTableManager(
      $_db,
      $_db.alimentos,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_alimentosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RefeicoesTable, List<RefeicaoLinha>>
  _refeicoesRefsTable(_$BancoLocal db) => MultiTypedResultKey.fromTable(
    db.refeicoes,
    aliasName: 'pets__id__refeicoes__pet_id',
  );

  $$RefeicoesTableProcessedTableManager get refeicoesRefs {
    final manager = $$RefeicoesTableTableManager(
      $_db,
      $_db.refeicoes,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_refeicoesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExtrasTable, List<ExtraLinha>> _extrasRefsTable(
    _$BancoLocal db,
  ) => MultiTypedResultKey.fromTable(
    db.extras,
    aliasName: 'pets__id__extras__pet_id',
  );

  $$ExtrasTableProcessedTableManager get extrasRefs {
    final manager = $$ExtrasTableTableManager(
      $_db,
      $_db.extras,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_extrasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AtividadesTable, List<AtividadeLinha>>
  _atividadesRefsTable(_$BancoLocal db) => MultiTypedResultKey.fromTable(
    db.atividades,
    aliasName: 'pets__id__atividades__pet_id',
  );

  $$AtividadesTableProcessedTableManager get atividadesRefs {
    final manager = $$AtividadesTableTableManager(
      $_db,
      $_db.atividades,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_atividadesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LembretesTable, List<LembreteLinha>>
  _lembretesRefsTable(_$BancoLocal db) => MultiTypedResultKey.fromTable(
    db.lembretes,
    aliasName: 'pets__id__lembretes__pet_id',
  );

  $$LembretesTableProcessedTableManager get lembretesRefs {
    final manager = $$LembretesTableTableManager(
      $_db,
      $_db.lembretes,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_lembretesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PesagensTable, List<PesagemLinha>>
  _pesagensRefsTable(_$BancoLocal db) => MultiTypedResultKey.fromTable(
    db.pesagens,
    aliasName: 'pets__id__pesagens__pet_id',
  );

  $$PesagensTableProcessedTableManager get pesagensRefs {
    final manager = $$PesagensTableTableManager(
      $_db,
      $_db.pesagens,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_pesagensRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReferenciasTable, List<ReferenciaLinha>>
  _referenciasRefsTable(_$BancoLocal db) => MultiTypedResultKey.fromTable(
    db.referencias,
    aliasName: 'pets__id__referencias__pet_id',
  );

  $$ReferenciasTableProcessedTableManager get referenciasRefs {
    final manager = $$ReferenciasTableTableManager(
      $_db,
      $_db.referencias,
    ).filter((f) => f.petId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_referenciasRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PetsTableFilterComposer extends Composer<_$BancoLocal, $PetsTable> {
  $$PetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get especie => $composableBuilder(
    column: $table.especie,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sexo => $composableBuilder(
    column: $table.sexo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get idadeMeses => $composableBuilder(
    column: $table.idadeMeses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get idadeInformadaEm => $composableBuilder(
    column: $table.idadeInformadaEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get castrado => $composableBuilder(
    column: $table.castrado,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nivelAtividade => $composableBuilder(
    column: $table.nivelAtividade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fotoArquivo => $composableBuilder(
    column: $table.fotoArquivo,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> alimentosRefs(
    Expression<bool> Function($$AlimentosTableFilterComposer f) f,
  ) {
    final $$AlimentosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alimentos,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlimentosTableFilterComposer(
            $db: $db,
            $table: $db.alimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> refeicoesRefs(
    Expression<bool> Function($$RefeicoesTableFilterComposer f) f,
  ) {
    final $$RefeicoesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.refeicoes,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RefeicoesTableFilterComposer(
            $db: $db,
            $table: $db.refeicoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> extrasRefs(
    Expression<bool> Function($$ExtrasTableFilterComposer f) f,
  ) {
    final $$ExtrasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.extras,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExtrasTableFilterComposer(
            $db: $db,
            $table: $db.extras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> atividadesRefs(
    Expression<bool> Function($$AtividadesTableFilterComposer f) f,
  ) {
    final $$AtividadesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.atividades,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AtividadesTableFilterComposer(
            $db: $db,
            $table: $db.atividades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> lembretesRefs(
    Expression<bool> Function($$LembretesTableFilterComposer f) f,
  ) {
    final $$LembretesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lembretes,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LembretesTableFilterComposer(
            $db: $db,
            $table: $db.lembretes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pesagensRefs(
    Expression<bool> Function($$PesagensTableFilterComposer f) f,
  ) {
    final $$PesagensTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pesagens,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PesagensTableFilterComposer(
            $db: $db,
            $table: $db.pesagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> referenciasRefs(
    Expression<bool> Function($$ReferenciasTableFilterComposer f) f,
  ) {
    final $$ReferenciasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.referencias,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenciasTableFilterComposer(
            $db: $db,
            $table: $db.referencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PetsTableOrderingComposer extends Composer<_$BancoLocal, $PetsTable> {
  $$PetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get especie => $composableBuilder(
    column: $table.especie,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sexo => $composableBuilder(
    column: $table.sexo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get idadeMeses => $composableBuilder(
    column: $table.idadeMeses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get idadeInformadaEm => $composableBuilder(
    column: $table.idadeInformadaEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get castrado => $composableBuilder(
    column: $table.castrado,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nivelAtividade => $composableBuilder(
    column: $table.nivelAtividade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fotoArquivo => $composableBuilder(
    column: $table.fotoArquivo,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PetsTableAnnotationComposer extends Composer<_$BancoLocal, $PetsTable> {
  $$PetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versao =>
      $composableBuilder(column: $table.versao, builder: (column) => column);

  GeneratedColumn<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excluido =>
      $composableBuilder(column: $table.excluido, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get especie =>
      $composableBuilder(column: $table.especie, builder: (column) => column);

  GeneratedColumn<String> get sexo =>
      $composableBuilder(column: $table.sexo, builder: (column) => column);

  GeneratedColumn<int> get idadeMeses => $composableBuilder(
    column: $table.idadeMeses,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get idadeInformadaEm => $composableBuilder(
    column: $table.idadeInformadaEm,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get castrado =>
      $composableBuilder(column: $table.castrado, builder: (column) => column);

  GeneratedColumn<String> get nivelAtividade => $composableBuilder(
    column: $table.nivelAtividade,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fotoArquivo => $composableBuilder(
    column: $table.fotoArquivo,
    builder: (column) => column,
  );

  Expression<T> alimentosRefs<T extends Object>(
    Expression<T> Function($$AlimentosTableAnnotationComposer a) f,
  ) {
    final $$AlimentosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.alimentos,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AlimentosTableAnnotationComposer(
            $db: $db,
            $table: $db.alimentos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> refeicoesRefs<T extends Object>(
    Expression<T> Function($$RefeicoesTableAnnotationComposer a) f,
  ) {
    final $$RefeicoesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.refeicoes,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RefeicoesTableAnnotationComposer(
            $db: $db,
            $table: $db.refeicoes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> extrasRefs<T extends Object>(
    Expression<T> Function($$ExtrasTableAnnotationComposer a) f,
  ) {
    final $$ExtrasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.extras,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExtrasTableAnnotationComposer(
            $db: $db,
            $table: $db.extras,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> atividadesRefs<T extends Object>(
    Expression<T> Function($$AtividadesTableAnnotationComposer a) f,
  ) {
    final $$AtividadesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.atividades,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AtividadesTableAnnotationComposer(
            $db: $db,
            $table: $db.atividades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> lembretesRefs<T extends Object>(
    Expression<T> Function($$LembretesTableAnnotationComposer a) f,
  ) {
    final $$LembretesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.lembretes,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LembretesTableAnnotationComposer(
            $db: $db,
            $table: $db.lembretes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pesagensRefs<T extends Object>(
    Expression<T> Function($$PesagensTableAnnotationComposer a) f,
  ) {
    final $$PesagensTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pesagens,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PesagensTableAnnotationComposer(
            $db: $db,
            $table: $db.pesagens,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> referenciasRefs<T extends Object>(
    Expression<T> Function($$ReferenciasTableAnnotationComposer a) f,
  ) {
    final $$ReferenciasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.referencias,
      getReferencedColumn: (t) => t.petId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReferenciasTableAnnotationComposer(
            $db: $db,
            $table: $db.referencias,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PetsTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $PetsTable,
          PetLinha,
          $$PetsTableFilterComposer,
          $$PetsTableOrderingComposer,
          $$PetsTableAnnotationComposer,
          $$PetsTableCreateCompanionBuilder,
          $$PetsTableUpdateCompanionBuilder,
          (PetLinha, $$PetsTableReferences),
          PetLinha,
          PrefetchHooks Function({
            bool alimentosRefs,
            bool refeicoesRefs,
            bool extrasRefs,
            bool atividadesRefs,
            bool lembretesRefs,
            bool pesagensRefs,
            bool referenciasRefs,
          })
        > {
  $$PetsTableTableManager(_$BancoLocal db, $PetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> especie = const Value.absent(),
                Value<String> sexo = const Value.absent(),
                Value<int> idadeMeses = const Value.absent(),
                Value<DateTime> idadeInformadaEm = const Value.absent(),
                Value<bool> castrado = const Value.absent(),
                Value<String> nivelAtividade = const Value.absent(),
                Value<String?> fotoArquivo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PetsCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                nome: nome,
                especie: especie,
                sexo: sexo,
                idadeMeses: idadeMeses,
                idadeInformadaEm: idadeInformadaEm,
                castrado: castrado,
                nivelAtividade: nivelAtividade,
                fotoArquivo: fotoArquivo,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                required String nome,
                required String especie,
                required String sexo,
                required int idadeMeses,
                required DateTime idadeInformadaEm,
                required bool castrado,
                required String nivelAtividade,
                Value<String?> fotoArquivo = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PetsCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                nome: nome,
                especie: especie,
                sexo: sexo,
                idadeMeses: idadeMeses,
                idadeInformadaEm: idadeInformadaEm,
                castrado: castrado,
                nivelAtividade: nivelAtividade,
                fotoArquivo: fotoArquivo,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PetsTable, PetLinha>(table),
                  $$PetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                alimentosRefs = false,
                refeicoesRefs = false,
                extrasRefs = false,
                atividadesRefs = false,
                lembretesRefs = false,
                pesagensRefs = false,
                referenciasRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (alimentosRefs) db.alimentos,
                    if (refeicoesRefs) db.refeicoes,
                    if (extrasRefs) db.extras,
                    if (atividadesRefs) db.atividades,
                    if (lembretesRefs) db.lembretes,
                    if (pesagensRefs) db.pesagens,
                    if (referenciasRefs) db.referencias,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (alimentosRefs)
                        await $_getPrefetchedDataByColumns<
                          PetLinha,
                          $PetsTable,
                          AlimentoLinha,
                          $AlimentosTable
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._alimentosRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).alimentosRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pet_id',
                          typedResults: items,
                        ),
                      if (refeicoesRefs)
                        await $_getPrefetchedDataByColumns<
                          PetLinha,
                          $PetsTable,
                          RefeicaoLinha,
                          $RefeicoesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._refeicoesRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).refeicoesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pet_id',
                          typedResults: items,
                        ),
                      if (extrasRefs)
                        await $_getPrefetchedDataByColumns<
                          PetLinha,
                          $PetsTable,
                          ExtraLinha,
                          $ExtrasTable
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._extrasRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PetsTableReferences(db, table, p0).extrasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pet_id',
                          typedResults: items,
                        ),
                      if (atividadesRefs)
                        await $_getPrefetchedDataByColumns<
                          PetLinha,
                          $PetsTable,
                          AtividadeLinha,
                          $AtividadesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._atividadesRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).atividadesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pet_id',
                          typedResults: items,
                        ),
                      if (lembretesRefs)
                        await $_getPrefetchedDataByColumns<
                          PetLinha,
                          $PetsTable,
                          LembreteLinha,
                          $LembretesTable
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._lembretesRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).lembretesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pet_id',
                          typedResults: items,
                        ),
                      if (pesagensRefs)
                        await $_getPrefetchedDataByColumns<
                          PetLinha,
                          $PetsTable,
                          PesagemLinha,
                          $PesagensTable
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._pesagensRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PetsTableReferences(db, table, p0).pesagensRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pet_id',
                          typedResults: items,
                        ),
                      if (referenciasRefs)
                        await $_getPrefetchedDataByColumns<
                          PetLinha,
                          $PetsTable,
                          ReferenciaLinha,
                          $ReferenciasTable
                        >(
                          currentTable: table,
                          referencedTable: $$PetsTableReferences
                              ._referenciasRefsTable(db),
                          managerFromTypedResult: (p0) => $$PetsTableReferences(
                            db,
                            table,
                            p0,
                          ).referenciasRefs,
                          currentColumn: 'id',
                          referencedColumn: 'pet_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PetsTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $PetsTable,
      PetLinha,
      $$PetsTableFilterComposer,
      $$PetsTableOrderingComposer,
      $$PetsTableAnnotationComposer,
      $$PetsTableCreateCompanionBuilder,
      $$PetsTableUpdateCompanionBuilder,
      (PetLinha, $$PetsTableReferences),
      PetLinha,
      PrefetchHooks Function({
        bool alimentosRefs,
        bool refeicoesRefs,
        bool extrasRefs,
        bool atividadesRefs,
        bool lembretesRefs,
        bool pesagensRefs,
        bool referenciasRefs,
      })
    >;
typedef $$AlimentosTableCreateCompanionBuilder = AlimentosCompanion Function({
  required String id,
  required DateTime criadoEm,
  required DateTime atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  required String petId,
  required String nome,
  Value<String> tipo,
  Value<double?> densidadeKcalPor100g,
  Value<double?> porcaoPadraoG,
  Value<double?> kcalPorUnidade,
  Value<int?> unidadesHabituais,
  Value<bool> arquivado,
  Value<int> rowid,
});
typedef $$AlimentosTableUpdateCompanionBuilder = AlimentosCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  Value<String> petId,
  Value<String> nome,
  Value<String> tipo,
  Value<double?> densidadeKcalPor100g,
  Value<double?> porcaoPadraoG,
  Value<double?> kcalPorUnidade,
  Value<int?> unidadesHabituais,
  Value<bool> arquivado,
  Value<int> rowid,
});

final class $$AlimentosTableReferences
    extends BaseReferences<_$BancoLocal, $AlimentosTable, AlimentoLinha> {
  $$AlimentosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$BancoLocal db) =>
      db.pets.createAlias('alimentos__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<String>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AlimentosTableFilterComposer
    extends Composer<_$BancoLocal, $AlimentosTable> {
  $$AlimentosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get densidadeKcalPor100g => $composableBuilder(
    column: $table.densidadeKcalPor100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get porcaoPadraoG => $composableBuilder(
    column: $table.porcaoPadraoG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalPorUnidade => $composableBuilder(
    column: $table.kcalPorUnidade,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unidadesHabituais => $composableBuilder(
    column: $table.unidadesHabituais,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get arquivado => $composableBuilder(
    column: $table.arquivado,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlimentosTableOrderingComposer
    extends Composer<_$BancoLocal, $AlimentosTable> {
  $$AlimentosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nome => $composableBuilder(
    column: $table.nome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get densidadeKcalPor100g => $composableBuilder(
    column: $table.densidadeKcalPor100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get porcaoPadraoG => $composableBuilder(
    column: $table.porcaoPadraoG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalPorUnidade => $composableBuilder(
    column: $table.kcalPorUnidade,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unidadesHabituais => $composableBuilder(
    column: $table.unidadesHabituais,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get arquivado => $composableBuilder(
    column: $table.arquivado,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlimentosTableAnnotationComposer
    extends Composer<_$BancoLocal, $AlimentosTable> {
  $$AlimentosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versao =>
      $composableBuilder(column: $table.versao, builder: (column) => column);

  GeneratedColumn<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excluido =>
      $composableBuilder(column: $table.excluido, builder: (column) => column);

  GeneratedColumn<String> get nome =>
      $composableBuilder(column: $table.nome, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<double> get densidadeKcalPor100g => $composableBuilder(
    column: $table.densidadeKcalPor100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get porcaoPadraoG => $composableBuilder(
    column: $table.porcaoPadraoG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kcalPorUnidade => $composableBuilder(
    column: $table.kcalPorUnidade,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unidadesHabituais => $composableBuilder(
    column: $table.unidadesHabituais,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get arquivado =>
      $composableBuilder(column: $table.arquivado, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AlimentosTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $AlimentosTable,
          AlimentoLinha,
          $$AlimentosTableFilterComposer,
          $$AlimentosTableOrderingComposer,
          $$AlimentosTableAnnotationComposer,
          $$AlimentosTableCreateCompanionBuilder,
          $$AlimentosTableUpdateCompanionBuilder,
          (AlimentoLinha, $$AlimentosTableReferences),
          AlimentoLinha,
          PrefetchHooks Function({bool petId})
        > {
  $$AlimentosTableTableManager(_$BancoLocal db, $AlimentosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AlimentosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AlimentosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AlimentosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<String> nome = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<double?> densidadeKcalPor100g = const Value.absent(),
                Value<double?> porcaoPadraoG = const Value.absent(),
                Value<double?> kcalPorUnidade = const Value.absent(),
                Value<int?> unidadesHabituais = const Value.absent(),
                Value<bool> arquivado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlimentosCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                nome: nome,
                tipo: tipo,
                densidadeKcalPor100g: densidadeKcalPor100g,
                porcaoPadraoG: porcaoPadraoG,
                kcalPorUnidade: kcalPorUnidade,
                unidadesHabituais: unidadesHabituais,
                arquivado: arquivado,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                required String petId,
                required String nome,
                Value<String> tipo = const Value.absent(),
                Value<double?> densidadeKcalPor100g = const Value.absent(),
                Value<double?> porcaoPadraoG = const Value.absent(),
                Value<double?> kcalPorUnidade = const Value.absent(),
                Value<int?> unidadesHabituais = const Value.absent(),
                Value<bool> arquivado = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AlimentosCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                nome: nome,
                tipo: tipo,
                densidadeKcalPor100g: densidadeKcalPor100g,
                porcaoPadraoG: porcaoPadraoG,
                kcalPorUnidade: kcalPorUnidade,
                unidadesHabituais: unidadesHabituais,
                arquivado: arquivado,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AlimentosTable, AlimentoLinha>(table),
                  $$AlimentosTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.petId,
                        referencedTable: $$AlimentosTableReferences._petIdTable(
                          db,
                        ),
                        referencedColumn: $$AlimentosTableReferences
                            ._petIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AlimentosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $AlimentosTable,
      AlimentoLinha,
      $$AlimentosTableFilterComposer,
      $$AlimentosTableOrderingComposer,
      $$AlimentosTableAnnotationComposer,
      $$AlimentosTableCreateCompanionBuilder,
      $$AlimentosTableUpdateCompanionBuilder,
      (AlimentoLinha, $$AlimentosTableReferences),
      AlimentoLinha,
      PrefetchHooks Function({bool petId})
    >;
typedef $$RefeicoesTableCreateCompanionBuilder = RefeicoesCompanion Function({
  required String id,
  required DateTime criadoEm,
  required DateTime atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  required String petId,
  Value<String?> alimentoId,
  required String alimentoNome,
  required double densidadeKcalPor100g,
  required double quantidadeG,
  required double energiaKcal,
  required DateTime dataHora,
  Value<int> rowid,
});
typedef $$RefeicoesTableUpdateCompanionBuilder = RefeicoesCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  Value<String> petId,
  Value<String?> alimentoId,
  Value<String> alimentoNome,
  Value<double> densidadeKcalPor100g,
  Value<double> quantidadeG,
  Value<double> energiaKcal,
  Value<DateTime> dataHora,
  Value<int> rowid,
});

final class $$RefeicoesTableReferences
    extends BaseReferences<_$BancoLocal, $RefeicoesTable, RefeicaoLinha> {
  $$RefeicoesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$BancoLocal db) =>
      db.pets.createAlias('refeicoes__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<String>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RefeicoesTableFilterComposer
    extends Composer<_$BancoLocal, $RefeicoesTable> {
  $$RefeicoesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alimentoId => $composableBuilder(
    column: $table.alimentoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alimentoNome => $composableBuilder(
    column: $table.alimentoNome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get densidadeKcalPor100g => $composableBuilder(
    column: $table.densidadeKcalPor100g,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantidadeG => $composableBuilder(
    column: $table.quantidadeG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energiaKcal => $composableBuilder(
    column: $table.energiaKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RefeicoesTableOrderingComposer
    extends Composer<_$BancoLocal, $RefeicoesTable> {
  $$RefeicoesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alimentoId => $composableBuilder(
    column: $table.alimentoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alimentoNome => $composableBuilder(
    column: $table.alimentoNome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get densidadeKcalPor100g => $composableBuilder(
    column: $table.densidadeKcalPor100g,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantidadeG => $composableBuilder(
    column: $table.quantidadeG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energiaKcal => $composableBuilder(
    column: $table.energiaKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RefeicoesTableAnnotationComposer
    extends Composer<_$BancoLocal, $RefeicoesTable> {
  $$RefeicoesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versao =>
      $composableBuilder(column: $table.versao, builder: (column) => column);

  GeneratedColumn<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excluido =>
      $composableBuilder(column: $table.excluido, builder: (column) => column);

  GeneratedColumn<String> get alimentoId => $composableBuilder(
    column: $table.alimentoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get alimentoNome => $composableBuilder(
    column: $table.alimentoNome,
    builder: (column) => column,
  );

  GeneratedColumn<double> get densidadeKcalPor100g => $composableBuilder(
    column: $table.densidadeKcalPor100g,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantidadeG => $composableBuilder(
    column: $table.quantidadeG,
    builder: (column) => column,
  );

  GeneratedColumn<double> get energiaKcal => $composableBuilder(
    column: $table.energiaKcal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataHora =>
      $composableBuilder(column: $table.dataHora, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RefeicoesTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $RefeicoesTable,
          RefeicaoLinha,
          $$RefeicoesTableFilterComposer,
          $$RefeicoesTableOrderingComposer,
          $$RefeicoesTableAnnotationComposer,
          $$RefeicoesTableCreateCompanionBuilder,
          $$RefeicoesTableUpdateCompanionBuilder,
          (RefeicaoLinha, $$RefeicoesTableReferences),
          RefeicaoLinha,
          PrefetchHooks Function({bool petId})
        > {
  $$RefeicoesTableTableManager(_$BancoLocal db, $RefeicoesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RefeicoesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RefeicoesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RefeicoesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<String?> alimentoId = const Value.absent(),
                Value<String> alimentoNome = const Value.absent(),
                Value<double> densidadeKcalPor100g = const Value.absent(),
                Value<double> quantidadeG = const Value.absent(),
                Value<double> energiaKcal = const Value.absent(),
                Value<DateTime> dataHora = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RefeicoesCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                alimentoId: alimentoId,
                alimentoNome: alimentoNome,
                densidadeKcalPor100g: densidadeKcalPor100g,
                quantidadeG: quantidadeG,
                energiaKcal: energiaKcal,
                dataHora: dataHora,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                required String petId,
                Value<String?> alimentoId = const Value.absent(),
                required String alimentoNome,
                required double densidadeKcalPor100g,
                required double quantidadeG,
                required double energiaKcal,
                required DateTime dataHora,
                Value<int> rowid = const Value.absent(),
              }) => RefeicoesCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                alimentoId: alimentoId,
                alimentoNome: alimentoNome,
                densidadeKcalPor100g: densidadeKcalPor100g,
                quantidadeG: quantidadeG,
                energiaKcal: energiaKcal,
                dataHora: dataHora,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RefeicoesTable, RefeicaoLinha>(table),
                  $$RefeicoesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.petId,
                        referencedTable: $$RefeicoesTableReferences._petIdTable(
                          db,
                        ),
                        referencedColumn: $$RefeicoesTableReferences
                            ._petIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RefeicoesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $RefeicoesTable,
      RefeicaoLinha,
      $$RefeicoesTableFilterComposer,
      $$RefeicoesTableOrderingComposer,
      $$RefeicoesTableAnnotationComposer,
      $$RefeicoesTableCreateCompanionBuilder,
      $$RefeicoesTableUpdateCompanionBuilder,
      (RefeicaoLinha, $$RefeicoesTableReferences),
      RefeicaoLinha,
      PrefetchHooks Function({bool petId})
    >;
typedef $$ExtrasTableCreateCompanionBuilder = ExtrasCompanion Function({
  required String id,
  required DateTime criadoEm,
  required DateTime atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  required String petId,
  Value<String?> alimentoId,
  required String descricao,
  Value<double?> quantidadeG,
  Value<int?> unidades,
  required double energiaKcal,
  required DateTime dataHora,
  Value<int> rowid,
});
typedef $$ExtrasTableUpdateCompanionBuilder = ExtrasCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  Value<String> petId,
  Value<String?> alimentoId,
  Value<String> descricao,
  Value<double?> quantidadeG,
  Value<int?> unidades,
  Value<double> energiaKcal,
  Value<DateTime> dataHora,
  Value<int> rowid,
});

final class $$ExtrasTableReferences
    extends BaseReferences<_$BancoLocal, $ExtrasTable, ExtraLinha> {
  $$ExtrasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$BancoLocal db) =>
      db.pets.createAlias('extras__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<String>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExtrasTableFilterComposer extends Composer<_$BancoLocal, $ExtrasTable> {
  $$ExtrasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alimentoId => $composableBuilder(
    column: $table.alimentoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantidadeG => $composableBuilder(
    column: $table.quantidadeG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unidades => $composableBuilder(
    column: $table.unidades,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energiaKcal => $composableBuilder(
    column: $table.energiaKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExtrasTableOrderingComposer
    extends Composer<_$BancoLocal, $ExtrasTable> {
  $$ExtrasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alimentoId => $composableBuilder(
    column: $table.alimentoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descricao => $composableBuilder(
    column: $table.descricao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantidadeG => $composableBuilder(
    column: $table.quantidadeG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unidades => $composableBuilder(
    column: $table.unidades,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energiaKcal => $composableBuilder(
    column: $table.energiaKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExtrasTableAnnotationComposer
    extends Composer<_$BancoLocal, $ExtrasTable> {
  $$ExtrasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versao =>
      $composableBuilder(column: $table.versao, builder: (column) => column);

  GeneratedColumn<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excluido =>
      $composableBuilder(column: $table.excluido, builder: (column) => column);

  GeneratedColumn<String> get alimentoId => $composableBuilder(
    column: $table.alimentoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get descricao =>
      $composableBuilder(column: $table.descricao, builder: (column) => column);

  GeneratedColumn<double> get quantidadeG => $composableBuilder(
    column: $table.quantidadeG,
    builder: (column) => column,
  );

  GeneratedColumn<int> get unidades =>
      $composableBuilder(column: $table.unidades, builder: (column) => column);

  GeneratedColumn<double> get energiaKcal => $composableBuilder(
    column: $table.energiaKcal,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataHora =>
      $composableBuilder(column: $table.dataHora, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExtrasTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $ExtrasTable,
          ExtraLinha,
          $$ExtrasTableFilterComposer,
          $$ExtrasTableOrderingComposer,
          $$ExtrasTableAnnotationComposer,
          $$ExtrasTableCreateCompanionBuilder,
          $$ExtrasTableUpdateCompanionBuilder,
          (ExtraLinha, $$ExtrasTableReferences),
          ExtraLinha,
          PrefetchHooks Function({bool petId})
        > {
  $$ExtrasTableTableManager(_$BancoLocal db, $ExtrasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExtrasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExtrasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExtrasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<String?> alimentoId = const Value.absent(),
                Value<String> descricao = const Value.absent(),
                Value<double?> quantidadeG = const Value.absent(),
                Value<int?> unidades = const Value.absent(),
                Value<double> energiaKcal = const Value.absent(),
                Value<DateTime> dataHora = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExtrasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                alimentoId: alimentoId,
                descricao: descricao,
                quantidadeG: quantidadeG,
                unidades: unidades,
                energiaKcal: energiaKcal,
                dataHora: dataHora,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                required String petId,
                Value<String?> alimentoId = const Value.absent(),
                required String descricao,
                Value<double?> quantidadeG = const Value.absent(),
                Value<int?> unidades = const Value.absent(),
                required double energiaKcal,
                required DateTime dataHora,
                Value<int> rowid = const Value.absent(),
              }) => ExtrasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                alimentoId: alimentoId,
                descricao: descricao,
                quantidadeG: quantidadeG,
                unidades: unidades,
                energiaKcal: energiaKcal,
                dataHora: dataHora,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExtrasTable, ExtraLinha>(table),
                  $$ExtrasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.petId,
                        referencedTable: $$ExtrasTableReferences._petIdTable(
                          db,
                        ),
                        referencedColumn: $$ExtrasTableReferences
                            ._petIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExtrasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $ExtrasTable,
      ExtraLinha,
      $$ExtrasTableFilterComposer,
      $$ExtrasTableOrderingComposer,
      $$ExtrasTableAnnotationComposer,
      $$ExtrasTableCreateCompanionBuilder,
      $$ExtrasTableUpdateCompanionBuilder,
      (ExtraLinha, $$ExtrasTableReferences),
      ExtraLinha,
      PrefetchHooks Function({bool petId})
    >;
typedef $$AtividadesTableCreateCompanionBuilder = AtividadesCompanion Function({
  required String id,
  required DateTime criadoEm,
  required DateTime atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  required String petId,
  required String tipo,
  required int duracaoMin,
  required DateTime dataHora,
  Value<int> rowid,
});
typedef $$AtividadesTableUpdateCompanionBuilder = AtividadesCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  Value<String> petId,
  Value<String> tipo,
  Value<int> duracaoMin,
  Value<DateTime> dataHora,
  Value<int> rowid,
});

final class $$AtividadesTableReferences
    extends BaseReferences<_$BancoLocal, $AtividadesTable, AtividadeLinha> {
  $$AtividadesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$BancoLocal db) =>
      db.pets.createAlias('atividades__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<String>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AtividadesTableFilterComposer
    extends Composer<_$BancoLocal, $AtividadesTable> {
  $$AtividadesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get duracaoMin => $composableBuilder(
    column: $table.duracaoMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AtividadesTableOrderingComposer
    extends Composer<_$BancoLocal, $AtividadesTable> {
  $$AtividadesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get duracaoMin => $composableBuilder(
    column: $table.duracaoMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AtividadesTableAnnotationComposer
    extends Composer<_$BancoLocal, $AtividadesTable> {
  $$AtividadesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versao =>
      $composableBuilder(column: $table.versao, builder: (column) => column);

  GeneratedColumn<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excluido =>
      $composableBuilder(column: $table.excluido, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<int> get duracaoMin => $composableBuilder(
    column: $table.duracaoMin,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dataHora =>
      $composableBuilder(column: $table.dataHora, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AtividadesTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $AtividadesTable,
          AtividadeLinha,
          $$AtividadesTableFilterComposer,
          $$AtividadesTableOrderingComposer,
          $$AtividadesTableAnnotationComposer,
          $$AtividadesTableCreateCompanionBuilder,
          $$AtividadesTableUpdateCompanionBuilder,
          (AtividadeLinha, $$AtividadesTableReferences),
          AtividadeLinha,
          PrefetchHooks Function({bool petId})
        > {
  $$AtividadesTableTableManager(_$BancoLocal db, $AtividadesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AtividadesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AtividadesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AtividadesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<int> duracaoMin = const Value.absent(),
                Value<DateTime> dataHora = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AtividadesCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                tipo: tipo,
                duracaoMin: duracaoMin,
                dataHora: dataHora,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                required String petId,
                required String tipo,
                required int duracaoMin,
                required DateTime dataHora,
                Value<int> rowid = const Value.absent(),
              }) => AtividadesCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                tipo: tipo,
                duracaoMin: duracaoMin,
                dataHora: dataHora,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AtividadesTable, AtividadeLinha>(table),
                  $$AtividadesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.petId,
                        referencedTable: $$AtividadesTableReferences
                            ._petIdTable(db),
                        referencedColumn: $$AtividadesTableReferences
                            ._petIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AtividadesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $AtividadesTable,
      AtividadeLinha,
      $$AtividadesTableFilterComposer,
      $$AtividadesTableOrderingComposer,
      $$AtividadesTableAnnotationComposer,
      $$AtividadesTableCreateCompanionBuilder,
      $$AtividadesTableUpdateCompanionBuilder,
      (AtividadeLinha, $$AtividadesTableReferences),
      AtividadeLinha,
      PrefetchHooks Function({bool petId})
    >;
typedef $$LembretesTableCreateCompanionBuilder = LembretesCompanion Function({
  required String id,
  required DateTime criadoEm,
  required DateTime atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  required String petId,
  required int hora,
  required String tipo,
  Value<bool> ativo,
  required int notificacaoId,
  Value<int> rowid,
});
typedef $$LembretesTableUpdateCompanionBuilder = LembretesCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  Value<String> petId,
  Value<int> hora,
  Value<String> tipo,
  Value<bool> ativo,
  Value<int> notificacaoId,
  Value<int> rowid,
});

final class $$LembretesTableReferences
    extends BaseReferences<_$BancoLocal, $LembretesTable, LembreteLinha> {
  $$LembretesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$BancoLocal db) =>
      db.pets.createAlias('lembretes__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<String>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LembretesTableFilterComposer
    extends Composer<_$BancoLocal, $LembretesTable> {
  $$LembretesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificacaoId => $composableBuilder(
    column: $table.notificacaoId,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LembretesTableOrderingComposer
    extends Composer<_$BancoLocal, $LembretesTable> {
  $$LembretesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hora => $composableBuilder(
    column: $table.hora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tipo => $composableBuilder(
    column: $table.tipo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get ativo => $composableBuilder(
    column: $table.ativo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificacaoId => $composableBuilder(
    column: $table.notificacaoId,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LembretesTableAnnotationComposer
    extends Composer<_$BancoLocal, $LembretesTable> {
  $$LembretesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versao =>
      $composableBuilder(column: $table.versao, builder: (column) => column);

  GeneratedColumn<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excluido =>
      $composableBuilder(column: $table.excluido, builder: (column) => column);

  GeneratedColumn<int> get hora =>
      $composableBuilder(column: $table.hora, builder: (column) => column);

  GeneratedColumn<String> get tipo =>
      $composableBuilder(column: $table.tipo, builder: (column) => column);

  GeneratedColumn<bool> get ativo =>
      $composableBuilder(column: $table.ativo, builder: (column) => column);

  GeneratedColumn<int> get notificacaoId => $composableBuilder(
    column: $table.notificacaoId,
    builder: (column) => column,
  );

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LembretesTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $LembretesTable,
          LembreteLinha,
          $$LembretesTableFilterComposer,
          $$LembretesTableOrderingComposer,
          $$LembretesTableAnnotationComposer,
          $$LembretesTableCreateCompanionBuilder,
          $$LembretesTableUpdateCompanionBuilder,
          (LembreteLinha, $$LembretesTableReferences),
          LembreteLinha,
          PrefetchHooks Function({bool petId})
        > {
  $$LembretesTableTableManager(_$BancoLocal db, $LembretesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LembretesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LembretesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LembretesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<int> hora = const Value.absent(),
                Value<String> tipo = const Value.absent(),
                Value<bool> ativo = const Value.absent(),
                Value<int> notificacaoId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LembretesCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                hora: hora,
                tipo: tipo,
                ativo: ativo,
                notificacaoId: notificacaoId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                required String petId,
                required int hora,
                required String tipo,
                Value<bool> ativo = const Value.absent(),
                required int notificacaoId,
                Value<int> rowid = const Value.absent(),
              }) => LembretesCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                hora: hora,
                tipo: tipo,
                ativo: ativo,
                notificacaoId: notificacaoId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LembretesTable, LembreteLinha>(table),
                  $$LembretesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.petId,
                        referencedTable: $$LembretesTableReferences._petIdTable(
                          db,
                        ),
                        referencedColumn: $$LembretesTableReferences
                            ._petIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$LembretesTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $LembretesTable,
      LembreteLinha,
      $$LembretesTableFilterComposer,
      $$LembretesTableOrderingComposer,
      $$LembretesTableAnnotationComposer,
      $$LembretesTableCreateCompanionBuilder,
      $$LembretesTableUpdateCompanionBuilder,
      (LembreteLinha, $$LembretesTableReferences),
      LembreteLinha,
      PrefetchHooks Function({bool petId})
    >;
typedef $$PesagensTableCreateCompanionBuilder = PesagensCompanion Function({
  required String id,
  required DateTime criadoEm,
  required DateTime atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  required String petId,
  required double pesoKg,
  required DateTime dataHora,
  Value<bool> conferida,
  Value<int> rowid,
});
typedef $$PesagensTableUpdateCompanionBuilder = PesagensCompanion Function({
  Value<String> id,
  Value<DateTime> criadoEm,
  Value<DateTime> atualizadoEm,
  Value<int> versao,
  Value<int?> versaoRemota,
  Value<String> estadoSync,
  Value<bool> excluido,
  Value<String> petId,
  Value<double> pesoKg,
  Value<DateTime> dataHora,
  Value<bool> conferida,
  Value<int> rowid,
});

final class $$PesagensTableReferences
    extends BaseReferences<_$BancoLocal, $PesagensTable, PesagemLinha> {
  $$PesagensTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$BancoLocal db) =>
      db.pets.createAlias('pesagens__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<String>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PesagensTableFilterComposer
    extends Composer<_$BancoLocal, $PesagensTable> {
  $$PesagensTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pesoKg => $composableBuilder(
    column: $table.pesoKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get conferida => $composableBuilder(
    column: $table.conferida,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PesagensTableOrderingComposer
    extends Composer<_$BancoLocal, $PesagensTable> {
  $$PesagensTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pesoKg => $composableBuilder(
    column: $table.pesoKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dataHora => $composableBuilder(
    column: $table.dataHora,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get conferida => $composableBuilder(
    column: $table.conferida,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PesagensTableAnnotationComposer
    extends Composer<_$BancoLocal, $PesagensTable> {
  $$PesagensTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versao =>
      $composableBuilder(column: $table.versao, builder: (column) => column);

  GeneratedColumn<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excluido =>
      $composableBuilder(column: $table.excluido, builder: (column) => column);

  GeneratedColumn<double> get pesoKg =>
      $composableBuilder(column: $table.pesoKg, builder: (column) => column);

  GeneratedColumn<DateTime> get dataHora =>
      $composableBuilder(column: $table.dataHora, builder: (column) => column);

  GeneratedColumn<bool> get conferida =>
      $composableBuilder(column: $table.conferida, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PesagensTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $PesagensTable,
          PesagemLinha,
          $$PesagensTableFilterComposer,
          $$PesagensTableOrderingComposer,
          $$PesagensTableAnnotationComposer,
          $$PesagensTableCreateCompanionBuilder,
          $$PesagensTableUpdateCompanionBuilder,
          (PesagemLinha, $$PesagensTableReferences),
          PesagemLinha,
          PrefetchHooks Function({bool petId})
        > {
  $$PesagensTableTableManager(_$BancoLocal db, $PesagensTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PesagensTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PesagensTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PesagensTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<double> pesoKg = const Value.absent(),
                Value<DateTime> dataHora = const Value.absent(),
                Value<bool> conferida = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PesagensCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                pesoKg: pesoKg,
                dataHora: dataHora,
                conferida: conferida,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                required String petId,
                required double pesoKg,
                required DateTime dataHora,
                Value<bool> conferida = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PesagensCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                pesoKg: pesoKg,
                dataHora: dataHora,
                conferida: conferida,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PesagensTable, PesagemLinha>(table),
                  $$PesagensTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.petId,
                        referencedTable: $$PesagensTableReferences._petIdTable(
                          db,
                        ),
                        referencedColumn: $$PesagensTableReferences
                            ._petIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PesagensTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $PesagensTable,
      PesagemLinha,
      $$PesagensTableFilterComposer,
      $$PesagensTableOrderingComposer,
      $$PesagensTableAnnotationComposer,
      $$PesagensTableCreateCompanionBuilder,
      $$PesagensTableUpdateCompanionBuilder,
      (PesagemLinha, $$PesagensTableReferences),
      PesagemLinha,
      PrefetchHooks Function({bool petId})
    >;
typedef $$ReferenciasTableCreateCompanionBuilder =
    ReferenciasCompanion Function({
      required String id,
      required DateTime criadoEm,
      required DateTime atualizadoEm,
      Value<int> versao,
      Value<int?> versaoRemota,
      Value<String> estadoSync,
      Value<bool> excluido,
      required String petId,
      Value<int?> ecc,
      Value<double?> objetivoKg,
      required String origem,
      required DateTime data,
      Value<int> rowid,
    });
typedef $$ReferenciasTableUpdateCompanionBuilder =
    ReferenciasCompanion Function({
      Value<String> id,
      Value<DateTime> criadoEm,
      Value<DateTime> atualizadoEm,
      Value<int> versao,
      Value<int?> versaoRemota,
      Value<String> estadoSync,
      Value<bool> excluido,
      Value<String> petId,
      Value<int?> ecc,
      Value<double?> objetivoKg,
      Value<String> origem,
      Value<DateTime> data,
      Value<int> rowid,
    });

final class $$ReferenciasTableReferences
    extends BaseReferences<_$BancoLocal, $ReferenciasTable, ReferenciaLinha> {
  $$ReferenciasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PetsTable _petIdTable(_$BancoLocal db) =>
      db.pets.createAlias('referencias__pet_id__pets__id');

  $$PetsTableProcessedTableManager get petId {
    final $_column = $_itemColumn<String>('pet_id')!;

    final manager = $$PetsTableTableManager(
      $_db,
      $_db.pets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_petIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReferenciasTableFilterComposer
    extends Composer<_$BancoLocal, $ReferenciasTable> {
  $$ReferenciasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ecc => $composableBuilder(
    column: $table.ecc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get objetivoKg => $composableBuilder(
    column: $table.objetivoKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  $$PetsTableFilterComposer get petId {
    final $$PetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableFilterComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReferenciasTableOrderingComposer
    extends Composer<_$BancoLocal, $ReferenciasTable> {
  $$ReferenciasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versao => $composableBuilder(
    column: $table.versao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get excluido => $composableBuilder(
    column: $table.excluido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ecc => $composableBuilder(
    column: $table.ecc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get objetivoKg => $composableBuilder(
    column: $table.objetivoKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get origem => $composableBuilder(
    column: $table.origem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  $$PetsTableOrderingComposer get petId {
    final $$PetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableOrderingComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReferenciasTableAnnotationComposer
    extends Composer<_$BancoLocal, $ReferenciasTable> {
  $$ReferenciasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<DateTime> get atualizadoEm => $composableBuilder(
    column: $table.atualizadoEm,
    builder: (column) => column,
  );

  GeneratedColumn<int> get versao =>
      $composableBuilder(column: $table.versao, builder: (column) => column);

  GeneratedColumn<int> get versaoRemota => $composableBuilder(
    column: $table.versaoRemota,
    builder: (column) => column,
  );

  GeneratedColumn<String> get estadoSync => $composableBuilder(
    column: $table.estadoSync,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get excluido =>
      $composableBuilder(column: $table.excluido, builder: (column) => column);

  GeneratedColumn<int> get ecc =>
      $composableBuilder(column: $table.ecc, builder: (column) => column);

  GeneratedColumn<double> get objetivoKg => $composableBuilder(
    column: $table.objetivoKg,
    builder: (column) => column,
  );

  GeneratedColumn<String> get origem =>
      $composableBuilder(column: $table.origem, builder: (column) => column);

  GeneratedColumn<DateTime> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  $$PetsTableAnnotationComposer get petId {
    final $$PetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.petId,
      referencedTable: $db.pets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PetsTableAnnotationComposer(
            $db: $db,
            $table: $db.pets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReferenciasTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $ReferenciasTable,
          ReferenciaLinha,
          $$ReferenciasTableFilterComposer,
          $$ReferenciasTableOrderingComposer,
          $$ReferenciasTableAnnotationComposer,
          $$ReferenciasTableCreateCompanionBuilder,
          $$ReferenciasTableUpdateCompanionBuilder,
          (ReferenciaLinha, $$ReferenciasTableReferences),
          ReferenciaLinha,
          PrefetchHooks Function({bool petId})
        > {
  $$ReferenciasTableTableManager(_$BancoLocal db, $ReferenciasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReferenciasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReferenciasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReferenciasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<DateTime> atualizadoEm = const Value.absent(),
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                Value<String> petId = const Value.absent(),
                Value<int?> ecc = const Value.absent(),
                Value<double?> objetivoKg = const Value.absent(),
                Value<String> origem = const Value.absent(),
                Value<DateTime> data = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReferenciasCompanion(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                ecc: ecc,
                objetivoKg: objetivoKg,
                origem: origem,
                data: data,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime criadoEm,
                required DateTime atualizadoEm,
                Value<int> versao = const Value.absent(),
                Value<int?> versaoRemota = const Value.absent(),
                Value<String> estadoSync = const Value.absent(),
                Value<bool> excluido = const Value.absent(),
                required String petId,
                Value<int?> ecc = const Value.absent(),
                Value<double?> objetivoKg = const Value.absent(),
                required String origem,
                required DateTime data,
                Value<int> rowid = const Value.absent(),
              }) => ReferenciasCompanion.insert(
                id: id,
                criadoEm: criadoEm,
                atualizadoEm: atualizadoEm,
                versao: versao,
                versaoRemota: versaoRemota,
                estadoSync: estadoSync,
                excluido: excluido,
                petId: petId,
                ecc: ecc,
                objetivoKg: objetivoKg,
                origem: origem,
                data: data,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReferenciasTable, ReferenciaLinha>(table),
                  $$ReferenciasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({petId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (petId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.petId,
                        referencedTable: $$ReferenciasTableReferences
                            ._petIdTable(db),
                        referencedColumn: $$ReferenciasTableReferences
                            ._petIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReferenciasTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $ReferenciasTable,
      ReferenciaLinha,
      $$ReferenciasTableFilterComposer,
      $$ReferenciasTableOrderingComposer,
      $$ReferenciasTableAnnotationComposer,
      $$ReferenciasTableCreateCompanionBuilder,
      $$ReferenciasTableUpdateCompanionBuilder,
      (ReferenciaLinha, $$ReferenciasTableReferences),
      ReferenciaLinha,
      PrefetchHooks Function({bool petId})
    >;
typedef $$ItensFilaSyncTableCreateCompanionBuilder =
    ItensFilaSyncCompanion Function({
      Value<int> id,
      required String tabela,
      required String registroId,
      required String operacao,
      required DateTime criadoEm,
      Value<int> tentativas,
      Value<String?> ultimoErro,
    });
typedef $$ItensFilaSyncTableUpdateCompanionBuilder =
    ItensFilaSyncCompanion Function({
      Value<int> id,
      Value<String> tabela,
      Value<String> registroId,
      Value<String> operacao,
      Value<DateTime> criadoEm,
      Value<int> tentativas,
      Value<String?> ultimoErro,
    });

class $$ItensFilaSyncTableFilterComposer
    extends Composer<_$BancoLocal, $ItensFilaSyncTable> {
  $$ItensFilaSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tabela => $composableBuilder(
    column: $table.tabela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operacao => $composableBuilder(
    column: $table.operacao,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tentativas => $composableBuilder(
    column: $table.tentativas,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ultimoErro => $composableBuilder(
    column: $table.ultimoErro,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ItensFilaSyncTableOrderingComposer
    extends Composer<_$BancoLocal, $ItensFilaSyncTable> {
  $$ItensFilaSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tabela => $composableBuilder(
    column: $table.tabela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operacao => $composableBuilder(
    column: $table.operacao,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get criadoEm => $composableBuilder(
    column: $table.criadoEm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tentativas => $composableBuilder(
    column: $table.tentativas,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ultimoErro => $composableBuilder(
    column: $table.ultimoErro,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ItensFilaSyncTableAnnotationComposer
    extends Composer<_$BancoLocal, $ItensFilaSyncTable> {
  $$ItensFilaSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get tabela =>
      $composableBuilder(column: $table.tabela, builder: (column) => column);

  GeneratedColumn<String> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get operacao =>
      $composableBuilder(column: $table.operacao, builder: (column) => column);

  GeneratedColumn<DateTime> get criadoEm =>
      $composableBuilder(column: $table.criadoEm, builder: (column) => column);

  GeneratedColumn<int> get tentativas => $composableBuilder(
    column: $table.tentativas,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ultimoErro => $composableBuilder(
    column: $table.ultimoErro,
    builder: (column) => column,
  );
}

class $$ItensFilaSyncTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $ItensFilaSyncTable,
          FilaSyncLinha,
          $$ItensFilaSyncTableFilterComposer,
          $$ItensFilaSyncTableOrderingComposer,
          $$ItensFilaSyncTableAnnotationComposer,
          $$ItensFilaSyncTableCreateCompanionBuilder,
          $$ItensFilaSyncTableUpdateCompanionBuilder,
          (
            FilaSyncLinha,
            BaseReferences<_$BancoLocal, $ItensFilaSyncTable, FilaSyncLinha>,
          ),
          FilaSyncLinha,
          PrefetchHooks Function()
        > {
  $$ItensFilaSyncTableTableManager(_$BancoLocal db, $ItensFilaSyncTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ItensFilaSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ItensFilaSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ItensFilaSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> tabela = const Value.absent(),
                Value<String> registroId = const Value.absent(),
                Value<String> operacao = const Value.absent(),
                Value<DateTime> criadoEm = const Value.absent(),
                Value<int> tentativas = const Value.absent(),
                Value<String?> ultimoErro = const Value.absent(),
              }) => ItensFilaSyncCompanion(
                id: id,
                tabela: tabela,
                registroId: registroId,
                operacao: operacao,
                criadoEm: criadoEm,
                tentativas: tentativas,
                ultimoErro: ultimoErro,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String tabela,
                required String registroId,
                required String operacao,
                required DateTime criadoEm,
                Value<int> tentativas = const Value.absent(),
                Value<String?> ultimoErro = const Value.absent(),
              }) => ItensFilaSyncCompanion.insert(
                id: id,
                tabela: tabela,
                registroId: registroId,
                operacao: operacao,
                criadoEm: criadoEm,
                tentativas: tentativas,
                ultimoErro: ultimoErro,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ItensFilaSyncTable, FilaSyncLinha>(table),
                  BaseReferences<
                    _$BancoLocal,
                    $ItensFilaSyncTable,
                    FilaSyncLinha
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ItensFilaSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $ItensFilaSyncTable,
      FilaSyncLinha,
      $$ItensFilaSyncTableFilterComposer,
      $$ItensFilaSyncTableOrderingComposer,
      $$ItensFilaSyncTableAnnotationComposer,
      $$ItensFilaSyncTableCreateCompanionBuilder,
      $$ItensFilaSyncTableUpdateCompanionBuilder,
      (
        FilaSyncLinha,
        BaseReferences<_$BancoLocal, $ItensFilaSyncTable, FilaSyncLinha>,
      ),
      FilaSyncLinha,
      PrefetchHooks Function()
    >;
typedef $$ConflitosTableCreateCompanionBuilder = ConflitosCompanion Function({
  required String tabela,
  required String registroId,
  required String dadosRemotos,
  required DateTime detectadoEm,
  Value<int> rowid,
});
typedef $$ConflitosTableUpdateCompanionBuilder = ConflitosCompanion Function({
  Value<String> tabela,
  Value<String> registroId,
  Value<String> dadosRemotos,
  Value<DateTime> detectadoEm,
  Value<int> rowid,
});

class $$ConflitosTableFilterComposer
    extends Composer<_$BancoLocal, $ConflitosTable> {
  $$ConflitosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get tabela => $composableBuilder(
    column: $table.tabela,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dadosRemotos => $composableBuilder(
    column: $table.dadosRemotos,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectadoEm => $composableBuilder(
    column: $table.detectadoEm,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConflitosTableOrderingComposer
    extends Composer<_$BancoLocal, $ConflitosTable> {
  $$ConflitosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get tabela => $composableBuilder(
    column: $table.tabela,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dadosRemotos => $composableBuilder(
    column: $table.dadosRemotos,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectadoEm => $composableBuilder(
    column: $table.detectadoEm,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConflitosTableAnnotationComposer
    extends Composer<_$BancoLocal, $ConflitosTable> {
  $$ConflitosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get tabela =>
      $composableBuilder(column: $table.tabela, builder: (column) => column);

  GeneratedColumn<String> get registroId => $composableBuilder(
    column: $table.registroId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dadosRemotos => $composableBuilder(
    column: $table.dadosRemotos,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectadoEm => $composableBuilder(
    column: $table.detectadoEm,
    builder: (column) => column,
  );
}

class $$ConflitosTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $ConflitosTable,
          ConflitoLinha,
          $$ConflitosTableFilterComposer,
          $$ConflitosTableOrderingComposer,
          $$ConflitosTableAnnotationComposer,
          $$ConflitosTableCreateCompanionBuilder,
          $$ConflitosTableUpdateCompanionBuilder,
          (
            ConflitoLinha,
            BaseReferences<_$BancoLocal, $ConflitosTable, ConflitoLinha>,
          ),
          ConflitoLinha,
          PrefetchHooks Function()
        > {
  $$ConflitosTableTableManager(_$BancoLocal db, $ConflitosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflitosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflitosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflitosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> tabela = const Value.absent(),
                Value<String> registroId = const Value.absent(),
                Value<String> dadosRemotos = const Value.absent(),
                Value<DateTime> detectadoEm = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflitosCompanion(
                tabela: tabela,
                registroId: registroId,
                dadosRemotos: dadosRemotos,
                detectadoEm: detectadoEm,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String tabela,
                required String registroId,
                required String dadosRemotos,
                required DateTime detectadoEm,
                Value<int> rowid = const Value.absent(),
              }) => ConflitosCompanion.insert(
                tabela: tabela,
                registroId: registroId,
                dadosRemotos: dadosRemotos,
                detectadoEm: detectadoEm,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConflitosTable, ConflitoLinha>(table),
                  BaseReferences<_$BancoLocal, $ConflitosTable, ConflitoLinha>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConflitosTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $ConflitosTable,
      ConflitoLinha,
      $$ConflitosTableFilterComposer,
      $$ConflitosTableOrderingComposer,
      $$ConflitosTableAnnotationComposer,
      $$ConflitosTableCreateCompanionBuilder,
      $$ConflitosTableUpdateCompanionBuilder,
      (
        ConflitoLinha,
        BaseReferences<_$BancoLocal, $ConflitosTable, ConflitoLinha>,
      ),
      ConflitoLinha,
      PrefetchHooks Function()
    >;
typedef $$ConfigTableCreateCompanionBuilder = ConfigCompanion Function({
  required String chave,
  Value<String?> valor,
  Value<int> rowid,
});
typedef $$ConfigTableUpdateCompanionBuilder = ConfigCompanion Function({
  Value<String> chave,
  Value<String?> valor,
  Value<int> rowid,
});

class $$ConfigTableFilterComposer extends Composer<_$BancoLocal, $ConfigTable> {
  $$ConfigTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfigTableOrderingComposer
    extends Composer<_$BancoLocal, $ConfigTable> {
  $$ConfigTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chave => $composableBuilder(
    column: $table.chave,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get valor => $composableBuilder(
    column: $table.valor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfigTableAnnotationComposer
    extends Composer<_$BancoLocal, $ConfigTable> {
  $$ConfigTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chave =>
      $composableBuilder(column: $table.chave, builder: (column) => column);

  GeneratedColumn<String> get valor =>
      $composableBuilder(column: $table.valor, builder: (column) => column);
}

class $$ConfigTableTableManager
    extends
        RootTableManager<
          _$BancoLocal,
          $ConfigTable,
          ConfigLinha,
          $$ConfigTableFilterComposer,
          $$ConfigTableOrderingComposer,
          $$ConfigTableAnnotationComposer,
          $$ConfigTableCreateCompanionBuilder,
          $$ConfigTableUpdateCompanionBuilder,
          (
            ConfigLinha,
            BaseReferences<_$BancoLocal, $ConfigTable, ConfigLinha>,
          ),
          ConfigLinha,
          PrefetchHooks Function()
        > {
  $$ConfigTableTableManager(_$BancoLocal db, $ConfigTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfigTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> chave = const Value.absent(),
            Value<String?> valor = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ConfigCompanion(chave: chave, valor: valor, rowid: rowid),
          createCompanionCallback:
              ({
                required String chave,
                Value<String?> valor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfigCompanion.insert(
                chave: chave,
                valor: valor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfigTable, ConfigLinha>(table),
                  BaseReferences<_$BancoLocal, $ConfigTable, ConfigLinha>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfigTableProcessedTableManager =
    ProcessedTableManager<
      _$BancoLocal,
      $ConfigTable,
      ConfigLinha,
      $$ConfigTableFilterComposer,
      $$ConfigTableOrderingComposer,
      $$ConfigTableAnnotationComposer,
      $$ConfigTableCreateCompanionBuilder,
      $$ConfigTableUpdateCompanionBuilder,
      (ConfigLinha, BaseReferences<_$BancoLocal, $ConfigTable, ConfigLinha>),
      ConfigLinha,
      PrefetchHooks Function()
    >;

class $BancoLocalManager {
  final _$BancoLocal _db;
  $BancoLocalManager(this._db);
  $$PetsTableTableManager get pets => $$PetsTableTableManager(_db, _db.pets);
  $$AlimentosTableTableManager get alimentos =>
      $$AlimentosTableTableManager(_db, _db.alimentos);
  $$RefeicoesTableTableManager get refeicoes =>
      $$RefeicoesTableTableManager(_db, _db.refeicoes);
  $$ExtrasTableTableManager get extras =>
      $$ExtrasTableTableManager(_db, _db.extras);
  $$AtividadesTableTableManager get atividades =>
      $$AtividadesTableTableManager(_db, _db.atividades);
  $$LembretesTableTableManager get lembretes =>
      $$LembretesTableTableManager(_db, _db.lembretes);
  $$PesagensTableTableManager get pesagens =>
      $$PesagensTableTableManager(_db, _db.pesagens);
  $$ReferenciasTableTableManager get referencias =>
      $$ReferenciasTableTableManager(_db, _db.referencias);
  $$ItensFilaSyncTableTableManager get itensFilaSync =>
      $$ItensFilaSyncTableTableManager(_db, _db.itensFilaSync);
  $$ConflitosTableTableManager get conflitos =>
      $$ConflitosTableTableManager(_db, _db.conflitos);
  $$ConfigTableTableManager get config =>
      $$ConfigTableTableManager(_db, _db.config);
}
