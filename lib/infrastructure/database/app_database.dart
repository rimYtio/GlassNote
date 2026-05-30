import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/timeline_task.dart';

part 'app_database.g.dart';

class AppSettingsRows extends Table {
  TextColumn get id => text()();
  TextColumn get themeMode => text().named('theme_mode')();
  TextColumn get themeColor => text().named('theme_color')();
  BoolColumn get enableAppLock => boolean().named('enable_app_lock')();
  BoolColumn get autoTranscribeVoice =>
      boolean().named('auto_transcribe_voice')();
  TextColumn get defaultFolderId => text().named('default_folder_id')();
  BoolColumn get exportIncludeMetadata =>
      boolean().named('export_include_metadata')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AiConfigRows extends Table {
  TextColumn get id => text()();
  TextColumn get volcAsrEndpoint => text().named('volc_asr_endpoint')();
  TextColumn get volcAsrResourceId => text().named('volc_asr_resource_id')();
  TextColumn get volcAsrLanguage => text().named('volc_asr_language')();
  TextColumn get deepSeekBaseUrl => text().named('deep_seek_base_url')();
  TextColumn get deepSeekModel => text().named('deep_seek_model')();
  RealColumn get temperature => real()();
  IntColumn get timeoutSeconds => integer().named('timeout_seconds')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  TextColumn get providerType => text()
      .named('provider_type')
      .withDefault(const Constant('deepSeek'))();
  TextColumn get apiBaseUrl => text().named('api_base_url').nullable()();
  TextColumn get apiModelName => text().named('api_model_name').nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class FolderRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().named('parent_id').nullable()();
  IntColumn get sortOrder => integer().named('sort_order')();
  BoolColumn get isSystem => boolean().named('is_system')();
  BoolColumn get isStarred =>
      boolean().named('is_starred').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class NoteRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get plainText => text().named('plain_text')();
  TextColumn get richContentJson => text().named('rich_content_json')();
  TextColumn get folderId => text().named('folder_id')();
  BoolColumn get isStarred =>
      boolean().named('is_starred').withDefault(const Constant(false))();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class AttachmentRows extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text().named('note_id')();
  IntColumn get type => integer().named('type')();
  TextColumn get fileName => text().named('file_name')();
  TextColumn get localPath => text().named('local_path')();
  TextColumn get mimeType => text().named('mime_type')();
  IntColumn get sizeBytes => integer().named('size_bytes')();
  IntColumn get width => integer().named('width').nullable()();
  IntColumn get height => integer().named('height').nullable()();
  IntColumn get durationMs => integer().named('duration_ms').nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TimelineTaskRows extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text()();
  DateTimeColumn get taskDate => dateTime().named('task_date')();
  DateTimeColumn get startAt => dateTime().named('start_at').nullable()();
  DateTimeColumn get endAt => dateTime().named('end_at').nullable()();
  TextColumn get importance => text()();
  IntColumn get colorArgb => integer().named('color_argb')();
  BoolColumn get isCompleted =>
      boolean().named('is_completed').withDefault(const Constant(false))();
  BoolColumn get isStarred =>
      boolean().named('is_starred').withDefault(const Constant(false))();
  BoolColumn get isDeleted =>
      boolean().named('is_deleted').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class TagRows extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get color => integer()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class NoteTags extends Table {
  TextColumn get noteId => text().named('note_id')();
  TextColumn get tagId => text().named('tag_id')();

  @override
  Set<Column<Object>> get primaryKey => {noteId, tagId};
}

class ReminderRows extends Table {
  TextColumn get id => text()();
  TextColumn get targetType => text().named('target_type')();
  TextColumn get targetId => text().named('target_id')();
  DateTimeColumn get triggerTime => dateTime().named('trigger_time')();
  IntColumn get notificationId => integer().named('notification_id')();
  BoolColumn get enabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftAccessor(tables: [TagRows, NoteTags, NoteRows])
class TagsDao extends DatabaseAccessor<AppDatabase> with _$TagsDaoMixin {
  TagsDao(super.db);

  Future<Tag> createTag(TagRowsCompanion tag) async {
    await into(tagRows).insertOnConflictUpdate(tag);
    final created = await findById(tag.id.value);
    return created!;
  }

  Future<Tag?> findById(String id) async {
    final row = await (select(tagRows)
      ..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToDomain(row);
  }

  Future<List<Tag>> listAll() async {
    final rows = await _allTagsQuery().get();
    return rows.map(_rowToDomain).toList();
  }

  Stream<List<Tag>> watchAll() {
    return _allTagsQuery()
        .watch()
        .map((rows) => rows.map(_rowToDomain).toList());
  }

  Future<void> deleteTag(String id) async {
    await (delete(noteTags)..where((t) => t.tagId.equals(id))).go();
    await (delete(tagRows)..where((t) => t.id.equals(id))).go();
  }

  Future<void> renameTag(String id, String name) async {
    await (update(tagRows)..where((t) => t.id.equals(id)))
        .write(TagRowsCompanion(name: Value(name)));
  }

  Future<List<Tag>> listByNote(String noteId) async {
    final query = select(tagRows).join([
      innerJoin(noteTags, noteTags.tagId.equalsExp(tagRows.id)),
    ])..where(noteTags.noteId.equals(noteId));
    final rows = await query.get();
    return rows.map((row) => _rowToDomain(row.readTable(tagRows))).toList();
  }

  Stream<List<Tag>> watchByNote(String noteId) {
    final query = select(tagRows).join([
      innerJoin(noteTags, noteTags.tagId.equalsExp(tagRows.id)),
    ])..where(noteTags.noteId.equals(noteId));
    return query.watch().map(
      (rows) => rows.map((row) => _rowToDomain(row.readTable(tagRows))).toList(),
    );
  }

  Future<void> addTagToNote(String noteId, String tagId) async {
    await into(noteTags).insertOnConflictUpdate(
      NoteTagsCompanion(noteId: Value(noteId), tagId: Value(tagId)),
    );
  }

  Future<void> removeTagFromNote(String noteId, String tagId) async {
    await (delete(noteTags)
      ..where((t) => t.noteId.equals(noteId) & t.tagId.equals(tagId)))
        .go();
  }

  Future<List<Note>> listNotesByTag(String tagId) async {
    final query = select(noteRows).join([
      innerJoin(noteTags, noteTags.noteId.equalsExp(noteRows.id)),
    ])
      ..where(noteTags.tagId.equals(tagId) & noteRows.isDeleted.equals(false))
      ..orderBy([
        OrderingTerm.desc(noteRows.isStarred),
        OrderingTerm.desc(noteRows.createdAt),
      ]);
    final rows = await query.get();
    return rows.map((row) {
      final r = row.readTable(noteRows);
      return Note(
        id: r.id,
        title: r.title,
        plainText: r.plainText,
        richContentJson: r.richContentJson,
        folderId: r.folderId,
        isStarred: r.isStarred,
        isDeleted: r.isDeleted,
        createdAt: r.createdAt,
        updatedAt: r.updatedAt,
      );
    }).toList();
  }

  SimpleSelectStatement<$TagRowsTable, TagRow> _allTagsQuery() {
    return select(tagRows)
      ..orderBy([(table) => OrderingTerm.asc(table.name)]);
  }

  Tag _rowToDomain(TagRow row) {
    return Tag(
      id: row.id,
      name: row.name,
      color: row.color,
      createdAt: row.createdAt,
    );
  }
}

@DriftAccessor(tables: [AppSettingsRows])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<AppSettings> loadSettings() async {
    final row = await _settingsQuery().getSingleOrNull();
    if (row != null) {
      return _rowToDomain(row);
    }

    final settings = AppSettings.defaults();
    await saveSettings(settings);
    return settings;
  }

  Future<AppSettings> saveSettings(AppSettings settings) async {
    await into(appSettingsRows).insertOnConflictUpdate(
      AppSettingsRowsCompanion(
        id: Value(settings.id),
        themeMode: Value(settings.themeMode.name),
        themeColor: Value(settings.themeColor),
        enableAppLock: Value(settings.enableAppLock),
        autoTranscribeVoice: Value(settings.autoTranscribeVoice),
        defaultFolderId: Value(settings.defaultFolderId),
        exportIncludeMetadata: Value(settings.exportIncludeMetadata),
        createdAt: Value(settings.createdAt),
        updatedAt: Value(settings.updatedAt),
      ),
    );
    return settings;
  }

  SimpleSelectStatement<$AppSettingsRowsTable, AppSettingsRow>
  _settingsQuery() {
    return select(appSettingsRows)
      ..where((table) => table.id.equals(AppSettings.defaultId));
  }

  AppSettings _rowToDomain(AppSettingsRow row) {
    return AppSettings(
      id: row.id,
      themeMode: AppThemeMode.fromStorageValue(row.themeMode),
      themeColor: row.themeColor,
      enableAppLock: row.enableAppLock,
      autoTranscribeVoice: row.autoTranscribeVoice,
      defaultFolderId: row.defaultFolderId,
      exportIncludeMetadata: row.exportIncludeMetadata,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

@DriftAccessor(tables: [AiConfigRows])
class AiConfigDao extends DatabaseAccessor<AppDatabase>
    with _$AiConfigDaoMixin {
  AiConfigDao(super.db);

  Future<AiConfig> loadConfig() async {
    final row = await (select(
      aiConfigRows,
    )..where((table) => table.id.equals(AiConfig.defaultId))).getSingleOrNull();
    if (row != null) {
      return _rowToDomain(row);
    }

    final config = AiConfig.defaults();
    await saveConfig(config);
    return config;
  }

  Future<AiConfig> saveConfig(AiConfig config) async {
    await into(aiConfigRows).insertOnConflictUpdate(
      AiConfigRowsCompanion(
        id: Value(config.id),
        volcAsrEndpoint: Value(config.volcAsrEndpoint),
        volcAsrResourceId: Value(config.volcAsrResourceId),
        volcAsrLanguage: Value(config.volcAsrLanguage),
        deepSeekBaseUrl: Value(config.deepSeekBaseUrl),
        deepSeekModel: Value(config.deepSeekModel),
        temperature: Value(config.temperature),
        timeoutSeconds: Value(config.timeoutSeconds),
        updatedAt: Value(config.updatedAt),
        providerType: Value(config.providerType.name),
        apiBaseUrl: Value(config.apiBaseUrl),
        apiModelName: Value(config.apiModelName),
      ),
    );
    return config;
  }

  AiConfig _rowToDomain(AiConfigRow row) {
    return AiConfig(
      id: row.id,
      volcAsrEndpoint: row.volcAsrEndpoint,
      volcAsrResourceId: row.volcAsrResourceId,
      volcAsrLanguage: row.volcAsrLanguage,
      deepSeekBaseUrl: row.deepSeekBaseUrl,
      deepSeekModel: row.deepSeekModel,
      temperature: row.temperature,
      timeoutSeconds: row.timeoutSeconds,
      updatedAt: row.updatedAt,
      providerType: AiProviderType.fromStorageValue(row.providerType),
      apiBaseUrl: row.apiBaseUrl,
      apiModelName: row.apiModelName,
    );
  }
}

@DriftAccessor(tables: [FolderRows])
class FoldersDao extends DatabaseAccessor<AppDatabase> with _$FoldersDaoMixin {
  FoldersDao(super.db);

  Future<Folder> ensureUncategorized() async {
    final existing = await findById(Folder.uncategorizedId);
    if (existing != null) {
      return existing;
    }

    final folder = Folder.uncategorized();
    await createFolder(
      FolderRowsCompanion.insert(
        id: folder.id,
        name: folder.name,
        parentId: Value(folder.parentId),
        sortOrder: folder.sortOrder,
        isSystem: folder.isSystem,
        isStarred: Value(folder.isStarred),
        createdAt: folder.createdAt,
        updatedAt: folder.updatedAt,
      ),
    );
    return folder;
  }

  Future<Folder> createFolder(FolderRowsCompanion folder) async {
    await into(folderRows).insertOnConflictUpdate(folder);
    final created = await findById(folder.id.value);
    return created!;
  }

  Future<Folder> updateFolder(Folder folder) async {
    await (update(
      folderRows,
    )..where((table) => table.id.equals(folder.id))).write(
      FolderRowsCompanion(
        name: Value(folder.name),
        parentId: Value(folder.parentId),
        sortOrder: Value(folder.sortOrder),
        isSystem: Value(folder.isSystem),
        isStarred: Value(folder.isStarred),
        updatedAt: Value(folder.updatedAt),
      ),
    );
    return (await findById(folder.id))!;
  }

  Future<void> deleteFolder(String id) async {
    await (delete(folderRows)..where((table) => table.id.equals(id))).go();
  }

  Future<Folder?> findById(String id) async {
    final row = await (select(
      folderRows,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToDomain(row);
  }

  Future<List<Folder>> listAll() async {
    final rows = await _allFoldersQuery().get();
    return rows.map(_rowToDomain).toList();
  }

  Stream<List<Folder>> watchRootFolders() {
    return (_allFoldersQuery()..where((table) => table.parentId.isNull()))
        .watch()
        .map((rows) => rows.map(_rowToDomain).toList());
  }

  SimpleSelectStatement<$FolderRowsTable, FolderRow> _allFoldersQuery() {
    return select(folderRows)..orderBy([
      (table) => OrderingTerm.desc(table.isSystem),
      (table) => OrderingTerm.desc(table.isStarred),
      (table) => OrderingTerm.asc(table.sortOrder),
      (table) => OrderingTerm.asc(table.createdAt),
    ]);
  }

  Folder _rowToDomain(FolderRow row) {
    return Folder(
      id: row.id,
      name: row.name,
      parentId: row.parentId,
      sortOrder: row.sortOrder,
      isSystem: row.isSystem,
      isStarred: row.isStarred,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

@DriftAccessor(tables: [NoteRows])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Future<Note> createNote(NoteRowsCompanion note) async {
    await into(noteRows).insertOnConflictUpdate(note);
    final created = await findById(note.id.value);
    return created!;
  }

  Future<Note> updateNote(Note note) async {
    debugPrint('[NotesDao] updateNote writing id=${note.id} plainText="${note.plainText}" richLen=${note.richContentJson.length}');
    await (update(noteRows)..where((table) => table.id.equals(note.id))).write(
      NoteRowsCompanion(
        title: Value(note.title),
        plainText: Value(note.plainText),
        richContentJson: Value(note.richContentJson),
        folderId: Value(note.folderId),
        isStarred: Value(note.isStarred),
        isDeleted: Value(note.isDeleted),
        updatedAt: Value(note.updatedAt),
      ),
    );
    final result = (await findById(note.id))!;
    debugPrint('[NotesDao] updateNote result id=${result.id} plainText="${result.plainText}" richLen=${result.richContentJson.length}');
    return result;
  }

  Future<void> softDelete(String id) async {
    await (update(noteRows)..where((table) => table.id.equals(id))).write(
      NoteRowsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> setStarred(String id, bool isStarred) async {
    await (update(noteRows)..where((table) => table.id.equals(id))).write(
      NoteRowsCompanion(
        isStarred: Value(isStarred),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> moveNotesToFolder({
    required String fromFolderId,
    required String toFolderId,
  }) async {
    await (update(
      noteRows,
    )..where((table) => table.folderId.equals(fromFolderId))).write(
      NoteRowsCompanion(
        folderId: Value(toFolderId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<Note?> findById(String id) async {
    final row = await (select(
      noteRows,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToDomain(row);
  }

  Future<List<Note>> listByFolder(String folderId) async {
    final query = _activeNotesQuery()
      ..where((table) => table.folderId.equals(folderId));
    final rows = await query.get();
    return rows.map(_rowToDomain).toList();
  }

  Future<List<Note>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final pattern = '%$trimmed%';
    final rows =
        await (_activeNotesQuery()..where(
              (table) =>
                  table.title.like(pattern) | table.plainText.like(pattern),
            ))
            .get();
    return rows.map(_rowToDomain).toList();
  }

  Stream<List<Note>> watchByFolder(String folderId) {
    return (_activeNotesQuery()
          ..where((table) => table.folderId.equals(folderId)))
        .watch()
        .map((rows) => rows.map(_rowToDomain).toList());
  }

  Stream<List<Note>> watchRecent({int limit = 5}) {
    return (select(noteRows)
          ..where((table) => table.isDeleted.equals(false))
          ..orderBy([
            (table) => OrderingTerm.desc(table.updatedAt),
          ])
          ..limit(limit))
        .watch()
        .map((rows) => rows.map(_rowToDomain).toList());
  }

  Stream<List<Note>> watchAll() {
    return _activeNotesQuery()
        .watch()
        .map((rows) => rows.map(_rowToDomain).toList());
  }

  Future<List<Note>> listDeleted() async {
    final rows = await (_deletedNotesQuery()).get();
    return rows.map(_rowToDomain).toList();
  }

  Stream<List<Note>> watchDeletedNotes() {
    return _deletedNotesQuery()
        .watch()
        .map((rows) => rows.map(_rowToDomain).toList());
  }

  Future<void> restore(String id) async {
    await (update(noteRows)..where((table) => table.id.equals(id))).write(
      NoteRowsCompanion(
        isDeleted: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> permanentlyDelete(String id) async {
    await db.attachmentsDao.deleteAllByNote(id);
    await (delete(noteRows)..where((table) => table.id.equals(id))).go();
  }

  Future<void> emptyTrash() async {
    final noteIds = await (selectOnly(noteRows)
          ..addColumns([noteRows.id])
          ..where(noteRows.isDeleted.equals(true)))
        .map((row) => row.read(noteRows.id)!)
        .get();
    for (final id in noteIds) {
      await db.attachmentsDao.deleteAllByNote(id);
    }
    await (delete(noteRows)..where((table) => table.isDeleted.equals(true)))
        .go();
  }

  SimpleSelectStatement<$NoteRowsTable, NoteRow> _deletedNotesQuery() {
    return select(noteRows)
      ..where((table) => table.isDeleted.equals(true))
      ..orderBy([
        (table) => OrderingTerm.desc(table.updatedAt),
      ]);
  }

  SimpleSelectStatement<$NoteRowsTable, NoteRow> _activeNotesQuery() {
    return select(noteRows)
      ..where((table) => table.isDeleted.equals(false))
      ..orderBy([
        (table) => OrderingTerm.desc(table.isStarred),
        (table) => OrderingTerm.desc(table.createdAt),
      ]);
  }

  Note _rowToDomain(NoteRow row) {
    return Note(
      id: row.id,
      title: row.title,
      plainText: row.plainText,
      richContentJson: row.richContentJson,
      folderId: row.folderId,
      isStarred: row.isStarred,
      isDeleted: row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

@DriftAccessor(tables: [AttachmentRows])
class AttachmentsDao extends DatabaseAccessor<AppDatabase>
    with _$AttachmentsDaoMixin {
  AttachmentsDao(super.db);

  Future<Attachment> save(Attachment attachment) async {
    await into(attachmentRows).insertOnConflictUpdate(
      AttachmentRowsCompanion(
        id: Value(attachment.id),
        noteId: Value(attachment.noteId),
        type: Value(attachment.type.index),
        fileName: Value(attachment.fileName),
        localPath: Value(attachment.localPath),
        mimeType: Value(attachment.mimeType),
        sizeBytes: Value(attachment.sizeBytes),
        width: Value(attachment.width),
        height: Value(attachment.height),
        durationMs: Value(attachment.durationMs),
        createdAt: Value(attachment.createdAt),
      ),
    );
    final row =
        await (select(attachmentRows)..where((t) => t.id.equals(attachment.id)))
            .getSingle();
    return _rowToDomain(row);
  }

  Future<List<Attachment>> listByNote(String noteId) async {
    final rows =
        await (select(attachmentRows)..where((t) => t.noteId.equals(noteId)))
            .get();
    return rows.map(_rowToDomain).toList();
  }

  Future<void> deleteAttachment(String id) async {
    await (delete(attachmentRows)..where((t) => t.id.equals(id))).go();
  }

  Future<void> deleteAllByNote(String noteId) async {
    await (delete(attachmentRows)..where((t) => t.noteId.equals(noteId))).go();
  }

  Stream<List<Attachment>> watchByNote(String noteId) {
    return (select(attachmentRows)..where((t) => t.noteId.equals(noteId)))
        .watch()
        .map((rows) => rows.map(_rowToDomain).toList());
  }

  Future<List<Attachment>> listByType(String noteId, AttachmentType type) async {
    final rows = await (select(attachmentRows)
      ..where((t) =>
          t.noteId.equals(noteId) & t.type.equals(type.index))
      ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
    return rows.map(_rowToDomain).toList();
  }

  Attachment _rowToDomain(AttachmentRow row) {
    return Attachment(
      id: row.id,
      noteId: row.noteId,
      type: AttachmentType.values[row.type],
      fileName: row.fileName,
      localPath: row.localPath,
      mimeType: row.mimeType,
      sizeBytes: row.sizeBytes,
      width: row.width,
      height: row.height,
      durationMs: row.durationMs,
      createdAt: row.createdAt,
    );
  }
}

@DriftAccessor(tables: [TimelineTaskRows])
class TimelineTasksDao extends DatabaseAccessor<AppDatabase>
    with _$TimelineTasksDaoMixin {
  TimelineTasksDao(super.db);

  Future<TimelineTask> createTask(TimelineTaskRowsCompanion task) async {
    await into(timelineTaskRows).insertOnConflictUpdate(task);
    final created = await findById(task.id.value);
    return created!;
  }

  Future<TimelineTask> updateTask(TimelineTask task) async {
    await (update(
      timelineTaskRows,
    )..where((table) => table.id.equals(task.id))).write(
      TimelineTaskRowsCompanion(
        title: Value(task.title),
        description: Value(task.description),
        taskDate: Value(_dateOnly(task.taskDate)),
        startAt: Value(task.startAt),
        endAt: Value(task.endAt),
        importance: Value(task.importance.name),
        colorArgb: Value(task.colorArgb),
        isCompleted: Value(task.isCompleted),
        isStarred: Value(task.isStarred),
        isDeleted: Value(task.isDeleted),
        updatedAt: Value(task.updatedAt),
      ),
    );
    return (await findById(task.id))!;
  }

  Future<void> softDelete(String id) async {
    await (update(
      timelineTaskRows,
    )..where((table) => table.id.equals(id))).write(
      TimelineTaskRowsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<TimelineTask?> findById(String id) async {
    final row =
        await (_activeTasksQuery()..where((table) => table.id.equals(id)))
            .getSingleOrNull();
    return row == null ? null : _rowToDomain(row);
  }

  Future<List<TimelineTask>> listRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final rows = await _rangeQuery(
      startDate: startDate,
      endDate: endDate,
    ).get();
    return TimelineTaskSort.sortedForTimeline(rows.map(_rowToDomain));
  }

  Future<List<TimelineTask>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const [];
    }

    final pattern = '%$trimmed%';
    final searchDate = _tryParseSearchDate(trimmed);
    final rows =
        await (_activeTasksQuery()..where((table) {
              var filter =
                  table.title.like(pattern) | table.description.like(pattern);
              if (searchDate != null) {
                filter = filter | table.taskDate.equals(searchDate);
              }
              return filter;
            }))
            .get();
    return TimelineTaskSort.sortedForTimeline(rows.map(_rowToDomain));
  }

  Stream<List<TimelineTask>> watchRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _rangeQuery(startDate: startDate, endDate: endDate).watch().map(
      (rows) => TimelineTaskSort.sortedForTimeline(rows.map(_rowToDomain)),
    );
  }

  SimpleSelectStatement<$TimelineTaskRowsTable, TimelineTaskRow> _rangeQuery({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _activeTasksQuery()..where(
      (table) =>
          table.taskDate.isBiggerOrEqualValue(_dateOnly(startDate)) &
          table.taskDate.isSmallerOrEqualValue(_dateOnly(endDate)),
    );
  }

  SimpleSelectStatement<$TimelineTaskRowsTable, TimelineTaskRow>
  _activeTasksQuery() {
    return select(timelineTaskRows)
      ..where((table) => table.isDeleted.equals(false));
  }

  TimelineTask _rowToDomain(TimelineTaskRow row) {
    return TimelineTask(
      id: row.id,
      title: row.title,
      description: row.description,
      taskDate: row.taskDate,
      startAt: row.startAt,
      endAt: row.endAt,
      importance: TimelineImportance.fromStorageValue(row.importance),
      colorArgb: row.colorArgb,
      isCompleted: row.isCompleted,
      isStarred: row.isStarred,
      isDeleted: row.isDeleted,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }
}

@DriftAccessor(tables: [ReminderRows])
class RemindersDao extends DatabaseAccessor<AppDatabase>
    with _$RemindersDaoMixin {
  RemindersDao(super.db);

  Future<Reminder> create(ReminderRowsCompanion reminder) async {
    await into(reminderRows).insertOnConflictUpdate(reminder);
    final created = await findById(reminder.id.value);
    return created!;
  }

  Future<Reminder?> findById(String id) async {
    final row = await (select(reminderRows)
      ..where((table) => table.id.equals(id))).getSingleOrNull();
    return row == null ? null : _rowToDomain(row);
  }

  Future<List<Reminder>> listByTarget(String targetId) async {
    final rows = await (select(reminderRows)
      ..where((table) => table.targetId.equals(targetId))
      ..orderBy([(table) => OrderingTerm.asc(table.triggerTime)])).get();
    return rows.map(_rowToDomain).toList();
  }

  Future<List<Reminder>> listPending() async {
    final now = DateTime.now();
    final rows = await (select(reminderRows)
      ..where((table) =>
          table.triggerTime.isBiggerOrEqualValue(now) &
          table.enabled.equals(true))
      ..orderBy([(table) => OrderingTerm.asc(table.triggerTime)])).get();
    return rows.map(_rowToDomain).toList();
  }

  Future<void> cancelByNotificationId(int notificationId) async {
    await (delete(reminderRows)
      ..where((table) => table.notificationId.equals(notificationId))).go();
  }

  Future<void> cancelByTarget(String targetId) async {
    await (delete(reminderRows)
      ..where((table) => table.targetId.equals(targetId))).go();
  }

  Future<void> deleteById(String id) async {
    await (delete(reminderRows)..where((table) => table.id.equals(id))).go();
  }

  Reminder _rowToDomain(ReminderRow row) {
    return Reminder(
      id: row.id,
      targetType: row.targetType,
      targetId: row.targetId,
      triggerTime: row.triggerTime,
      notificationId: row.notificationId,
      enabled: row.enabled,
      createdAt: row.createdAt,
    );
  }
}

@DriftDatabase(
  tables: [
    AppSettingsRows,
    AiConfigRows,
    FolderRows,
    NoteRows,
    AttachmentRows,
    TimelineTaskRows,
    TagRows,
    NoteTags,
    ReminderRows,
  ],
  daos: [
    SettingsDao,
    AiConfigDao,
    FoldersDao,
    NotesDao,
    AttachmentsDao,
    TimelineTasksDao,
    TagsDao,
    RemindersDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(folderRows);
        await migrator.createTable(noteRows);
      }
      if (from < 3) {
        await migrator.createTable(timelineTaskRows);
      }
      if (from < 4) {
        await migrator.addColumn(folderRows, folderRows.isStarred);
      }
      if (from < 5) {
        await migrator.createTable(aiConfigRows);
      }
      if (from < 6) {
        await migrator.addColumn(aiConfigRows, aiConfigRows.providerType);
        await migrator.addColumn(aiConfigRows, aiConfigRows.apiBaseUrl);
        await migrator.addColumn(aiConfigRows, aiConfigRows.apiModelName);
      }
      if (from < 7) {
        await migrator.createTable(attachmentRows);
      }
      if (from < 8) {
        await migrator.createTable(tagRows);
        await migrator.createTable(noteTags);
      }
      if (from < 9) {
        await migrator.createTable(reminderRows);
      }
    },
  );
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}

DateTime? _tryParseSearchDate(String value) {
  final match = RegExp(
    r'^(\d{4})[./-](\d{1,2})[./-](\d{1,2})$',
  ).firstMatch(value.trim());
  if (match == null) {
    return null;
  }

  final year = int.tryParse(match.group(1)!);
  final month = int.tryParse(match.group(2)!);
  final day = int.tryParse(match.group(3)!);
  if (year == null || month == null || day == null) {
    return null;
  }

  final date = DateTime(year, month, day);
  if (date.year != year || date.month != month || date.day != day) {
    return null;
  }
  return date;
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File(p.join(directory.path, 'glass_note.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
