// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
mixin _$TagsDaoMixin on DatabaseAccessor<AppDatabase> {
  $TagRowsTable get tagRows => attachedDatabase.tagRows;
  $NoteTagsTable get noteTags => attachedDatabase.noteTags;
  $NoteRowsTable get noteRows => attachedDatabase.noteRows;
  TagsDaoManager get managers => TagsDaoManager(this);
}

class TagsDaoManager {
  final _$TagsDaoMixin _db;
  TagsDaoManager(this._db);
  $$TagRowsTableTableManager get tagRows =>
      $$TagRowsTableTableManager(_db.attachedDatabase, _db.tagRows);
  $$NoteTagsTableTableManager get noteTags =>
      $$NoteTagsTableTableManager(_db.attachedDatabase, _db.noteTags);
  $$NoteRowsTableTableManager get noteRows =>
      $$NoteRowsTableTableManager(_db.attachedDatabase, _db.noteRows);
}

mixin _$SettingsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AppSettingsRowsTable get appSettingsRows => attachedDatabase.appSettingsRows;
  SettingsDaoManager get managers => SettingsDaoManager(this);
}

class SettingsDaoManager {
  final _$SettingsDaoMixin _db;
  SettingsDaoManager(this._db);
  $$AppSettingsRowsTableTableManager get appSettingsRows =>
      $$AppSettingsRowsTableTableManager(
        _db.attachedDatabase,
        _db.appSettingsRows,
      );
}

mixin _$AiConfigDaoMixin on DatabaseAccessor<AppDatabase> {
  $AiConfigRowsTable get aiConfigRows => attachedDatabase.aiConfigRows;
  AiConfigDaoManager get managers => AiConfigDaoManager(this);
}

class AiConfigDaoManager {
  final _$AiConfigDaoMixin _db;
  AiConfigDaoManager(this._db);
  $$AiConfigRowsTableTableManager get aiConfigRows =>
      $$AiConfigRowsTableTableManager(_db.attachedDatabase, _db.aiConfigRows);
}

mixin _$FoldersDaoMixin on DatabaseAccessor<AppDatabase> {
  $FolderRowsTable get folderRows => attachedDatabase.folderRows;
  FoldersDaoManager get managers => FoldersDaoManager(this);
}

class FoldersDaoManager {
  final _$FoldersDaoMixin _db;
  FoldersDaoManager(this._db);
  $$FolderRowsTableTableManager get folderRows =>
      $$FolderRowsTableTableManager(_db.attachedDatabase, _db.folderRows);
}

mixin _$NotesDaoMixin on DatabaseAccessor<AppDatabase> {
  $NoteRowsTable get noteRows => attachedDatabase.noteRows;
  NotesDaoManager get managers => NotesDaoManager(this);
}

class NotesDaoManager {
  final _$NotesDaoMixin _db;
  NotesDaoManager(this._db);
  $$NoteRowsTableTableManager get noteRows =>
      $$NoteRowsTableTableManager(_db.attachedDatabase, _db.noteRows);
}

mixin _$AttachmentsDaoMixin on DatabaseAccessor<AppDatabase> {
  $AttachmentRowsTable get attachmentRows => attachedDatabase.attachmentRows;
  AttachmentsDaoManager get managers => AttachmentsDaoManager(this);
}

class AttachmentsDaoManager {
  final _$AttachmentsDaoMixin _db;
  AttachmentsDaoManager(this._db);
  $$AttachmentRowsTableTableManager get attachmentRows =>
      $$AttachmentRowsTableTableManager(
        _db.attachedDatabase,
        _db.attachmentRows,
      );
}

mixin _$TimelineTasksDaoMixin on DatabaseAccessor<AppDatabase> {
  $TimelineTaskRowsTable get timelineTaskRows =>
      attachedDatabase.timelineTaskRows;
  TimelineTasksDaoManager get managers => TimelineTasksDaoManager(this);
}

class TimelineTasksDaoManager {
  final _$TimelineTasksDaoMixin _db;
  TimelineTasksDaoManager(this._db);
  $$TimelineTaskRowsTableTableManager get timelineTaskRows =>
      $$TimelineTaskRowsTableTableManager(
        _db.attachedDatabase,
        _db.timelineTaskRows,
      );
}

mixin _$RemindersDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReminderRowsTable get reminderRows => attachedDatabase.reminderRows;
  RemindersDaoManager get managers => RemindersDaoManager(this);
}

class RemindersDaoManager {
  final _$RemindersDaoMixin _db;
  RemindersDaoManager(this._db);
  $$ReminderRowsTableTableManager get reminderRows =>
      $$ReminderRowsTableTableManager(_db.attachedDatabase, _db.reminderRows);
}

class $AppSettingsRowsTable extends AppSettingsRows
    with TableInfo<$AppSettingsRowsTable, AppSettingsRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeColorMeta = const VerificationMeta(
    'themeColor',
  );
  @override
  late final GeneratedColumn<String> themeColor = GeneratedColumn<String>(
    'theme_color',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enableAppLockMeta = const VerificationMeta(
    'enableAppLock',
  );
  @override
  late final GeneratedColumn<bool> enableAppLock = GeneratedColumn<bool>(
    'enable_app_lock',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enable_app_lock" IN (0, 1))',
    ),
  );
  static const VerificationMeta _autoTranscribeVoiceMeta =
      const VerificationMeta('autoTranscribeVoice');
  @override
  late final GeneratedColumn<bool> autoTranscribeVoice = GeneratedColumn<bool>(
    'auto_transcribe_voice',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("auto_transcribe_voice" IN (0, 1))',
    ),
  );
  static const VerificationMeta _defaultFolderIdMeta = const VerificationMeta(
    'defaultFolderId',
  );
  @override
  late final GeneratedColumn<String> defaultFolderId = GeneratedColumn<String>(
    'default_folder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exportIncludeMetadataMeta =
      const VerificationMeta('exportIncludeMetadata');
  @override
  late final GeneratedColumn<bool> exportIncludeMetadata =
      GeneratedColumn<bool>(
        'export_include_metadata',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: true,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("export_include_metadata" IN (0, 1))',
        ),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    themeMode,
    themeColor,
    enableAppLock,
    autoTranscribeVoice,
    defaultFolderId,
    exportIncludeMetadata,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSettingsRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    } else if (isInserting) {
      context.missing(_themeModeMeta);
    }
    if (data.containsKey('theme_color')) {
      context.handle(
        _themeColorMeta,
        themeColor.isAcceptableOrUnknown(data['theme_color']!, _themeColorMeta),
      );
    } else if (isInserting) {
      context.missing(_themeColorMeta);
    }
    if (data.containsKey('enable_app_lock')) {
      context.handle(
        _enableAppLockMeta,
        enableAppLock.isAcceptableOrUnknown(
          data['enable_app_lock']!,
          _enableAppLockMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enableAppLockMeta);
    }
    if (data.containsKey('auto_transcribe_voice')) {
      context.handle(
        _autoTranscribeVoiceMeta,
        autoTranscribeVoice.isAcceptableOrUnknown(
          data['auto_transcribe_voice']!,
          _autoTranscribeVoiceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_autoTranscribeVoiceMeta);
    }
    if (data.containsKey('default_folder_id')) {
      context.handle(
        _defaultFolderIdMeta,
        defaultFolderId.isAcceptableOrUnknown(
          data['default_folder_id']!,
          _defaultFolderIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultFolderIdMeta);
    }
    if (data.containsKey('export_include_metadata')) {
      context.handle(
        _exportIncludeMetadataMeta,
        exportIncludeMetadata.isAcceptableOrUnknown(
          data['export_include_metadata']!,
          _exportIncludeMetadataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exportIncludeMetadataMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppSettingsRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingsRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      themeMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_mode'],
      )!,
      themeColor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_color'],
      )!,
      enableAppLock: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enable_app_lock'],
      )!,
      autoTranscribeVoice: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}auto_transcribe_voice'],
      )!,
      defaultFolderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_folder_id'],
      )!,
      exportIncludeMetadata: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}export_include_metadata'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $AppSettingsRowsTable createAlias(String alias) {
    return $AppSettingsRowsTable(attachedDatabase, alias);
  }
}

class AppSettingsRow extends DataClass implements Insertable<AppSettingsRow> {
  final String id;
  final String themeMode;
  final String themeColor;
  final bool enableAppLock;
  final bool autoTranscribeVoice;
  final String defaultFolderId;
  final bool exportIncludeMetadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  const AppSettingsRow({
    required this.id,
    required this.themeMode,
    required this.themeColor,
    required this.enableAppLock,
    required this.autoTranscribeVoice,
    required this.defaultFolderId,
    required this.exportIncludeMetadata,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['theme_color'] = Variable<String>(themeColor);
    map['enable_app_lock'] = Variable<bool>(enableAppLock);
    map['auto_transcribe_voice'] = Variable<bool>(autoTranscribeVoice);
    map['default_folder_id'] = Variable<String>(defaultFolderId);
    map['export_include_metadata'] = Variable<bool>(exportIncludeMetadata);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  AppSettingsRowsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsRowsCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      themeColor: Value(themeColor),
      enableAppLock: Value(enableAppLock),
      autoTranscribeVoice: Value(autoTranscribeVoice),
      defaultFolderId: Value(defaultFolderId),
      exportIncludeMetadata: Value(exportIncludeMetadata),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory AppSettingsRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingsRow(
      id: serializer.fromJson<String>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      themeColor: serializer.fromJson<String>(json['themeColor']),
      enableAppLock: serializer.fromJson<bool>(json['enableAppLock']),
      autoTranscribeVoice: serializer.fromJson<bool>(
        json['autoTranscribeVoice'],
      ),
      defaultFolderId: serializer.fromJson<String>(json['defaultFolderId']),
      exportIncludeMetadata: serializer.fromJson<bool>(
        json['exportIncludeMetadata'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'themeColor': serializer.toJson<String>(themeColor),
      'enableAppLock': serializer.toJson<bool>(enableAppLock),
      'autoTranscribeVoice': serializer.toJson<bool>(autoTranscribeVoice),
      'defaultFolderId': serializer.toJson<String>(defaultFolderId),
      'exportIncludeMetadata': serializer.toJson<bool>(exportIncludeMetadata),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  AppSettingsRow copyWith({
    String? id,
    String? themeMode,
    String? themeColor,
    bool? enableAppLock,
    bool? autoTranscribeVoice,
    String? defaultFolderId,
    bool? exportIncludeMetadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => AppSettingsRow(
    id: id ?? this.id,
    themeMode: themeMode ?? this.themeMode,
    themeColor: themeColor ?? this.themeColor,
    enableAppLock: enableAppLock ?? this.enableAppLock,
    autoTranscribeVoice: autoTranscribeVoice ?? this.autoTranscribeVoice,
    defaultFolderId: defaultFolderId ?? this.defaultFolderId,
    exportIncludeMetadata: exportIncludeMetadata ?? this.exportIncludeMetadata,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  AppSettingsRow copyWithCompanion(AppSettingsRowsCompanion data) {
    return AppSettingsRow(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      themeColor: data.themeColor.present
          ? data.themeColor.value
          : this.themeColor,
      enableAppLock: data.enableAppLock.present
          ? data.enableAppLock.value
          : this.enableAppLock,
      autoTranscribeVoice: data.autoTranscribeVoice.present
          ? data.autoTranscribeVoice.value
          : this.autoTranscribeVoice,
      defaultFolderId: data.defaultFolderId.present
          ? data.defaultFolderId.value
          : this.defaultFolderId,
      exportIncludeMetadata: data.exportIncludeMetadata.present
          ? data.exportIncludeMetadata.value
          : this.exportIncludeMetadata,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRow(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('themeColor: $themeColor, ')
          ..write('enableAppLock: $enableAppLock, ')
          ..write('autoTranscribeVoice: $autoTranscribeVoice, ')
          ..write('defaultFolderId: $defaultFolderId, ')
          ..write('exportIncludeMetadata: $exportIncludeMetadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    themeMode,
    themeColor,
    enableAppLock,
    autoTranscribeVoice,
    defaultFolderId,
    exportIncludeMetadata,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingsRow &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.themeColor == this.themeColor &&
          other.enableAppLock == this.enableAppLock &&
          other.autoTranscribeVoice == this.autoTranscribeVoice &&
          other.defaultFolderId == this.defaultFolderId &&
          other.exportIncludeMetadata == this.exportIncludeMetadata &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class AppSettingsRowsCompanion extends UpdateCompanion<AppSettingsRow> {
  final Value<String> id;
  final Value<String> themeMode;
  final Value<String> themeColor;
  final Value<bool> enableAppLock;
  final Value<bool> autoTranscribeVoice;
  final Value<String> defaultFolderId;
  final Value<bool> exportIncludeMetadata;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const AppSettingsRowsCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.themeColor = const Value.absent(),
    this.enableAppLock = const Value.absent(),
    this.autoTranscribeVoice = const Value.absent(),
    this.defaultFolderId = const Value.absent(),
    this.exportIncludeMetadata = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsRowsCompanion.insert({
    required String id,
    required String themeMode,
    required String themeColor,
    required bool enableAppLock,
    required bool autoTranscribeVoice,
    required String defaultFolderId,
    required bool exportIncludeMetadata,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       themeMode = Value(themeMode),
       themeColor = Value(themeColor),
       enableAppLock = Value(enableAppLock),
       autoTranscribeVoice = Value(autoTranscribeVoice),
       defaultFolderId = Value(defaultFolderId),
       exportIncludeMetadata = Value(exportIncludeMetadata),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<AppSettingsRow> custom({
    Expression<String>? id,
    Expression<String>? themeMode,
    Expression<String>? themeColor,
    Expression<bool>? enableAppLock,
    Expression<bool>? autoTranscribeVoice,
    Expression<String>? defaultFolderId,
    Expression<bool>? exportIncludeMetadata,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (themeColor != null) 'theme_color': themeColor,
      if (enableAppLock != null) 'enable_app_lock': enableAppLock,
      if (autoTranscribeVoice != null)
        'auto_transcribe_voice': autoTranscribeVoice,
      if (defaultFolderId != null) 'default_folder_id': defaultFolderId,
      if (exportIncludeMetadata != null)
        'export_include_metadata': exportIncludeMetadata,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? themeMode,
    Value<String>? themeColor,
    Value<bool>? enableAppLock,
    Value<bool>? autoTranscribeVoice,
    Value<String>? defaultFolderId,
    Value<bool>? exportIncludeMetadata,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return AppSettingsRowsCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      themeColor: themeColor ?? this.themeColor,
      enableAppLock: enableAppLock ?? this.enableAppLock,
      autoTranscribeVoice: autoTranscribeVoice ?? this.autoTranscribeVoice,
      defaultFolderId: defaultFolderId ?? this.defaultFolderId,
      exportIncludeMetadata:
          exportIncludeMetadata ?? this.exportIncludeMetadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (themeColor.present) {
      map['theme_color'] = Variable<String>(themeColor.value);
    }
    if (enableAppLock.present) {
      map['enable_app_lock'] = Variable<bool>(enableAppLock.value);
    }
    if (autoTranscribeVoice.present) {
      map['auto_transcribe_voice'] = Variable<bool>(autoTranscribeVoice.value);
    }
    if (defaultFolderId.present) {
      map['default_folder_id'] = Variable<String>(defaultFolderId.value);
    }
    if (exportIncludeMetadata.present) {
      map['export_include_metadata'] = Variable<bool>(
        exportIncludeMetadata.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsRowsCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('themeColor: $themeColor, ')
          ..write('enableAppLock: $enableAppLock, ')
          ..write('autoTranscribeVoice: $autoTranscribeVoice, ')
          ..write('defaultFolderId: $defaultFolderId, ')
          ..write('exportIncludeMetadata: $exportIncludeMetadata, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AiConfigRowsTable extends AiConfigRows
    with TableInfo<$AiConfigRowsTable, AiConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AiConfigRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volcAsrEndpointMeta = const VerificationMeta(
    'volcAsrEndpoint',
  );
  @override
  late final GeneratedColumn<String> volcAsrEndpoint = GeneratedColumn<String>(
    'volc_asr_endpoint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _volcAsrResourceIdMeta = const VerificationMeta(
    'volcAsrResourceId',
  );
  @override
  late final GeneratedColumn<String> volcAsrResourceId =
      GeneratedColumn<String>(
        'volc_asr_resource_id',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _volcAsrLanguageMeta = const VerificationMeta(
    'volcAsrLanguage',
  );
  @override
  late final GeneratedColumn<String> volcAsrLanguage = GeneratedColumn<String>(
    'volc_asr_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deepSeekBaseUrlMeta = const VerificationMeta(
    'deepSeekBaseUrl',
  );
  @override
  late final GeneratedColumn<String> deepSeekBaseUrl = GeneratedColumn<String>(
    'deep_seek_base_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deepSeekModelMeta = const VerificationMeta(
    'deepSeekModel',
  );
  @override
  late final GeneratedColumn<String> deepSeekModel = GeneratedColumn<String>(
    'deep_seek_model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _temperatureMeta = const VerificationMeta(
    'temperature',
  );
  @override
  late final GeneratedColumn<double> temperature = GeneratedColumn<double>(
    'temperature',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeoutSecondsMeta = const VerificationMeta(
    'timeoutSeconds',
  );
  @override
  late final GeneratedColumn<int> timeoutSeconds = GeneratedColumn<int>(
    'timeout_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _providerTypeMeta = const VerificationMeta(
    'providerType',
  );
  @override
  late final GeneratedColumn<String> providerType = GeneratedColumn<String>(
    'provider_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('deepSeek'),
  );
  static const VerificationMeta _apiBaseUrlMeta = const VerificationMeta(
    'apiBaseUrl',
  );
  @override
  late final GeneratedColumn<String> apiBaseUrl = GeneratedColumn<String>(
    'api_base_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _apiModelNameMeta = const VerificationMeta(
    'apiModelName',
  );
  @override
  late final GeneratedColumn<String> apiModelName = GeneratedColumn<String>(
    'api_model_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    volcAsrEndpoint,
    volcAsrResourceId,
    volcAsrLanguage,
    deepSeekBaseUrl,
    deepSeekModel,
    temperature,
    timeoutSeconds,
    updatedAt,
    providerType,
    apiBaseUrl,
    apiModelName,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ai_config_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AiConfigRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('volc_asr_endpoint')) {
      context.handle(
        _volcAsrEndpointMeta,
        volcAsrEndpoint.isAcceptableOrUnknown(
          data['volc_asr_endpoint']!,
          _volcAsrEndpointMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_volcAsrEndpointMeta);
    }
    if (data.containsKey('volc_asr_resource_id')) {
      context.handle(
        _volcAsrResourceIdMeta,
        volcAsrResourceId.isAcceptableOrUnknown(
          data['volc_asr_resource_id']!,
          _volcAsrResourceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_volcAsrResourceIdMeta);
    }
    if (data.containsKey('volc_asr_language')) {
      context.handle(
        _volcAsrLanguageMeta,
        volcAsrLanguage.isAcceptableOrUnknown(
          data['volc_asr_language']!,
          _volcAsrLanguageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_volcAsrLanguageMeta);
    }
    if (data.containsKey('deep_seek_base_url')) {
      context.handle(
        _deepSeekBaseUrlMeta,
        deepSeekBaseUrl.isAcceptableOrUnknown(
          data['deep_seek_base_url']!,
          _deepSeekBaseUrlMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deepSeekBaseUrlMeta);
    }
    if (data.containsKey('deep_seek_model')) {
      context.handle(
        _deepSeekModelMeta,
        deepSeekModel.isAcceptableOrUnknown(
          data['deep_seek_model']!,
          _deepSeekModelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deepSeekModelMeta);
    }
    if (data.containsKey('temperature')) {
      context.handle(
        _temperatureMeta,
        temperature.isAcceptableOrUnknown(
          data['temperature']!,
          _temperatureMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_temperatureMeta);
    }
    if (data.containsKey('timeout_seconds')) {
      context.handle(
        _timeoutSecondsMeta,
        timeoutSeconds.isAcceptableOrUnknown(
          data['timeout_seconds']!,
          _timeoutSecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeoutSecondsMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('provider_type')) {
      context.handle(
        _providerTypeMeta,
        providerType.isAcceptableOrUnknown(
          data['provider_type']!,
          _providerTypeMeta,
        ),
      );
    }
    if (data.containsKey('api_base_url')) {
      context.handle(
        _apiBaseUrlMeta,
        apiBaseUrl.isAcceptableOrUnknown(
          data['api_base_url']!,
          _apiBaseUrlMeta,
        ),
      );
    }
    if (data.containsKey('api_model_name')) {
      context.handle(
        _apiModelNameMeta,
        apiModelName.isAcceptableOrUnknown(
          data['api_model_name']!,
          _apiModelNameMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AiConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AiConfigRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      volcAsrEndpoint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volc_asr_endpoint'],
      )!,
      volcAsrResourceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volc_asr_resource_id'],
      )!,
      volcAsrLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volc_asr_language'],
      )!,
      deepSeekBaseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deep_seek_base_url'],
      )!,
      deepSeekModel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deep_seek_model'],
      )!,
      temperature: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}temperature'],
      )!,
      timeoutSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timeout_seconds'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      providerType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provider_type'],
      )!,
      apiBaseUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_base_url'],
      ),
      apiModelName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}api_model_name'],
      ),
    );
  }

  @override
  $AiConfigRowsTable createAlias(String alias) {
    return $AiConfigRowsTable(attachedDatabase, alias);
  }
}

class AiConfigRow extends DataClass implements Insertable<AiConfigRow> {
  final String id;
  final String volcAsrEndpoint;
  final String volcAsrResourceId;
  final String volcAsrLanguage;
  final String deepSeekBaseUrl;
  final String deepSeekModel;
  final double temperature;
  final int timeoutSeconds;
  final DateTime updatedAt;
  final String providerType;
  final String? apiBaseUrl;
  final String? apiModelName;
  const AiConfigRow({
    required this.id,
    required this.volcAsrEndpoint,
    required this.volcAsrResourceId,
    required this.volcAsrLanguage,
    required this.deepSeekBaseUrl,
    required this.deepSeekModel,
    required this.temperature,
    required this.timeoutSeconds,
    required this.updatedAt,
    required this.providerType,
    this.apiBaseUrl,
    this.apiModelName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['volc_asr_endpoint'] = Variable<String>(volcAsrEndpoint);
    map['volc_asr_resource_id'] = Variable<String>(volcAsrResourceId);
    map['volc_asr_language'] = Variable<String>(volcAsrLanguage);
    map['deep_seek_base_url'] = Variable<String>(deepSeekBaseUrl);
    map['deep_seek_model'] = Variable<String>(deepSeekModel);
    map['temperature'] = Variable<double>(temperature);
    map['timeout_seconds'] = Variable<int>(timeoutSeconds);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['provider_type'] = Variable<String>(providerType);
    if (!nullToAbsent || apiBaseUrl != null) {
      map['api_base_url'] = Variable<String>(apiBaseUrl);
    }
    if (!nullToAbsent || apiModelName != null) {
      map['api_model_name'] = Variable<String>(apiModelName);
    }
    return map;
  }

  AiConfigRowsCompanion toCompanion(bool nullToAbsent) {
    return AiConfigRowsCompanion(
      id: Value(id),
      volcAsrEndpoint: Value(volcAsrEndpoint),
      volcAsrResourceId: Value(volcAsrResourceId),
      volcAsrLanguage: Value(volcAsrLanguage),
      deepSeekBaseUrl: Value(deepSeekBaseUrl),
      deepSeekModel: Value(deepSeekModel),
      temperature: Value(temperature),
      timeoutSeconds: Value(timeoutSeconds),
      updatedAt: Value(updatedAt),
      providerType: Value(providerType),
      apiBaseUrl: apiBaseUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(apiBaseUrl),
      apiModelName: apiModelName == null && nullToAbsent
          ? const Value.absent()
          : Value(apiModelName),
    );
  }

  factory AiConfigRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AiConfigRow(
      id: serializer.fromJson<String>(json['id']),
      volcAsrEndpoint: serializer.fromJson<String>(json['volcAsrEndpoint']),
      volcAsrResourceId: serializer.fromJson<String>(json['volcAsrResourceId']),
      volcAsrLanguage: serializer.fromJson<String>(json['volcAsrLanguage']),
      deepSeekBaseUrl: serializer.fromJson<String>(json['deepSeekBaseUrl']),
      deepSeekModel: serializer.fromJson<String>(json['deepSeekModel']),
      temperature: serializer.fromJson<double>(json['temperature']),
      timeoutSeconds: serializer.fromJson<int>(json['timeoutSeconds']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      providerType: serializer.fromJson<String>(json['providerType']),
      apiBaseUrl: serializer.fromJson<String?>(json['apiBaseUrl']),
      apiModelName: serializer.fromJson<String?>(json['apiModelName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'volcAsrEndpoint': serializer.toJson<String>(volcAsrEndpoint),
      'volcAsrResourceId': serializer.toJson<String>(volcAsrResourceId),
      'volcAsrLanguage': serializer.toJson<String>(volcAsrLanguage),
      'deepSeekBaseUrl': serializer.toJson<String>(deepSeekBaseUrl),
      'deepSeekModel': serializer.toJson<String>(deepSeekModel),
      'temperature': serializer.toJson<double>(temperature),
      'timeoutSeconds': serializer.toJson<int>(timeoutSeconds),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'providerType': serializer.toJson<String>(providerType),
      'apiBaseUrl': serializer.toJson<String?>(apiBaseUrl),
      'apiModelName': serializer.toJson<String?>(apiModelName),
    };
  }

  AiConfigRow copyWith({
    String? id,
    String? volcAsrEndpoint,
    String? volcAsrResourceId,
    String? volcAsrLanguage,
    String? deepSeekBaseUrl,
    String? deepSeekModel,
    double? temperature,
    int? timeoutSeconds,
    DateTime? updatedAt,
    String? providerType,
    Value<String?> apiBaseUrl = const Value.absent(),
    Value<String?> apiModelName = const Value.absent(),
  }) => AiConfigRow(
    id: id ?? this.id,
    volcAsrEndpoint: volcAsrEndpoint ?? this.volcAsrEndpoint,
    volcAsrResourceId: volcAsrResourceId ?? this.volcAsrResourceId,
    volcAsrLanguage: volcAsrLanguage ?? this.volcAsrLanguage,
    deepSeekBaseUrl: deepSeekBaseUrl ?? this.deepSeekBaseUrl,
    deepSeekModel: deepSeekModel ?? this.deepSeekModel,
    temperature: temperature ?? this.temperature,
    timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
    updatedAt: updatedAt ?? this.updatedAt,
    providerType: providerType ?? this.providerType,
    apiBaseUrl: apiBaseUrl.present ? apiBaseUrl.value : this.apiBaseUrl,
    apiModelName: apiModelName.present ? apiModelName.value : this.apiModelName,
  );
  AiConfigRow copyWithCompanion(AiConfigRowsCompanion data) {
    return AiConfigRow(
      id: data.id.present ? data.id.value : this.id,
      volcAsrEndpoint: data.volcAsrEndpoint.present
          ? data.volcAsrEndpoint.value
          : this.volcAsrEndpoint,
      volcAsrResourceId: data.volcAsrResourceId.present
          ? data.volcAsrResourceId.value
          : this.volcAsrResourceId,
      volcAsrLanguage: data.volcAsrLanguage.present
          ? data.volcAsrLanguage.value
          : this.volcAsrLanguage,
      deepSeekBaseUrl: data.deepSeekBaseUrl.present
          ? data.deepSeekBaseUrl.value
          : this.deepSeekBaseUrl,
      deepSeekModel: data.deepSeekModel.present
          ? data.deepSeekModel.value
          : this.deepSeekModel,
      temperature: data.temperature.present
          ? data.temperature.value
          : this.temperature,
      timeoutSeconds: data.timeoutSeconds.present
          ? data.timeoutSeconds.value
          : this.timeoutSeconds,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      providerType: data.providerType.present
          ? data.providerType.value
          : this.providerType,
      apiBaseUrl: data.apiBaseUrl.present
          ? data.apiBaseUrl.value
          : this.apiBaseUrl,
      apiModelName: data.apiModelName.present
          ? data.apiModelName.value
          : this.apiModelName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AiConfigRow(')
          ..write('id: $id, ')
          ..write('volcAsrEndpoint: $volcAsrEndpoint, ')
          ..write('volcAsrResourceId: $volcAsrResourceId, ')
          ..write('volcAsrLanguage: $volcAsrLanguage, ')
          ..write('deepSeekBaseUrl: $deepSeekBaseUrl, ')
          ..write('deepSeekModel: $deepSeekModel, ')
          ..write('temperature: $temperature, ')
          ..write('timeoutSeconds: $timeoutSeconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('providerType: $providerType, ')
          ..write('apiBaseUrl: $apiBaseUrl, ')
          ..write('apiModelName: $apiModelName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    volcAsrEndpoint,
    volcAsrResourceId,
    volcAsrLanguage,
    deepSeekBaseUrl,
    deepSeekModel,
    temperature,
    timeoutSeconds,
    updatedAt,
    providerType,
    apiBaseUrl,
    apiModelName,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AiConfigRow &&
          other.id == this.id &&
          other.volcAsrEndpoint == this.volcAsrEndpoint &&
          other.volcAsrResourceId == this.volcAsrResourceId &&
          other.volcAsrLanguage == this.volcAsrLanguage &&
          other.deepSeekBaseUrl == this.deepSeekBaseUrl &&
          other.deepSeekModel == this.deepSeekModel &&
          other.temperature == this.temperature &&
          other.timeoutSeconds == this.timeoutSeconds &&
          other.updatedAt == this.updatedAt &&
          other.providerType == this.providerType &&
          other.apiBaseUrl == this.apiBaseUrl &&
          other.apiModelName == this.apiModelName);
}

class AiConfigRowsCompanion extends UpdateCompanion<AiConfigRow> {
  final Value<String> id;
  final Value<String> volcAsrEndpoint;
  final Value<String> volcAsrResourceId;
  final Value<String> volcAsrLanguage;
  final Value<String> deepSeekBaseUrl;
  final Value<String> deepSeekModel;
  final Value<double> temperature;
  final Value<int> timeoutSeconds;
  final Value<DateTime> updatedAt;
  final Value<String> providerType;
  final Value<String?> apiBaseUrl;
  final Value<String?> apiModelName;
  final Value<int> rowid;
  const AiConfigRowsCompanion({
    this.id = const Value.absent(),
    this.volcAsrEndpoint = const Value.absent(),
    this.volcAsrResourceId = const Value.absent(),
    this.volcAsrLanguage = const Value.absent(),
    this.deepSeekBaseUrl = const Value.absent(),
    this.deepSeekModel = const Value.absent(),
    this.temperature = const Value.absent(),
    this.timeoutSeconds = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.providerType = const Value.absent(),
    this.apiBaseUrl = const Value.absent(),
    this.apiModelName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AiConfigRowsCompanion.insert({
    required String id,
    required String volcAsrEndpoint,
    required String volcAsrResourceId,
    required String volcAsrLanguage,
    required String deepSeekBaseUrl,
    required String deepSeekModel,
    required double temperature,
    required int timeoutSeconds,
    required DateTime updatedAt,
    this.providerType = const Value.absent(),
    this.apiBaseUrl = const Value.absent(),
    this.apiModelName = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       volcAsrEndpoint = Value(volcAsrEndpoint),
       volcAsrResourceId = Value(volcAsrResourceId),
       volcAsrLanguage = Value(volcAsrLanguage),
       deepSeekBaseUrl = Value(deepSeekBaseUrl),
       deepSeekModel = Value(deepSeekModel),
       temperature = Value(temperature),
       timeoutSeconds = Value(timeoutSeconds),
       updatedAt = Value(updatedAt);
  static Insertable<AiConfigRow> custom({
    Expression<String>? id,
    Expression<String>? volcAsrEndpoint,
    Expression<String>? volcAsrResourceId,
    Expression<String>? volcAsrLanguage,
    Expression<String>? deepSeekBaseUrl,
    Expression<String>? deepSeekModel,
    Expression<double>? temperature,
    Expression<int>? timeoutSeconds,
    Expression<DateTime>? updatedAt,
    Expression<String>? providerType,
    Expression<String>? apiBaseUrl,
    Expression<String>? apiModelName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (volcAsrEndpoint != null) 'volc_asr_endpoint': volcAsrEndpoint,
      if (volcAsrResourceId != null) 'volc_asr_resource_id': volcAsrResourceId,
      if (volcAsrLanguage != null) 'volc_asr_language': volcAsrLanguage,
      if (deepSeekBaseUrl != null) 'deep_seek_base_url': deepSeekBaseUrl,
      if (deepSeekModel != null) 'deep_seek_model': deepSeekModel,
      if (temperature != null) 'temperature': temperature,
      if (timeoutSeconds != null) 'timeout_seconds': timeoutSeconds,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (providerType != null) 'provider_type': providerType,
      if (apiBaseUrl != null) 'api_base_url': apiBaseUrl,
      if (apiModelName != null) 'api_model_name': apiModelName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AiConfigRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? volcAsrEndpoint,
    Value<String>? volcAsrResourceId,
    Value<String>? volcAsrLanguage,
    Value<String>? deepSeekBaseUrl,
    Value<String>? deepSeekModel,
    Value<double>? temperature,
    Value<int>? timeoutSeconds,
    Value<DateTime>? updatedAt,
    Value<String>? providerType,
    Value<String?>? apiBaseUrl,
    Value<String?>? apiModelName,
    Value<int>? rowid,
  }) {
    return AiConfigRowsCompanion(
      id: id ?? this.id,
      volcAsrEndpoint: volcAsrEndpoint ?? this.volcAsrEndpoint,
      volcAsrResourceId: volcAsrResourceId ?? this.volcAsrResourceId,
      volcAsrLanguage: volcAsrLanguage ?? this.volcAsrLanguage,
      deepSeekBaseUrl: deepSeekBaseUrl ?? this.deepSeekBaseUrl,
      deepSeekModel: deepSeekModel ?? this.deepSeekModel,
      temperature: temperature ?? this.temperature,
      timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      updatedAt: updatedAt ?? this.updatedAt,
      providerType: providerType ?? this.providerType,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      apiModelName: apiModelName ?? this.apiModelName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (volcAsrEndpoint.present) {
      map['volc_asr_endpoint'] = Variable<String>(volcAsrEndpoint.value);
    }
    if (volcAsrResourceId.present) {
      map['volc_asr_resource_id'] = Variable<String>(volcAsrResourceId.value);
    }
    if (volcAsrLanguage.present) {
      map['volc_asr_language'] = Variable<String>(volcAsrLanguage.value);
    }
    if (deepSeekBaseUrl.present) {
      map['deep_seek_base_url'] = Variable<String>(deepSeekBaseUrl.value);
    }
    if (deepSeekModel.present) {
      map['deep_seek_model'] = Variable<String>(deepSeekModel.value);
    }
    if (temperature.present) {
      map['temperature'] = Variable<double>(temperature.value);
    }
    if (timeoutSeconds.present) {
      map['timeout_seconds'] = Variable<int>(timeoutSeconds.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (providerType.present) {
      map['provider_type'] = Variable<String>(providerType.value);
    }
    if (apiBaseUrl.present) {
      map['api_base_url'] = Variable<String>(apiBaseUrl.value);
    }
    if (apiModelName.present) {
      map['api_model_name'] = Variable<String>(apiModelName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AiConfigRowsCompanion(')
          ..write('id: $id, ')
          ..write('volcAsrEndpoint: $volcAsrEndpoint, ')
          ..write('volcAsrResourceId: $volcAsrResourceId, ')
          ..write('volcAsrLanguage: $volcAsrLanguage, ')
          ..write('deepSeekBaseUrl: $deepSeekBaseUrl, ')
          ..write('deepSeekModel: $deepSeekModel, ')
          ..write('temperature: $temperature, ')
          ..write('timeoutSeconds: $timeoutSeconds, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('providerType: $providerType, ')
          ..write('apiBaseUrl: $apiBaseUrl, ')
          ..write('apiModelName: $apiModelName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FolderRowsTable extends FolderRows
    with TableInfo<$FolderRowsTable, FolderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FolderRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    parentId,
    sortOrder,
    isSystem,
    isStarred,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'folder_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<FolderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    } else if (isInserting) {
      context.missing(_sortOrderMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    } else if (isInserting) {
      context.missing(_isSystemMeta);
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FolderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FolderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $FolderRowsTable createAlias(String alias) {
    return $FolderRowsTable(attachedDatabase, alias);
  }
}

class FolderRow extends DataClass implements Insertable<FolderRow> {
  final String id;
  final String name;
  final String? parentId;
  final int sortOrder;
  final bool isSystem;
  final bool isStarred;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FolderRow({
    required this.id,
    required this.name,
    this.parentId,
    required this.sortOrder,
    required this.isSystem,
    required this.isStarred,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_starred'] = Variable<bool>(isStarred);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FolderRowsCompanion toCompanion(bool nullToAbsent) {
    return FolderRowsCompanion(
      id: Value(id),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      sortOrder: Value(sortOrder),
      isSystem: Value(isSystem),
      isStarred: Value(isStarred),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FolderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FolderRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isStarred': serializer.toJson<bool>(isStarred),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FolderRow copyWith({
    String? id,
    String? name,
    Value<String?> parentId = const Value.absent(),
    int? sortOrder,
    bool? isSystem,
    bool? isStarred,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => FolderRow(
    id: id ?? this.id,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    sortOrder: sortOrder ?? this.sortOrder,
    isSystem: isSystem ?? this.isSystem,
    isStarred: isStarred ?? this.isStarred,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  FolderRow copyWithCompanion(FolderRowsCompanion data) {
    return FolderRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FolderRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('isStarred: $isStarred, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    parentId,
    sortOrder,
    isSystem,
    isStarred,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FolderRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.sortOrder == this.sortOrder &&
          other.isSystem == this.isSystem &&
          other.isStarred == this.isStarred &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FolderRowsCompanion extends UpdateCompanion<FolderRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<int> sortOrder;
  final Value<bool> isSystem;
  final Value<bool> isStarred;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FolderRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FolderRowsCompanion.insert({
    required String id,
    required String name,
    this.parentId = const Value.absent(),
    required int sortOrder,
    required bool isSystem,
    this.isStarred = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       sortOrder = Value(sortOrder),
       isSystem = Value(isSystem),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<FolderRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<int>? sortOrder,
    Expression<bool>? isSystem,
    Expression<bool>? isStarred,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (isSystem != null) 'is_system': isSystem,
      if (isStarred != null) 'is_starred': isStarred,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FolderRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? parentId,
    Value<int>? sortOrder,
    Value<bool>? isSystem,
    Value<bool>? isStarred,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return FolderRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      isStarred: isStarred ?? this.isStarred,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FolderRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('isSystem: $isSystem, ')
          ..write('isStarred: $isStarred, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteRowsTable extends NoteRows with TableInfo<$NoteRowsTable, NoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _plainTextMeta = const VerificationMeta(
    'plainText',
  );
  @override
  late final GeneratedColumn<String> plainText = GeneratedColumn<String>(
    'plain_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _richContentJsonMeta = const VerificationMeta(
    'richContentJson',
  );
  @override
  late final GeneratedColumn<String> richContentJson = GeneratedColumn<String>(
    'rich_content_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _folderIdMeta = const VerificationMeta(
    'folderId',
  );
  @override
  late final GeneratedColumn<String> folderId = GeneratedColumn<String>(
    'folder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    plainText,
    richContentJson,
    folderId,
    isStarred,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('plain_text')) {
      context.handle(
        _plainTextMeta,
        plainText.isAcceptableOrUnknown(data['plain_text']!, _plainTextMeta),
      );
    } else if (isInserting) {
      context.missing(_plainTextMeta);
    }
    if (data.containsKey('rich_content_json')) {
      context.handle(
        _richContentJsonMeta,
        richContentJson.isAcceptableOrUnknown(
          data['rich_content_json']!,
          _richContentJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_richContentJsonMeta);
    }
    if (data.containsKey('folder_id')) {
      context.handle(
        _folderIdMeta,
        folderId.isAcceptableOrUnknown(data['folder_id']!, _folderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_folderIdMeta);
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      plainText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}plain_text'],
      )!,
      richContentJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rich_content_json'],
      )!,
      folderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folder_id'],
      )!,
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $NoteRowsTable createAlias(String alias) {
    return $NoteRowsTable(attachedDatabase, alias);
  }
}

class NoteRow extends DataClass implements Insertable<NoteRow> {
  final String id;
  final String title;
  final String plainText;
  final String richContentJson;
  final String folderId;
  final bool isStarred;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const NoteRow({
    required this.id,
    required this.title,
    required this.plainText,
    required this.richContentJson,
    required this.folderId,
    required this.isStarred,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['plain_text'] = Variable<String>(plainText);
    map['rich_content_json'] = Variable<String>(richContentJson);
    map['folder_id'] = Variable<String>(folderId);
    map['is_starred'] = Variable<bool>(isStarred);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NoteRowsCompanion toCompanion(bool nullToAbsent) {
    return NoteRowsCompanion(
      id: Value(id),
      title: Value(title),
      plainText: Value(plainText),
      richContentJson: Value(richContentJson),
      folderId: Value(folderId),
      isStarred: Value(isStarred),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory NoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      plainText: serializer.fromJson<String>(json['plainText']),
      richContentJson: serializer.fromJson<String>(json['richContentJson']),
      folderId: serializer.fromJson<String>(json['folderId']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'plainText': serializer.toJson<String>(plainText),
      'richContentJson': serializer.toJson<String>(richContentJson),
      'folderId': serializer.toJson<String>(folderId),
      'isStarred': serializer.toJson<bool>(isStarred),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  NoteRow copyWith({
    String? id,
    String? title,
    String? plainText,
    String? richContentJson,
    String? folderId,
    bool? isStarred,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => NoteRow(
    id: id ?? this.id,
    title: title ?? this.title,
    plainText: plainText ?? this.plainText,
    richContentJson: richContentJson ?? this.richContentJson,
    folderId: folderId ?? this.folderId,
    isStarred: isStarred ?? this.isStarred,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  NoteRow copyWithCompanion(NoteRowsCompanion data) {
    return NoteRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      plainText: data.plainText.present ? data.plainText.value : this.plainText,
      richContentJson: data.richContentJson.present
          ? data.richContentJson.value
          : this.richContentJson,
      folderId: data.folderId.present ? data.folderId.value : this.folderId,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('plainText: $plainText, ')
          ..write('richContentJson: $richContentJson, ')
          ..write('folderId: $folderId, ')
          ..write('isStarred: $isStarred, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    plainText,
    richContentJson,
    folderId,
    isStarred,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.plainText == this.plainText &&
          other.richContentJson == this.richContentJson &&
          other.folderId == this.folderId &&
          other.isStarred == this.isStarred &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NoteRowsCompanion extends UpdateCompanion<NoteRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> plainText;
  final Value<String> richContentJson;
  final Value<String> folderId;
  final Value<bool> isStarred;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const NoteRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.plainText = const Value.absent(),
    this.richContentJson = const Value.absent(),
    this.folderId = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteRowsCompanion.insert({
    required String id,
    required String title,
    required String plainText,
    required String richContentJson,
    required String folderId,
    this.isStarred = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       plainText = Value(plainText),
       richContentJson = Value(richContentJson),
       folderId = Value(folderId),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<NoteRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? plainText,
    Expression<String>? richContentJson,
    Expression<String>? folderId,
    Expression<bool>? isStarred,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (plainText != null) 'plain_text': plainText,
      if (richContentJson != null) 'rich_content_json': richContentJson,
      if (folderId != null) 'folder_id': folderId,
      if (isStarred != null) 'is_starred': isStarred,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? plainText,
    Value<String>? richContentJson,
    Value<String>? folderId,
    Value<bool>? isStarred,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return NoteRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      plainText: plainText ?? this.plainText,
      richContentJson: richContentJson ?? this.richContentJson,
      folderId: folderId ?? this.folderId,
      isStarred: isStarred ?? this.isStarred,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (plainText.present) {
      map['plain_text'] = Variable<String>(plainText.value);
    }
    if (richContentJson.present) {
      map['rich_content_json'] = Variable<String>(richContentJson.value);
    }
    if (folderId.present) {
      map['folder_id'] = Variable<String>(folderId.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('plainText: $plainText, ')
          ..write('richContentJson: $richContentJson, ')
          ..write('folderId: $folderId, ')
          ..write('isStarred: $isStarred, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttachmentRowsTable extends AttachmentRows
    with TableInfo<$AttachmentRowsTable, AttachmentRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttachmentRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    noteId,
    type,
    fileName,
    localPath,
    mimeType,
    sizeBytes,
    width,
    height,
    durationMs,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attachment_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttachmentRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_sizeBytesMeta);
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttachmentRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttachmentRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}type'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      ),
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      ),
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AttachmentRowsTable createAlias(String alias) {
    return $AttachmentRowsTable(attachedDatabase, alias);
  }
}

class AttachmentRow extends DataClass implements Insertable<AttachmentRow> {
  final String id;
  final String noteId;
  final int type;
  final String fileName;
  final String localPath;
  final String mimeType;
  final int sizeBytes;
  final int? width;
  final int? height;
  final int? durationMs;
  final DateTime createdAt;
  const AttachmentRow({
    required this.id,
    required this.noteId,
    required this.type,
    required this.fileName,
    required this.localPath,
    required this.mimeType,
    required this.sizeBytes,
    this.width,
    this.height,
    this.durationMs,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['note_id'] = Variable<String>(noteId);
    map['type'] = Variable<int>(type);
    map['file_name'] = Variable<String>(fileName);
    map['local_path'] = Variable<String>(localPath);
    map['mime_type'] = Variable<String>(mimeType);
    map['size_bytes'] = Variable<int>(sizeBytes);
    if (!nullToAbsent || width != null) {
      map['width'] = Variable<int>(width);
    }
    if (!nullToAbsent || height != null) {
      map['height'] = Variable<int>(height);
    }
    if (!nullToAbsent || durationMs != null) {
      map['duration_ms'] = Variable<int>(durationMs);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AttachmentRowsCompanion toCompanion(bool nullToAbsent) {
    return AttachmentRowsCompanion(
      id: Value(id),
      noteId: Value(noteId),
      type: Value(type),
      fileName: Value(fileName),
      localPath: Value(localPath),
      mimeType: Value(mimeType),
      sizeBytes: Value(sizeBytes),
      width: width == null && nullToAbsent
          ? const Value.absent()
          : Value(width),
      height: height == null && nullToAbsent
          ? const Value.absent()
          : Value(height),
      durationMs: durationMs == null && nullToAbsent
          ? const Value.absent()
          : Value(durationMs),
      createdAt: Value(createdAt),
    );
  }

  factory AttachmentRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttachmentRow(
      id: serializer.fromJson<String>(json['id']),
      noteId: serializer.fromJson<String>(json['noteId']),
      type: serializer.fromJson<int>(json['type']),
      fileName: serializer.fromJson<String>(json['fileName']),
      localPath: serializer.fromJson<String>(json['localPath']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      sizeBytes: serializer.fromJson<int>(json['sizeBytes']),
      width: serializer.fromJson<int?>(json['width']),
      height: serializer.fromJson<int?>(json['height']),
      durationMs: serializer.fromJson<int?>(json['durationMs']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'noteId': serializer.toJson<String>(noteId),
      'type': serializer.toJson<int>(type),
      'fileName': serializer.toJson<String>(fileName),
      'localPath': serializer.toJson<String>(localPath),
      'mimeType': serializer.toJson<String>(mimeType),
      'sizeBytes': serializer.toJson<int>(sizeBytes),
      'width': serializer.toJson<int?>(width),
      'height': serializer.toJson<int?>(height),
      'durationMs': serializer.toJson<int?>(durationMs),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AttachmentRow copyWith({
    String? id,
    String? noteId,
    int? type,
    String? fileName,
    String? localPath,
    String? mimeType,
    int? sizeBytes,
    Value<int?> width = const Value.absent(),
    Value<int?> height = const Value.absent(),
    Value<int?> durationMs = const Value.absent(),
    DateTime? createdAt,
  }) => AttachmentRow(
    id: id ?? this.id,
    noteId: noteId ?? this.noteId,
    type: type ?? this.type,
    fileName: fileName ?? this.fileName,
    localPath: localPath ?? this.localPath,
    mimeType: mimeType ?? this.mimeType,
    sizeBytes: sizeBytes ?? this.sizeBytes,
    width: width.present ? width.value : this.width,
    height: height.present ? height.value : this.height,
    durationMs: durationMs.present ? durationMs.value : this.durationMs,
    createdAt: createdAt ?? this.createdAt,
  );
  AttachmentRow copyWithCompanion(AttachmentRowsCompanion data) {
    return AttachmentRow(
      id: data.id.present ? data.id.value : this.id,
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      type: data.type.present ? data.type.value : this.type,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRow(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('type: $type, ')
          ..write('fileName: $fileName, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    noteId,
    type,
    fileName,
    localPath,
    mimeType,
    sizeBytes,
    width,
    height,
    durationMs,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttachmentRow &&
          other.id == this.id &&
          other.noteId == this.noteId &&
          other.type == this.type &&
          other.fileName == this.fileName &&
          other.localPath == this.localPath &&
          other.mimeType == this.mimeType &&
          other.sizeBytes == this.sizeBytes &&
          other.width == this.width &&
          other.height == this.height &&
          other.durationMs == this.durationMs &&
          other.createdAt == this.createdAt);
}

class AttachmentRowsCompanion extends UpdateCompanion<AttachmentRow> {
  final Value<String> id;
  final Value<String> noteId;
  final Value<int> type;
  final Value<String> fileName;
  final Value<String> localPath;
  final Value<String> mimeType;
  final Value<int> sizeBytes;
  final Value<int?> width;
  final Value<int?> height;
  final Value<int?> durationMs;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AttachmentRowsCompanion({
    this.id = const Value.absent(),
    this.noteId = const Value.absent(),
    this.type = const Value.absent(),
    this.fileName = const Value.absent(),
    this.localPath = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttachmentRowsCompanion.insert({
    required String id,
    required String noteId,
    required int type,
    required String fileName,
    required String localPath,
    required String mimeType,
    required int sizeBytes,
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.durationMs = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       noteId = Value(noteId),
       type = Value(type),
       fileName = Value(fileName),
       localPath = Value(localPath),
       mimeType = Value(mimeType),
       sizeBytes = Value(sizeBytes),
       createdAt = Value(createdAt);
  static Insertable<AttachmentRow> custom({
    Expression<String>? id,
    Expression<String>? noteId,
    Expression<int>? type,
    Expression<String>? fileName,
    Expression<String>? localPath,
    Expression<String>? mimeType,
    Expression<int>? sizeBytes,
    Expression<int>? width,
    Expression<int>? height,
    Expression<int>? durationMs,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (noteId != null) 'note_id': noteId,
      if (type != null) 'type': type,
      if (fileName != null) 'file_name': fileName,
      if (localPath != null) 'local_path': localPath,
      if (mimeType != null) 'mime_type': mimeType,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationMs != null) 'duration_ms': durationMs,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttachmentRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? noteId,
    Value<int>? type,
    Value<String>? fileName,
    Value<String>? localPath,
    Value<String>? mimeType,
    Value<int>? sizeBytes,
    Value<int?>? width,
    Value<int?>? height,
    Value<int?>? durationMs,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return AttachmentRowsCompanion(
      id: id ?? this.id,
      noteId: noteId ?? this.noteId,
      type: type ?? this.type,
      fileName: fileName ?? this.fileName,
      localPath: localPath ?? this.localPath,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      durationMs: durationMs ?? this.durationMs,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttachmentRowsCompanion(')
          ..write('id: $id, ')
          ..write('noteId: $noteId, ')
          ..write('type: $type, ')
          ..write('fileName: $fileName, ')
          ..write('localPath: $localPath, ')
          ..write('mimeType: $mimeType, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('durationMs: $durationMs, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimelineTaskRowsTable extends TimelineTaskRows
    with TableInfo<$TimelineTaskRowsTable, TimelineTaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimelineTaskRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskDateMeta = const VerificationMeta(
    'taskDate',
  );
  @override
  late final GeneratedColumn<DateTime> taskDate = GeneratedColumn<DateTime>(
    'task_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startAtMeta = const VerificationMeta(
    'startAt',
  );
  @override
  late final GeneratedColumn<DateTime> startAt = GeneratedColumn<DateTime>(
    'start_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endAtMeta = const VerificationMeta('endAt');
  @override
  late final GeneratedColumn<DateTime> endAt = GeneratedColumn<DateTime>(
    'end_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _importanceMeta = const VerificationMeta(
    'importance',
  );
  @override
  late final GeneratedColumn<String> importance = GeneratedColumn<String>(
    'importance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorArgbMeta = const VerificationMeta(
    'colorArgb',
  );
  @override
  late final GeneratedColumn<int> colorArgb = GeneratedColumn<int>(
    'color_argb',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isStarredMeta = const VerificationMeta(
    'isStarred',
  );
  @override
  late final GeneratedColumn<bool> isStarred = GeneratedColumn<bool>(
    'is_starred',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_starred" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isDeletedMeta = const VerificationMeta(
    'isDeleted',
  );
  @override
  late final GeneratedColumn<bool> isDeleted = GeneratedColumn<bool>(
    'is_deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    description,
    taskDate,
    startAt,
    endAt,
    importance,
    colorArgb,
    isCompleted,
    isStarred,
    isDeleted,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timeline_task_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimelineTaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('task_date')) {
      context.handle(
        _taskDateMeta,
        taskDate.isAcceptableOrUnknown(data['task_date']!, _taskDateMeta),
      );
    } else if (isInserting) {
      context.missing(_taskDateMeta);
    }
    if (data.containsKey('start_at')) {
      context.handle(
        _startAtMeta,
        startAt.isAcceptableOrUnknown(data['start_at']!, _startAtMeta),
      );
    }
    if (data.containsKey('end_at')) {
      context.handle(
        _endAtMeta,
        endAt.isAcceptableOrUnknown(data['end_at']!, _endAtMeta),
      );
    }
    if (data.containsKey('importance')) {
      context.handle(
        _importanceMeta,
        importance.isAcceptableOrUnknown(data['importance']!, _importanceMeta),
      );
    } else if (isInserting) {
      context.missing(_importanceMeta);
    }
    if (data.containsKey('color_argb')) {
      context.handle(
        _colorArgbMeta,
        colorArgb.isAcceptableOrUnknown(data['color_argb']!, _colorArgbMeta),
      );
    } else if (isInserting) {
      context.missing(_colorArgbMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('is_starred')) {
      context.handle(
        _isStarredMeta,
        isStarred.isAcceptableOrUnknown(data['is_starred']!, _isStarredMeta),
      );
    }
    if (data.containsKey('is_deleted')) {
      context.handle(
        _isDeletedMeta,
        isDeleted.isAcceptableOrUnknown(data['is_deleted']!, _isDeletedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimelineTaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimelineTaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      taskDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}task_date'],
      )!,
      startAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_at'],
      ),
      endAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}end_at'],
      ),
      importance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}importance'],
      )!,
      colorArgb: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_argb'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      isStarred: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_starred'],
      )!,
      isDeleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_deleted'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TimelineTaskRowsTable createAlias(String alias) {
    return $TimelineTaskRowsTable(attachedDatabase, alias);
  }
}

class TimelineTaskRow extends DataClass implements Insertable<TimelineTaskRow> {
  final String id;
  final String title;
  final String description;
  final DateTime taskDate;
  final DateTime? startAt;
  final DateTime? endAt;
  final String importance;
  final int colorArgb;
  final bool isCompleted;
  final bool isStarred;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TimelineTaskRow({
    required this.id,
    required this.title,
    required this.description,
    required this.taskDate,
    this.startAt,
    this.endAt,
    required this.importance,
    required this.colorArgb,
    required this.isCompleted,
    required this.isStarred,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['task_date'] = Variable<DateTime>(taskDate);
    if (!nullToAbsent || startAt != null) {
      map['start_at'] = Variable<DateTime>(startAt);
    }
    if (!nullToAbsent || endAt != null) {
      map['end_at'] = Variable<DateTime>(endAt);
    }
    map['importance'] = Variable<String>(importance);
    map['color_argb'] = Variable<int>(colorArgb);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['is_starred'] = Variable<bool>(isStarred);
    map['is_deleted'] = Variable<bool>(isDeleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TimelineTaskRowsCompanion toCompanion(bool nullToAbsent) {
    return TimelineTaskRowsCompanion(
      id: Value(id),
      title: Value(title),
      description: Value(description),
      taskDate: Value(taskDate),
      startAt: startAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startAt),
      endAt: endAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endAt),
      importance: Value(importance),
      colorArgb: Value(colorArgb),
      isCompleted: Value(isCompleted),
      isStarred: Value(isStarred),
      isDeleted: Value(isDeleted),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TimelineTaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimelineTaskRow(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      taskDate: serializer.fromJson<DateTime>(json['taskDate']),
      startAt: serializer.fromJson<DateTime?>(json['startAt']),
      endAt: serializer.fromJson<DateTime?>(json['endAt']),
      importance: serializer.fromJson<String>(json['importance']),
      colorArgb: serializer.fromJson<int>(json['colorArgb']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      isStarred: serializer.fromJson<bool>(json['isStarred']),
      isDeleted: serializer.fromJson<bool>(json['isDeleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'taskDate': serializer.toJson<DateTime>(taskDate),
      'startAt': serializer.toJson<DateTime?>(startAt),
      'endAt': serializer.toJson<DateTime?>(endAt),
      'importance': serializer.toJson<String>(importance),
      'colorArgb': serializer.toJson<int>(colorArgb),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'isStarred': serializer.toJson<bool>(isStarred),
      'isDeleted': serializer.toJson<bool>(isDeleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TimelineTaskRow copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? taskDate,
    Value<DateTime?> startAt = const Value.absent(),
    Value<DateTime?> endAt = const Value.absent(),
    String? importance,
    int? colorArgb,
    bool? isCompleted,
    bool? isStarred,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TimelineTaskRow(
    id: id ?? this.id,
    title: title ?? this.title,
    description: description ?? this.description,
    taskDate: taskDate ?? this.taskDate,
    startAt: startAt.present ? startAt.value : this.startAt,
    endAt: endAt.present ? endAt.value : this.endAt,
    importance: importance ?? this.importance,
    colorArgb: colorArgb ?? this.colorArgb,
    isCompleted: isCompleted ?? this.isCompleted,
    isStarred: isStarred ?? this.isStarred,
    isDeleted: isDeleted ?? this.isDeleted,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TimelineTaskRow copyWithCompanion(TimelineTaskRowsCompanion data) {
    return TimelineTaskRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      taskDate: data.taskDate.present ? data.taskDate.value : this.taskDate,
      startAt: data.startAt.present ? data.startAt.value : this.startAt,
      endAt: data.endAt.present ? data.endAt.value : this.endAt,
      importance: data.importance.present
          ? data.importance.value
          : this.importance,
      colorArgb: data.colorArgb.present ? data.colorArgb.value : this.colorArgb,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      isStarred: data.isStarred.present ? data.isStarred.value : this.isStarred,
      isDeleted: data.isDeleted.present ? data.isDeleted.value : this.isDeleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimelineTaskRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('taskDate: $taskDate, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('importance: $importance, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isStarred: $isStarred, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    description,
    taskDate,
    startAt,
    endAt,
    importance,
    colorArgb,
    isCompleted,
    isStarred,
    isDeleted,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimelineTaskRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.description == this.description &&
          other.taskDate == this.taskDate &&
          other.startAt == this.startAt &&
          other.endAt == this.endAt &&
          other.importance == this.importance &&
          other.colorArgb == this.colorArgb &&
          other.isCompleted == this.isCompleted &&
          other.isStarred == this.isStarred &&
          other.isDeleted == this.isDeleted &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TimelineTaskRowsCompanion extends UpdateCompanion<TimelineTaskRow> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> description;
  final Value<DateTime> taskDate;
  final Value<DateTime?> startAt;
  final Value<DateTime?> endAt;
  final Value<String> importance;
  final Value<int> colorArgb;
  final Value<bool> isCompleted;
  final Value<bool> isStarred;
  final Value<bool> isDeleted;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TimelineTaskRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.taskDate = const Value.absent(),
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    this.importance = const Value.absent(),
    this.colorArgb = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isDeleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimelineTaskRowsCompanion.insert({
    required String id,
    required String title,
    required String description,
    required DateTime taskDate,
    this.startAt = const Value.absent(),
    this.endAt = const Value.absent(),
    required String importance,
    required int colorArgb,
    this.isCompleted = const Value.absent(),
    this.isStarred = const Value.absent(),
    this.isDeleted = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       title = Value(title),
       description = Value(description),
       taskDate = Value(taskDate),
       importance = Value(importance),
       colorArgb = Value(colorArgb),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TimelineTaskRow> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? taskDate,
    Expression<DateTime>? startAt,
    Expression<DateTime>? endAt,
    Expression<String>? importance,
    Expression<int>? colorArgb,
    Expression<bool>? isCompleted,
    Expression<bool>? isStarred,
    Expression<bool>? isDeleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (taskDate != null) 'task_date': taskDate,
      if (startAt != null) 'start_at': startAt,
      if (endAt != null) 'end_at': endAt,
      if (importance != null) 'importance': importance,
      if (colorArgb != null) 'color_argb': colorArgb,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (isStarred != null) 'is_starred': isStarred,
      if (isDeleted != null) 'is_deleted': isDeleted,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimelineTaskRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? description,
    Value<DateTime>? taskDate,
    Value<DateTime?>? startAt,
    Value<DateTime?>? endAt,
    Value<String>? importance,
    Value<int>? colorArgb,
    Value<bool>? isCompleted,
    Value<bool>? isStarred,
    Value<bool>? isDeleted,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TimelineTaskRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      taskDate: taskDate ?? this.taskDate,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      importance: importance ?? this.importance,
      colorArgb: colorArgb ?? this.colorArgb,
      isCompleted: isCompleted ?? this.isCompleted,
      isStarred: isStarred ?? this.isStarred,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (taskDate.present) {
      map['task_date'] = Variable<DateTime>(taskDate.value);
    }
    if (startAt.present) {
      map['start_at'] = Variable<DateTime>(startAt.value);
    }
    if (endAt.present) {
      map['end_at'] = Variable<DateTime>(endAt.value);
    }
    if (importance.present) {
      map['importance'] = Variable<String>(importance.value);
    }
    if (colorArgb.present) {
      map['color_argb'] = Variable<int>(colorArgb.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (isStarred.present) {
      map['is_starred'] = Variable<bool>(isStarred.value);
    }
    if (isDeleted.present) {
      map['is_deleted'] = Variable<bool>(isDeleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimelineTaskRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('taskDate: $taskDate, ')
          ..write('startAt: $startAt, ')
          ..write('endAt: $endAt, ')
          ..write('importance: $importance, ')
          ..write('colorArgb: $colorArgb, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('isStarred: $isStarred, ')
          ..write('isDeleted: $isDeleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagRowsTable extends TagRows with TableInfo<$TagRowsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, color, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tag_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TagRowsTable createAlias(String alias) {
    return $TagRowsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final String name;
  final int color;
  final DateTime createdAt;
  const TagRow({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['color'] = Variable<int>(color);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TagRowsCompanion toCompanion(bool nullToAbsent) {
    return TagRowsCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      createdAt: Value(createdAt),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: serializer.fromJson<int>(json['color']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(color),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  TagRow copyWith({
    String? id,
    String? name,
    int? color,
    DateTime? createdAt,
  }) => TagRow(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    createdAt: createdAt ?? this.createdAt,
  );
  TagRow copyWithCompanion(TagRowsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, color, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.createdAt == this.createdAt);
}

class TagRowsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> color;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const TagRowsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagRowsCompanion.insert({
    required String id,
    required String name,
    required int color,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       color = Value(color),
       createdAt = Value(createdAt);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? color,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return TagRowsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagRowsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NoteTagsTable extends NoteTags with TableInfo<$NoteTagsTable, NoteTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NoteTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _noteIdMeta = const VerificationMeta('noteId');
  @override
  late final GeneratedColumn<String> noteId = GeneratedColumn<String>(
    'note_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [noteId, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'note_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<NoteTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('note_id')) {
      context.handle(
        _noteIdMeta,
        noteId.isAcceptableOrUnknown(data['note_id']!, _noteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_noteIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {noteId, tagId};
  @override
  NoteTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NoteTag(
      noteId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $NoteTagsTable createAlias(String alias) {
    return $NoteTagsTable(attachedDatabase, alias);
  }
}

class NoteTag extends DataClass implements Insertable<NoteTag> {
  final String noteId;
  final String tagId;
  const NoteTag({required this.noteId, required this.tagId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['note_id'] = Variable<String>(noteId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  NoteTagsCompanion toCompanion(bool nullToAbsent) {
    return NoteTagsCompanion(noteId: Value(noteId), tagId: Value(tagId));
  }

  factory NoteTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NoteTag(
      noteId: serializer.fromJson<String>(json['noteId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'noteId': serializer.toJson<String>(noteId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  NoteTag copyWith({String? noteId, String? tagId}) =>
      NoteTag(noteId: noteId ?? this.noteId, tagId: tagId ?? this.tagId);
  NoteTag copyWithCompanion(NoteTagsCompanion data) {
    return NoteTag(
      noteId: data.noteId.present ? data.noteId.value : this.noteId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NoteTag(')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(noteId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NoteTag &&
          other.noteId == this.noteId &&
          other.tagId == this.tagId);
}

class NoteTagsCompanion extends UpdateCompanion<NoteTag> {
  final Value<String> noteId;
  final Value<String> tagId;
  final Value<int> rowid;
  const NoteTagsCompanion({
    this.noteId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NoteTagsCompanion.insert({
    required String noteId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : noteId = Value(noteId),
       tagId = Value(tagId);
  static Insertable<NoteTag> custom({
    Expression<String>? noteId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (noteId != null) 'note_id': noteId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NoteTagsCompanion copyWith({
    Value<String>? noteId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return NoteTagsCompanion(
      noteId: noteId ?? this.noteId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (noteId.present) {
      map['note_id'] = Variable<String>(noteId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NoteTagsCompanion(')
          ..write('noteId: $noteId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderRowsTable extends ReminderRows
    with TableInfo<$ReminderRowsTable, ReminderRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetTypeMeta = const VerificationMeta(
    'targetType',
  );
  @override
  late final GeneratedColumn<String> targetType = GeneratedColumn<String>(
    'target_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetIdMeta = const VerificationMeta(
    'targetId',
  );
  @override
  late final GeneratedColumn<String> targetId = GeneratedColumn<String>(
    'target_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _triggerTimeMeta = const VerificationMeta(
    'triggerTime',
  );
  @override
  late final GeneratedColumn<DateTime> triggerTime = GeneratedColumn<DateTime>(
    'trigger_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notificationIdMeta = const VerificationMeta(
    'notificationId',
  );
  @override
  late final GeneratedColumn<int> notificationId = GeneratedColumn<int>(
    'notification_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    targetType,
    targetId,
    triggerTime,
    notificationId,
    enabled,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('target_type')) {
      context.handle(
        _targetTypeMeta,
        targetType.isAcceptableOrUnknown(data['target_type']!, _targetTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_targetTypeMeta);
    }
    if (data.containsKey('target_id')) {
      context.handle(
        _targetIdMeta,
        targetId.isAcceptableOrUnknown(data['target_id']!, _targetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_targetIdMeta);
    }
    if (data.containsKey('trigger_time')) {
      context.handle(
        _triggerTimeMeta,
        triggerTime.isAcceptableOrUnknown(
          data['trigger_time']!,
          _triggerTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerTimeMeta);
    }
    if (data.containsKey('notification_id')) {
      context.handle(
        _notificationIdMeta,
        notificationId.isAcceptableOrUnknown(
          data['notification_id']!,
          _notificationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_notificationIdMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      targetType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_type'],
      )!,
      targetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_id'],
      )!,
      triggerTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}trigger_time'],
      )!,
      notificationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}notification_id'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ReminderRowsTable createAlias(String alias) {
    return $ReminderRowsTable(attachedDatabase, alias);
  }
}

class ReminderRow extends DataClass implements Insertable<ReminderRow> {
  final String id;
  final String targetType;
  final String targetId;
  final DateTime triggerTime;
  final int notificationId;
  final bool enabled;
  final DateTime createdAt;
  const ReminderRow({
    required this.id,
    required this.targetType,
    required this.targetId,
    required this.triggerTime,
    required this.notificationId,
    required this.enabled,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['target_type'] = Variable<String>(targetType);
    map['target_id'] = Variable<String>(targetId);
    map['trigger_time'] = Variable<DateTime>(triggerTime);
    map['notification_id'] = Variable<int>(notificationId);
    map['enabled'] = Variable<bool>(enabled);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ReminderRowsCompanion toCompanion(bool nullToAbsent) {
    return ReminderRowsCompanion(
      id: Value(id),
      targetType: Value(targetType),
      targetId: Value(targetId),
      triggerTime: Value(triggerTime),
      notificationId: Value(notificationId),
      enabled: Value(enabled),
      createdAt: Value(createdAt),
    );
  }

  factory ReminderRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderRow(
      id: serializer.fromJson<String>(json['id']),
      targetType: serializer.fromJson<String>(json['targetType']),
      targetId: serializer.fromJson<String>(json['targetId']),
      triggerTime: serializer.fromJson<DateTime>(json['triggerTime']),
      notificationId: serializer.fromJson<int>(json['notificationId']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'targetType': serializer.toJson<String>(targetType),
      'targetId': serializer.toJson<String>(targetId),
      'triggerTime': serializer.toJson<DateTime>(triggerTime),
      'notificationId': serializer.toJson<int>(notificationId),
      'enabled': serializer.toJson<bool>(enabled),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ReminderRow copyWith({
    String? id,
    String? targetType,
    String? targetId,
    DateTime? triggerTime,
    int? notificationId,
    bool? enabled,
    DateTime? createdAt,
  }) => ReminderRow(
    id: id ?? this.id,
    targetType: targetType ?? this.targetType,
    targetId: targetId ?? this.targetId,
    triggerTime: triggerTime ?? this.triggerTime,
    notificationId: notificationId ?? this.notificationId,
    enabled: enabled ?? this.enabled,
    createdAt: createdAt ?? this.createdAt,
  );
  ReminderRow copyWithCompanion(ReminderRowsCompanion data) {
    return ReminderRow(
      id: data.id.present ? data.id.value : this.id,
      targetType: data.targetType.present
          ? data.targetType.value
          : this.targetType,
      targetId: data.targetId.present ? data.targetId.value : this.targetId,
      triggerTime: data.triggerTime.present
          ? data.triggerTime.value
          : this.triggerTime,
      notificationId: data.notificationId.present
          ? data.notificationId.value
          : this.notificationId,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRow(')
          ..write('id: $id, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('triggerTime: $triggerTime, ')
          ..write('notificationId: $notificationId, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    targetType,
    targetId,
    triggerTime,
    notificationId,
    enabled,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderRow &&
          other.id == this.id &&
          other.targetType == this.targetType &&
          other.targetId == this.targetId &&
          other.triggerTime == this.triggerTime &&
          other.notificationId == this.notificationId &&
          other.enabled == this.enabled &&
          other.createdAt == this.createdAt);
}

class ReminderRowsCompanion extends UpdateCompanion<ReminderRow> {
  final Value<String> id;
  final Value<String> targetType;
  final Value<String> targetId;
  final Value<DateTime> triggerTime;
  final Value<int> notificationId;
  final Value<bool> enabled;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ReminderRowsCompanion({
    this.id = const Value.absent(),
    this.targetType = const Value.absent(),
    this.targetId = const Value.absent(),
    this.triggerTime = const Value.absent(),
    this.notificationId = const Value.absent(),
    this.enabled = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderRowsCompanion.insert({
    required String id,
    required String targetType,
    required String targetId,
    required DateTime triggerTime,
    required int notificationId,
    this.enabled = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       targetType = Value(targetType),
       targetId = Value(targetId),
       triggerTime = Value(triggerTime),
       notificationId = Value(notificationId),
       createdAt = Value(createdAt);
  static Insertable<ReminderRow> custom({
    Expression<String>? id,
    Expression<String>? targetType,
    Expression<String>? targetId,
    Expression<DateTime>? triggerTime,
    Expression<int>? notificationId,
    Expression<bool>? enabled,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (targetType != null) 'target_type': targetType,
      if (targetId != null) 'target_id': targetId,
      if (triggerTime != null) 'trigger_time': triggerTime,
      if (notificationId != null) 'notification_id': notificationId,
      if (enabled != null) 'enabled': enabled,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderRowsCompanion copyWith({
    Value<String>? id,
    Value<String>? targetType,
    Value<String>? targetId,
    Value<DateTime>? triggerTime,
    Value<int>? notificationId,
    Value<bool>? enabled,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ReminderRowsCompanion(
      id: id ?? this.id,
      targetType: targetType ?? this.targetType,
      targetId: targetId ?? this.targetId,
      triggerTime: triggerTime ?? this.triggerTime,
      notificationId: notificationId ?? this.notificationId,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (targetType.present) {
      map['target_type'] = Variable<String>(targetType.value);
    }
    if (targetId.present) {
      map['target_id'] = Variable<String>(targetId.value);
    }
    if (triggerTime.present) {
      map['trigger_time'] = Variable<DateTime>(triggerTime.value);
    }
    if (notificationId.present) {
      map['notification_id'] = Variable<int>(notificationId.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderRowsCompanion(')
          ..write('id: $id, ')
          ..write('targetType: $targetType, ')
          ..write('targetId: $targetId, ')
          ..write('triggerTime: $triggerTime, ')
          ..write('notificationId: $notificationId, ')
          ..write('enabled: $enabled, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AppSettingsRowsTable appSettingsRows = $AppSettingsRowsTable(
    this,
  );
  late final $AiConfigRowsTable aiConfigRows = $AiConfigRowsTable(this);
  late final $FolderRowsTable folderRows = $FolderRowsTable(this);
  late final $NoteRowsTable noteRows = $NoteRowsTable(this);
  late final $AttachmentRowsTable attachmentRows = $AttachmentRowsTable(this);
  late final $TimelineTaskRowsTable timelineTaskRows = $TimelineTaskRowsTable(
    this,
  );
  late final $TagRowsTable tagRows = $TagRowsTable(this);
  late final $NoteTagsTable noteTags = $NoteTagsTable(this);
  late final $ReminderRowsTable reminderRows = $ReminderRowsTable(this);
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final AiConfigDao aiConfigDao = AiConfigDao(this as AppDatabase);
  late final FoldersDao foldersDao = FoldersDao(this as AppDatabase);
  late final NotesDao notesDao = NotesDao(this as AppDatabase);
  late final AttachmentsDao attachmentsDao = AttachmentsDao(
    this as AppDatabase,
  );
  late final TimelineTasksDao timelineTasksDao = TimelineTasksDao(
    this as AppDatabase,
  );
  late final TagsDao tagsDao = TagsDao(this as AppDatabase);
  late final RemindersDao remindersDao = RemindersDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    appSettingsRows,
    aiConfigRows,
    folderRows,
    noteRows,
    attachmentRows,
    timelineTaskRows,
    tagRows,
    noteTags,
    reminderRows,
  ];
}

typedef $$AppSettingsRowsTableCreateCompanionBuilder =
    AppSettingsRowsCompanion Function({
      required String id,
      required String themeMode,
      required String themeColor,
      required bool enableAppLock,
      required bool autoTranscribeVoice,
      required String defaultFolderId,
      required bool exportIncludeMetadata,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$AppSettingsRowsTableUpdateCompanionBuilder =
    AppSettingsRowsCompanion Function({
      Value<String> id,
      Value<String> themeMode,
      Value<String> themeColor,
      Value<bool> enableAppLock,
      Value<bool> autoTranscribeVoice,
      Value<String> defaultFolderId,
      Value<bool> exportIncludeMetadata,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$AppSettingsRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsRowsTable> {
  $$AppSettingsRowsTableFilterComposer({
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

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enableAppLock => $composableBuilder(
    column: $table.enableAppLock,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get autoTranscribeVoice => $composableBuilder(
    column: $table.autoTranscribeVoice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultFolderId => $composableBuilder(
    column: $table.defaultFolderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exportIncludeMetadata => $composableBuilder(
    column: $table.exportIncludeMetadata,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsRowsTable> {
  $$AppSettingsRowsTableOrderingComposer({
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

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enableAppLock => $composableBuilder(
    column: $table.enableAppLock,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get autoTranscribeVoice => $composableBuilder(
    column: $table.autoTranscribeVoice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultFolderId => $composableBuilder(
    column: $table.defaultFolderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exportIncludeMetadata => $composableBuilder(
    column: $table.exportIncludeMetadata,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsRowsTable> {
  $$AppSettingsRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get themeColor => $composableBuilder(
    column: $table.themeColor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enableAppLock => $composableBuilder(
    column: $table.enableAppLock,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get autoTranscribeVoice => $composableBuilder(
    column: $table.autoTranscribeVoice,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultFolderId => $composableBuilder(
    column: $table.defaultFolderId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get exportIncludeMetadata => $composableBuilder(
    column: $table.exportIncludeMetadata,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$AppSettingsRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsRowsTable,
          AppSettingsRow,
          $$AppSettingsRowsTableFilterComposer,
          $$AppSettingsRowsTableOrderingComposer,
          $$AppSettingsRowsTableAnnotationComposer,
          $$AppSettingsRowsTableCreateCompanionBuilder,
          $$AppSettingsRowsTableUpdateCompanionBuilder,
          (
            AppSettingsRow,
            BaseReferences<
              _$AppDatabase,
              $AppSettingsRowsTable,
              AppSettingsRow
            >,
          ),
          AppSettingsRow,
          PrefetchHooks Function()
        > {
  $$AppSettingsRowsTableTableManager(
    _$AppDatabase db,
    $AppSettingsRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> themeColor = const Value.absent(),
                Value<bool> enableAppLock = const Value.absent(),
                Value<bool> autoTranscribeVoice = const Value.absent(),
                Value<String> defaultFolderId = const Value.absent(),
                Value<bool> exportIncludeMetadata = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsRowsCompanion(
                id: id,
                themeMode: themeMode,
                themeColor: themeColor,
                enableAppLock: enableAppLock,
                autoTranscribeVoice: autoTranscribeVoice,
                defaultFolderId: defaultFolderId,
                exportIncludeMetadata: exportIncludeMetadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String themeMode,
                required String themeColor,
                required bool enableAppLock,
                required bool autoTranscribeVoice,
                required String defaultFolderId,
                required bool exportIncludeMetadata,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsRowsCompanion.insert(
                id: id,
                themeMode: themeMode,
                themeColor: themeColor,
                enableAppLock: enableAppLock,
                autoTranscribeVoice: autoTranscribeVoice,
                defaultFolderId: defaultFolderId,
                exportIncludeMetadata: exportIncludeMetadata,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsRowsTable,
      AppSettingsRow,
      $$AppSettingsRowsTableFilterComposer,
      $$AppSettingsRowsTableOrderingComposer,
      $$AppSettingsRowsTableAnnotationComposer,
      $$AppSettingsRowsTableCreateCompanionBuilder,
      $$AppSettingsRowsTableUpdateCompanionBuilder,
      (
        AppSettingsRow,
        BaseReferences<_$AppDatabase, $AppSettingsRowsTable, AppSettingsRow>,
      ),
      AppSettingsRow,
      PrefetchHooks Function()
    >;
typedef $$AiConfigRowsTableCreateCompanionBuilder =
    AiConfigRowsCompanion Function({
      required String id,
      required String volcAsrEndpoint,
      required String volcAsrResourceId,
      required String volcAsrLanguage,
      required String deepSeekBaseUrl,
      required String deepSeekModel,
      required double temperature,
      required int timeoutSeconds,
      required DateTime updatedAt,
      Value<String> providerType,
      Value<String?> apiBaseUrl,
      Value<String?> apiModelName,
      Value<int> rowid,
    });
typedef $$AiConfigRowsTableUpdateCompanionBuilder =
    AiConfigRowsCompanion Function({
      Value<String> id,
      Value<String> volcAsrEndpoint,
      Value<String> volcAsrResourceId,
      Value<String> volcAsrLanguage,
      Value<String> deepSeekBaseUrl,
      Value<String> deepSeekModel,
      Value<double> temperature,
      Value<int> timeoutSeconds,
      Value<DateTime> updatedAt,
      Value<String> providerType,
      Value<String?> apiBaseUrl,
      Value<String?> apiModelName,
      Value<int> rowid,
    });

class $$AiConfigRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AiConfigRowsTable> {
  $$AiConfigRowsTableFilterComposer({
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

  ColumnFilters<String> get volcAsrEndpoint => $composableBuilder(
    column: $table.volcAsrEndpoint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volcAsrResourceId => $composableBuilder(
    column: $table.volcAsrResourceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volcAsrLanguage => $composableBuilder(
    column: $table.volcAsrLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deepSeekBaseUrl => $composableBuilder(
    column: $table.deepSeekBaseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deepSeekModel => $composableBuilder(
    column: $table.deepSeekModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiBaseUrl => $composableBuilder(
    column: $table.apiBaseUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get apiModelName => $composableBuilder(
    column: $table.apiModelName,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AiConfigRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AiConfigRowsTable> {
  $$AiConfigRowsTableOrderingComposer({
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

  ColumnOrderings<String> get volcAsrEndpoint => $composableBuilder(
    column: $table.volcAsrEndpoint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volcAsrResourceId => $composableBuilder(
    column: $table.volcAsrResourceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volcAsrLanguage => $composableBuilder(
    column: $table.volcAsrLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deepSeekBaseUrl => $composableBuilder(
    column: $table.deepSeekBaseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deepSeekModel => $composableBuilder(
    column: $table.deepSeekModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiBaseUrl => $composableBuilder(
    column: $table.apiBaseUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get apiModelName => $composableBuilder(
    column: $table.apiModelName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AiConfigRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AiConfigRowsTable> {
  $$AiConfigRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get volcAsrEndpoint => $composableBuilder(
    column: $table.volcAsrEndpoint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get volcAsrResourceId => $composableBuilder(
    column: $table.volcAsrResourceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get volcAsrLanguage => $composableBuilder(
    column: $table.volcAsrLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deepSeekBaseUrl => $composableBuilder(
    column: $table.deepSeekBaseUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deepSeekModel => $composableBuilder(
    column: $table.deepSeekModel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get temperature => $composableBuilder(
    column: $table.temperature,
    builder: (column) => column,
  );

  GeneratedColumn<int> get timeoutSeconds => $composableBuilder(
    column: $table.timeoutSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get providerType => $composableBuilder(
    column: $table.providerType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get apiBaseUrl => $composableBuilder(
    column: $table.apiBaseUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get apiModelName => $composableBuilder(
    column: $table.apiModelName,
    builder: (column) => column,
  );
}

class $$AiConfigRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AiConfigRowsTable,
          AiConfigRow,
          $$AiConfigRowsTableFilterComposer,
          $$AiConfigRowsTableOrderingComposer,
          $$AiConfigRowsTableAnnotationComposer,
          $$AiConfigRowsTableCreateCompanionBuilder,
          $$AiConfigRowsTableUpdateCompanionBuilder,
          (
            AiConfigRow,
            BaseReferences<_$AppDatabase, $AiConfigRowsTable, AiConfigRow>,
          ),
          AiConfigRow,
          PrefetchHooks Function()
        > {
  $$AiConfigRowsTableTableManager(_$AppDatabase db, $AiConfigRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AiConfigRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AiConfigRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AiConfigRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> volcAsrEndpoint = const Value.absent(),
                Value<String> volcAsrResourceId = const Value.absent(),
                Value<String> volcAsrLanguage = const Value.absent(),
                Value<String> deepSeekBaseUrl = const Value.absent(),
                Value<String> deepSeekModel = const Value.absent(),
                Value<double> temperature = const Value.absent(),
                Value<int> timeoutSeconds = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<String> providerType = const Value.absent(),
                Value<String?> apiBaseUrl = const Value.absent(),
                Value<String?> apiModelName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiConfigRowsCompanion(
                id: id,
                volcAsrEndpoint: volcAsrEndpoint,
                volcAsrResourceId: volcAsrResourceId,
                volcAsrLanguage: volcAsrLanguage,
                deepSeekBaseUrl: deepSeekBaseUrl,
                deepSeekModel: deepSeekModel,
                temperature: temperature,
                timeoutSeconds: timeoutSeconds,
                updatedAt: updatedAt,
                providerType: providerType,
                apiBaseUrl: apiBaseUrl,
                apiModelName: apiModelName,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String volcAsrEndpoint,
                required String volcAsrResourceId,
                required String volcAsrLanguage,
                required String deepSeekBaseUrl,
                required String deepSeekModel,
                required double temperature,
                required int timeoutSeconds,
                required DateTime updatedAt,
                Value<String> providerType = const Value.absent(),
                Value<String?> apiBaseUrl = const Value.absent(),
                Value<String?> apiModelName = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AiConfigRowsCompanion.insert(
                id: id,
                volcAsrEndpoint: volcAsrEndpoint,
                volcAsrResourceId: volcAsrResourceId,
                volcAsrLanguage: volcAsrLanguage,
                deepSeekBaseUrl: deepSeekBaseUrl,
                deepSeekModel: deepSeekModel,
                temperature: temperature,
                timeoutSeconds: timeoutSeconds,
                updatedAt: updatedAt,
                providerType: providerType,
                apiBaseUrl: apiBaseUrl,
                apiModelName: apiModelName,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AiConfigRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AiConfigRowsTable,
      AiConfigRow,
      $$AiConfigRowsTableFilterComposer,
      $$AiConfigRowsTableOrderingComposer,
      $$AiConfigRowsTableAnnotationComposer,
      $$AiConfigRowsTableCreateCompanionBuilder,
      $$AiConfigRowsTableUpdateCompanionBuilder,
      (
        AiConfigRow,
        BaseReferences<_$AppDatabase, $AiConfigRowsTable, AiConfigRow>,
      ),
      AiConfigRow,
      PrefetchHooks Function()
    >;
typedef $$FolderRowsTableCreateCompanionBuilder =
    FolderRowsCompanion Function({
      required String id,
      required String name,
      Value<String?> parentId,
      required int sortOrder,
      required bool isSystem,
      Value<bool> isStarred,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$FolderRowsTableUpdateCompanionBuilder =
    FolderRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> parentId,
      Value<int> sortOrder,
      Value<bool> isSystem,
      Value<bool> isStarred,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$FolderRowsTableFilterComposer
    extends Composer<_$AppDatabase, $FolderRowsTable> {
  $$FolderRowsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FolderRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $FolderRowsTable> {
  $$FolderRowsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FolderRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FolderRowsTable> {
  $$FolderRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FolderRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FolderRowsTable,
          FolderRow,
          $$FolderRowsTableFilterComposer,
          $$FolderRowsTableOrderingComposer,
          $$FolderRowsTableAnnotationComposer,
          $$FolderRowsTableCreateCompanionBuilder,
          $$FolderRowsTableUpdateCompanionBuilder,
          (
            FolderRow,
            BaseReferences<_$AppDatabase, $FolderRowsTable, FolderRow>,
          ),
          FolderRow,
          PrefetchHooks Function()
        > {
  $$FolderRowsTableTableManager(_$AppDatabase db, $FolderRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FolderRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FolderRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FolderRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FolderRowsCompanion(
                id: id,
                name: name,
                parentId: parentId,
                sortOrder: sortOrder,
                isSystem: isSystem,
                isStarred: isStarred,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> parentId = const Value.absent(),
                required int sortOrder,
                required bool isSystem,
                Value<bool> isStarred = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => FolderRowsCompanion.insert(
                id: id,
                name: name,
                parentId: parentId,
                sortOrder: sortOrder,
                isSystem: isSystem,
                isStarred: isStarred,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FolderRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FolderRowsTable,
      FolderRow,
      $$FolderRowsTableFilterComposer,
      $$FolderRowsTableOrderingComposer,
      $$FolderRowsTableAnnotationComposer,
      $$FolderRowsTableCreateCompanionBuilder,
      $$FolderRowsTableUpdateCompanionBuilder,
      (FolderRow, BaseReferences<_$AppDatabase, $FolderRowsTable, FolderRow>),
      FolderRow,
      PrefetchHooks Function()
    >;
typedef $$NoteRowsTableCreateCompanionBuilder =
    NoteRowsCompanion Function({
      required String id,
      required String title,
      required String plainText,
      required String richContentJson,
      required String folderId,
      Value<bool> isStarred,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$NoteRowsTableUpdateCompanionBuilder =
    NoteRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> plainText,
      Value<String> richContentJson,
      Value<String> folderId,
      Value<bool> isStarred,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$NoteRowsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteRowsTable> {
  $$NoteRowsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get richContentJson => $composableBuilder(
    column: $table.richContentJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteRowsTable> {
  $$NoteRowsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get plainText => $composableBuilder(
    column: $table.plainText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get richContentJson => $composableBuilder(
    column: $table.richContentJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get folderId => $composableBuilder(
    column: $table.folderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteRowsTable> {
  $$NoteRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get plainText =>
      $composableBuilder(column: $table.plainText, builder: (column) => column);

  GeneratedColumn<String> get richContentJson => $composableBuilder(
    column: $table.richContentJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get folderId =>
      $composableBuilder(column: $table.folderId, builder: (column) => column);

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NoteRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteRowsTable,
          NoteRow,
          $$NoteRowsTableFilterComposer,
          $$NoteRowsTableOrderingComposer,
          $$NoteRowsTableAnnotationComposer,
          $$NoteRowsTableCreateCompanionBuilder,
          $$NoteRowsTableUpdateCompanionBuilder,
          (NoteRow, BaseReferences<_$AppDatabase, $NoteRowsTable, NoteRow>),
          NoteRow,
          PrefetchHooks Function()
        > {
  $$NoteRowsTableTableManager(_$AppDatabase db, $NoteRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> plainText = const Value.absent(),
                Value<String> richContentJson = const Value.absent(),
                Value<String> folderId = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NoteRowsCompanion(
                id: id,
                title: title,
                plainText: plainText,
                richContentJson: richContentJson,
                folderId: folderId,
                isStarred: isStarred,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String plainText,
                required String richContentJson,
                required String folderId,
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => NoteRowsCompanion.insert(
                id: id,
                title: title,
                plainText: plainText,
                richContentJson: richContentJson,
                folderId: folderId,
                isStarred: isStarred,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteRowsTable,
      NoteRow,
      $$NoteRowsTableFilterComposer,
      $$NoteRowsTableOrderingComposer,
      $$NoteRowsTableAnnotationComposer,
      $$NoteRowsTableCreateCompanionBuilder,
      $$NoteRowsTableUpdateCompanionBuilder,
      (NoteRow, BaseReferences<_$AppDatabase, $NoteRowsTable, NoteRow>),
      NoteRow,
      PrefetchHooks Function()
    >;
typedef $$AttachmentRowsTableCreateCompanionBuilder =
    AttachmentRowsCompanion Function({
      required String id,
      required String noteId,
      required int type,
      required String fileName,
      required String localPath,
      required String mimeType,
      required int sizeBytes,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationMs,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$AttachmentRowsTableUpdateCompanionBuilder =
    AttachmentRowsCompanion Function({
      Value<String> id,
      Value<String> noteId,
      Value<int> type,
      Value<String> fileName,
      Value<String> localPath,
      Value<String> mimeType,
      Value<int> sizeBytes,
      Value<int?> width,
      Value<int?> height,
      Value<int?> durationMs,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$AttachmentRowsTableFilterComposer
    extends Composer<_$AppDatabase, $AttachmentRowsTable> {
  $$AttachmentRowsTableFilterComposer({
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

  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttachmentRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $AttachmentRowsTable> {
  $$AttachmentRowsTableOrderingComposer({
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

  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttachmentRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttachmentRowsTable> {
  $$AttachmentRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AttachmentRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttachmentRowsTable,
          AttachmentRow,
          $$AttachmentRowsTableFilterComposer,
          $$AttachmentRowsTableOrderingComposer,
          $$AttachmentRowsTableAnnotationComposer,
          $$AttachmentRowsTableCreateCompanionBuilder,
          $$AttachmentRowsTableUpdateCompanionBuilder,
          (
            AttachmentRow,
            BaseReferences<_$AppDatabase, $AttachmentRowsTable, AttachmentRow>,
          ),
          AttachmentRow,
          PrefetchHooks Function()
        > {
  $$AttachmentRowsTableTableManager(
    _$AppDatabase db,
    $AttachmentRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttachmentRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttachmentRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttachmentRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> noteId = const Value.absent(),
                Value<int> type = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> sizeBytes = const Value.absent(),
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttachmentRowsCompanion(
                id: id,
                noteId: noteId,
                type: type,
                fileName: fileName,
                localPath: localPath,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                width: width,
                height: height,
                durationMs: durationMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String noteId,
                required int type,
                required String fileName,
                required String localPath,
                required String mimeType,
                required int sizeBytes,
                Value<int?> width = const Value.absent(),
                Value<int?> height = const Value.absent(),
                Value<int?> durationMs = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AttachmentRowsCompanion.insert(
                id: id,
                noteId: noteId,
                type: type,
                fileName: fileName,
                localPath: localPath,
                mimeType: mimeType,
                sizeBytes: sizeBytes,
                width: width,
                height: height,
                durationMs: durationMs,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttachmentRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttachmentRowsTable,
      AttachmentRow,
      $$AttachmentRowsTableFilterComposer,
      $$AttachmentRowsTableOrderingComposer,
      $$AttachmentRowsTableAnnotationComposer,
      $$AttachmentRowsTableCreateCompanionBuilder,
      $$AttachmentRowsTableUpdateCompanionBuilder,
      (
        AttachmentRow,
        BaseReferences<_$AppDatabase, $AttachmentRowsTable, AttachmentRow>,
      ),
      AttachmentRow,
      PrefetchHooks Function()
    >;
typedef $$TimelineTaskRowsTableCreateCompanionBuilder =
    TimelineTaskRowsCompanion Function({
      required String id,
      required String title,
      required String description,
      required DateTime taskDate,
      Value<DateTime?> startAt,
      Value<DateTime?> endAt,
      required String importance,
      required int colorArgb,
      Value<bool> isCompleted,
      Value<bool> isStarred,
      Value<bool> isDeleted,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TimelineTaskRowsTableUpdateCompanionBuilder =
    TimelineTaskRowsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> description,
      Value<DateTime> taskDate,
      Value<DateTime?> startAt,
      Value<DateTime?> endAt,
      Value<String> importance,
      Value<int> colorArgb,
      Value<bool> isCompleted,
      Value<bool> isStarred,
      Value<bool> isDeleted,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$TimelineTaskRowsTableFilterComposer
    extends Composer<_$AppDatabase, $TimelineTaskRowsTable> {
  $$TimelineTaskRowsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get taskDate => $composableBuilder(
    column: $table.taskDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimelineTaskRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimelineTaskRowsTable> {
  $$TimelineTaskRowsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get taskDate => $composableBuilder(
    column: $table.taskDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startAt => $composableBuilder(
    column: $table.startAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endAt => $composableBuilder(
    column: $table.endAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorArgb => $composableBuilder(
    column: $table.colorArgb,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isStarred => $composableBuilder(
    column: $table.isStarred,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDeleted => $composableBuilder(
    column: $table.isDeleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimelineTaskRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimelineTaskRowsTable> {
  $$TimelineTaskRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get taskDate =>
      $composableBuilder(column: $table.taskDate, builder: (column) => column);

  GeneratedColumn<DateTime> get startAt =>
      $composableBuilder(column: $table.startAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endAt =>
      $composableBuilder(column: $table.endAt, builder: (column) => column);

  GeneratedColumn<String> get importance => $composableBuilder(
    column: $table.importance,
    builder: (column) => column,
  );

  GeneratedColumn<int> get colorArgb =>
      $composableBuilder(column: $table.colorArgb, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isStarred =>
      $composableBuilder(column: $table.isStarred, builder: (column) => column);

  GeneratedColumn<bool> get isDeleted =>
      $composableBuilder(column: $table.isDeleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$TimelineTaskRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimelineTaskRowsTable,
          TimelineTaskRow,
          $$TimelineTaskRowsTableFilterComposer,
          $$TimelineTaskRowsTableOrderingComposer,
          $$TimelineTaskRowsTableAnnotationComposer,
          $$TimelineTaskRowsTableCreateCompanionBuilder,
          $$TimelineTaskRowsTableUpdateCompanionBuilder,
          (
            TimelineTaskRow,
            BaseReferences<
              _$AppDatabase,
              $TimelineTaskRowsTable,
              TimelineTaskRow
            >,
          ),
          TimelineTaskRow,
          PrefetchHooks Function()
        > {
  $$TimelineTaskRowsTableTableManager(
    _$AppDatabase db,
    $TimelineTaskRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimelineTaskRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimelineTaskRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimelineTaskRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<DateTime> taskDate = const Value.absent(),
                Value<DateTime?> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                Value<String> importance = const Value.absent(),
                Value<int> colorArgb = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimelineTaskRowsCompanion(
                id: id,
                title: title,
                description: description,
                taskDate: taskDate,
                startAt: startAt,
                endAt: endAt,
                importance: importance,
                colorArgb: colorArgb,
                isCompleted: isCompleted,
                isStarred: isStarred,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String title,
                required String description,
                required DateTime taskDate,
                Value<DateTime?> startAt = const Value.absent(),
                Value<DateTime?> endAt = const Value.absent(),
                required String importance,
                required int colorArgb,
                Value<bool> isCompleted = const Value.absent(),
                Value<bool> isStarred = const Value.absent(),
                Value<bool> isDeleted = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TimelineTaskRowsCompanion.insert(
                id: id,
                title: title,
                description: description,
                taskDate: taskDate,
                startAt: startAt,
                endAt: endAt,
                importance: importance,
                colorArgb: colorArgb,
                isCompleted: isCompleted,
                isStarred: isStarred,
                isDeleted: isDeleted,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimelineTaskRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimelineTaskRowsTable,
      TimelineTaskRow,
      $$TimelineTaskRowsTableFilterComposer,
      $$TimelineTaskRowsTableOrderingComposer,
      $$TimelineTaskRowsTableAnnotationComposer,
      $$TimelineTaskRowsTableCreateCompanionBuilder,
      $$TimelineTaskRowsTableUpdateCompanionBuilder,
      (
        TimelineTaskRow,
        BaseReferences<_$AppDatabase, $TimelineTaskRowsTable, TimelineTaskRow>,
      ),
      TimelineTaskRow,
      PrefetchHooks Function()
    >;
typedef $$TagRowsTableCreateCompanionBuilder =
    TagRowsCompanion Function({
      required String id,
      required String name,
      required int color,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$TagRowsTableUpdateCompanionBuilder =
    TagRowsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> color,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$TagRowsTableFilterComposer
    extends Composer<_$AppDatabase, $TagRowsTable> {
  $$TagRowsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $TagRowsTable> {
  $$TagRowsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagRowsTable> {
  $$TagRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$TagRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagRowsTable,
          TagRow,
          $$TagRowsTableFilterComposer,
          $$TagRowsTableOrderingComposer,
          $$TagRowsTableAnnotationComposer,
          $$TagRowsTableCreateCompanionBuilder,
          $$TagRowsTableUpdateCompanionBuilder,
          (TagRow, BaseReferences<_$AppDatabase, $TagRowsTable, TagRow>),
          TagRow,
          PrefetchHooks Function()
        > {
  $$TagRowsTableTableManager(_$AppDatabase db, $TagRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagRowsCompanion(
                id: id,
                name: name,
                color: color,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int color,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => TagRowsCompanion.insert(
                id: id,
                name: name,
                color: color,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagRowsTable,
      TagRow,
      $$TagRowsTableFilterComposer,
      $$TagRowsTableOrderingComposer,
      $$TagRowsTableAnnotationComposer,
      $$TagRowsTableCreateCompanionBuilder,
      $$TagRowsTableUpdateCompanionBuilder,
      (TagRow, BaseReferences<_$AppDatabase, $TagRowsTable, TagRow>),
      TagRow,
      PrefetchHooks Function()
    >;
typedef $$NoteTagsTableCreateCompanionBuilder =
    NoteTagsCompanion Function({
      required String noteId,
      required String tagId,
      Value<int> rowid,
    });
typedef $$NoteTagsTableUpdateCompanionBuilder =
    NoteTagsCompanion Function({
      Value<String> noteId,
      Value<String> tagId,
      Value<int> rowid,
    });

class $$NoteTagsTableFilterComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NoteTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get noteId => $composableBuilder(
    column: $table.noteId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagId => $composableBuilder(
    column: $table.tagId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NoteTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NoteTagsTable> {
  $$NoteTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get noteId =>
      $composableBuilder(column: $table.noteId, builder: (column) => column);

  GeneratedColumn<String> get tagId =>
      $composableBuilder(column: $table.tagId, builder: (column) => column);
}

class $$NoteTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NoteTagsTable,
          NoteTag,
          $$NoteTagsTableFilterComposer,
          $$NoteTagsTableOrderingComposer,
          $$NoteTagsTableAnnotationComposer,
          $$NoteTagsTableCreateCompanionBuilder,
          $$NoteTagsTableUpdateCompanionBuilder,
          (NoteTag, BaseReferences<_$AppDatabase, $NoteTagsTable, NoteTag>),
          NoteTag,
          PrefetchHooks Function()
        > {
  $$NoteTagsTableTableManager(_$AppDatabase db, $NoteTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NoteTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NoteTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NoteTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> noteId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  NoteTagsCompanion(noteId: noteId, tagId: tagId, rowid: rowid),
          createCompanionCallback:
              ({
                required String noteId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => NoteTagsCompanion.insert(
                noteId: noteId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NoteTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NoteTagsTable,
      NoteTag,
      $$NoteTagsTableFilterComposer,
      $$NoteTagsTableOrderingComposer,
      $$NoteTagsTableAnnotationComposer,
      $$NoteTagsTableCreateCompanionBuilder,
      $$NoteTagsTableUpdateCompanionBuilder,
      (NoteTag, BaseReferences<_$AppDatabase, $NoteTagsTable, NoteTag>),
      NoteTag,
      PrefetchHooks Function()
    >;
typedef $$ReminderRowsTableCreateCompanionBuilder =
    ReminderRowsCompanion Function({
      required String id,
      required String targetType,
      required String targetId,
      required DateTime triggerTime,
      required int notificationId,
      Value<bool> enabled,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ReminderRowsTableUpdateCompanionBuilder =
    ReminderRowsCompanion Function({
      Value<String> id,
      Value<String> targetType,
      Value<String> targetId,
      Value<DateTime> triggerTime,
      Value<int> notificationId,
      Value<bool> enabled,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ReminderRowsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderRowsTable> {
  $$ReminderRowsTableFilterComposer({
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

  ColumnFilters<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get triggerTime => $composableBuilder(
    column: $table.triggerTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderRowsTable> {
  $$ReminderRowsTableOrderingComposer({
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

  ColumnOrderings<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetId => $composableBuilder(
    column: $table.targetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get triggerTime => $composableBuilder(
    column: $table.triggerTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderRowsTable> {
  $$ReminderRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get targetType => $composableBuilder(
    column: $table.targetType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get targetId =>
      $composableBuilder(column: $table.targetId, builder: (column) => column);

  GeneratedColumn<DateTime> get triggerTime => $composableBuilder(
    column: $table.triggerTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get notificationId => $composableBuilder(
    column: $table.notificationId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ReminderRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderRowsTable,
          ReminderRow,
          $$ReminderRowsTableFilterComposer,
          $$ReminderRowsTableOrderingComposer,
          $$ReminderRowsTableAnnotationComposer,
          $$ReminderRowsTableCreateCompanionBuilder,
          $$ReminderRowsTableUpdateCompanionBuilder,
          (
            ReminderRow,
            BaseReferences<_$AppDatabase, $ReminderRowsTable, ReminderRow>,
          ),
          ReminderRow,
          PrefetchHooks Function()
        > {
  $$ReminderRowsTableTableManager(_$AppDatabase db, $ReminderRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> targetType = const Value.absent(),
                Value<String> targetId = const Value.absent(),
                Value<DateTime> triggerTime = const Value.absent(),
                Value<int> notificationId = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderRowsCompanion(
                id: id,
                targetType: targetType,
                targetId: targetId,
                triggerTime: triggerTime,
                notificationId: notificationId,
                enabled: enabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String targetType,
                required String targetId,
                required DateTime triggerTime,
                required int notificationId,
                Value<bool> enabled = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ReminderRowsCompanion.insert(
                id: id,
                targetType: targetType,
                targetId: targetId,
                triggerTime: triggerTime,
                notificationId: notificationId,
                enabled: enabled,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderRowsTable,
      ReminderRow,
      $$ReminderRowsTableFilterComposer,
      $$ReminderRowsTableOrderingComposer,
      $$ReminderRowsTableAnnotationComposer,
      $$ReminderRowsTableCreateCompanionBuilder,
      $$ReminderRowsTableUpdateCompanionBuilder,
      (
        ReminderRow,
        BaseReferences<_$AppDatabase, $ReminderRowsTable, ReminderRow>,
      ),
      ReminderRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AppSettingsRowsTableTableManager get appSettingsRows =>
      $$AppSettingsRowsTableTableManager(_db, _db.appSettingsRows);
  $$AiConfigRowsTableTableManager get aiConfigRows =>
      $$AiConfigRowsTableTableManager(_db, _db.aiConfigRows);
  $$FolderRowsTableTableManager get folderRows =>
      $$FolderRowsTableTableManager(_db, _db.folderRows);
  $$NoteRowsTableTableManager get noteRows =>
      $$NoteRowsTableTableManager(_db, _db.noteRows);
  $$AttachmentRowsTableTableManager get attachmentRows =>
      $$AttachmentRowsTableTableManager(_db, _db.attachmentRows);
  $$TimelineTaskRowsTableTableManager get timelineTaskRows =>
      $$TimelineTaskRowsTableTableManager(_db, _db.timelineTaskRows);
  $$TagRowsTableTableManager get tagRows =>
      $$TagRowsTableTableManager(_db, _db.tagRows);
  $$NoteTagsTableTableManager get noteTags =>
      $$NoteTagsTableTableManager(_db, _db.noteTags);
  $$ReminderRowsTableTableManager get reminderRows =>
      $$ReminderRowsTableTableManager(_db, _db.reminderRows);
}
