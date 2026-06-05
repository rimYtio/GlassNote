// ignore_for_file: prefer_initializing_formals

import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../domain/entities/ai_config.dart';
import '../../domain/entities/app_settings.dart';
import '../../infrastructure/database/app_database.dart';

class ImportDataBackupUseCase {
  const ImportDataBackupUseCase({
    required AppDatabase database,
    required Future<String> Function() attachmentDirectoryProvider,
  }) : _database = database,
       _attachmentDirectoryProvider = attachmentDirectoryProvider;

  final AppDatabase _database;
  final Future<String> Function() _attachmentDirectoryProvider;

  Future<void> importJson(String json) async {
    final decoded = jsonDecode(json);
    if (decoded is! Map<String, Object?>) {
      throw const FormatException('Invalid GlassNote backup JSON');
    }

    await _database.transaction(() async {
      await _importSettings(_map(decoded['appSettings']));
      await _importAiConfig(_nullableMap(decoded['aiConfig']));
      await _importFolders(_list(decoded['folders']));
      await _importNotes(_list(decoded['notes']));
      await _importTags(_list(decoded['tags']));
      await _importNoteTags(_list(decoded['noteTags']));
      await _importTimelineTasks(_list(decoded['timelineTasks']));
      await _importReminders(_list(decoded['reminders']));
      await _importAttachments(_list(decoded['attachments']));
    });
  }

  Future<void> _importSettings(Map<String, Object?> row) async {
    if (row.isEmpty) return;
    final now = DateTime.now();
    final settings = AppSettings(
      id: AppSettings.defaultId,
      themeMode: AppThemeMode.fromStorageValue(
        _string(row['themeMode'], 'system'),
      ),
      themeColor: _string(row['themeColor'], '#5B6CFF'),
      enableAppLock: _bool(row['enableAppLock']),
      autoTranscribeVoice: _bool(row['autoTranscribeVoice']),
      defaultFolderId: _string(row['defaultFolderId'], 'inbox'),
      exportIncludeMetadata: _bool(
        row['exportIncludeMetadata'],
        fallback: true,
      ),
      fontScale: _double(row['fontScale'], 1.0),
      defaultReminderLeadMinutes: _int(row['defaultReminderLeadMinutes'], 15),
      hasRequestedStartupPermissions: _bool(
        row['hasRequestedStartupPermissions'],
      ),
      createdAt: now,
      updatedAt: now,
    );
    await _database.settingsDao.saveSettings(settings);
  }

  Future<void> _importAiConfig(Map<String, Object?>? row) async {
    if (row == null || row.isEmpty) return;
    await _database.aiConfigDao.saveConfig(
      AiConfig(
        id: AiConfig.defaultId,
        volcAsrEndpoint: _string(
          row['volcAsrEndpoint'],
          'wss://openspeech.bytedance.com/api/v3/sauc/bigmodel_async',
        ),
        volcAsrResourceId: _string(
          row['volcAsrResourceId'],
          'volc.seedasr.sauc.duration',
        ),
        volcAsrLanguage: _string(row['volcAsrLanguage'], 'zh-CN'),
        deepSeekBaseUrl: _string(
          row['deepSeekBaseUrl'],
          'https://api.deepseek.com',
        ),
        deepSeekModel: _string(row['deepSeekModel'], 'deepseek-v4-flash'),
        temperature: _double(row['temperature'], 0.2),
        timeoutSeconds: _int(row['timeoutSeconds'], 45),
        updatedAt: _date(row['updatedAt'], DateTime.now()),
        providerType: AiProviderType.fromStorageValue(
          _string(row['providerType'], 'deepSeek'),
        ),
        apiBaseUrl: row['apiBaseUrl'] as String?,
        apiModelName: row['apiModelName'] as String?,
      ),
    );
  }

  Future<void> _importFolders(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await _database
          .into(_database.folderRows)
          .insertOnConflictUpdate(
            FolderRowsCompanion.insert(
              id: _string(row['id'], ''),
              name: _string(row['name'], '未命名文件夹'),
              parentId: Value(row['parentId'] as String?),
              sortOrder: _int(row['sortOrder'], 0),
              isSystem: _bool(row['isSystem']),
              isStarred: Value(_bool(row['isStarred'])),
              createdAt: _date(row['createdAt'], DateTime.now()),
              updatedAt: _date(row['updatedAt'], DateTime.now()),
            ),
          );
    }
  }

  Future<void> _importNotes(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await _database
          .into(_database.noteRows)
          .insertOnConflictUpdate(
            NoteRowsCompanion.insert(
              id: _string(row['id'], ''),
              title: _string(row['title'], '无标题笔记'),
              plainText: _string(row['plainText'], ''),
              richContentJson: _string(row['richContentJson'], '{}'),
              folderId: _string(row['folderId'], 'inbox'),
              isStarred: Value(_bool(row['isStarred'])),
              isDeleted: Value(_bool(row['isDeleted'])),
              createdAt: _date(row['createdAt'], DateTime.now()),
              updatedAt: _date(row['updatedAt'], DateTime.now()),
            ),
          );
    }
  }

  Future<void> _importTags(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await _database
          .into(_database.tagRows)
          .insertOnConflictUpdate(
            TagRowsCompanion.insert(
              id: _string(row['id'], ''),
              name: _string(row['name'], '标签'),
              color: _int(row['color'], 0xFF7C6FF7),
              createdAt: _date(row['createdAt'], DateTime.now()),
            ),
          );
    }
  }

  Future<void> _importNoteTags(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await _database
          .into(_database.noteTags)
          .insertOnConflictUpdate(
            NoteTagsCompanion.insert(
              noteId: _string(row['noteId'], ''),
              tagId: _string(row['tagId'], ''),
            ),
          );
    }
  }

  Future<void> _importTimelineTasks(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await _database
          .into(_database.timelineTaskRows)
          .insertOnConflictUpdate(
            TimelineTaskRowsCompanion.insert(
              id: _string(row['id'], ''),
              title: _string(row['title'], '任务'),
              description: _string(row['description'], ''),
              taskDate: _date(row['taskDate'], DateTime.now()),
              startAt: Value(_nullableDate(row['startAt'])),
              endAt: Value(_nullableDate(row['endAt'])),
              importance: _string(row['importance'], 'medium'),
              colorArgb: _int(row['colorArgb'], 0xFF5B8DEF),
              isCompleted: Value(_bool(row['isCompleted'])),
              isStarred: Value(_bool(row['isStarred'])),
              isDeleted: Value(_bool(row['isDeleted'])),
              createdAt: _date(row['createdAt'], DateTime.now()),
              updatedAt: _date(row['updatedAt'], DateTime.now()),
            ),
          );
    }
  }

  Future<void> _importReminders(List<Map<String, Object?>> rows) async {
    for (final row in rows) {
      await _database
          .into(_database.reminderRows)
          .insertOnConflictUpdate(
            ReminderRowsCompanion.insert(
              id: _string(row['id'], ''),
              targetType: _string(row['targetType'], 'note'),
              targetId: _string(row['targetId'], ''),
              triggerTime: _date(row['triggerTime'], DateTime.now()),
              notificationId: _int(row['notificationId'], 0),
              enabled: Value(_bool(row['enabled'], fallback: true)),
              createdAt: _date(row['createdAt'], DateTime.now()),
            ),
          );
    }
  }

  Future<void> _importAttachments(List<Map<String, Object?>> rows) async {
    final dirPath = await _attachmentDirectoryProvider();
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    for (final row in rows) {
      if (_bool(row['missingFile'])) continue;
      final base64Data = row['base64Data'];
      if (base64Data is! String || base64Data.isEmpty) continue;
      final fileName = _string(row['fileName'], 'attachment.bin');
      final localPath = p.join(dir.path, fileName);
      await File(localPath).writeAsBytes(base64Decode(base64Data));
      await _database
          .into(_database.attachmentRows)
          .insertOnConflictUpdate(
            AttachmentRowsCompanion.insert(
              id: _string(row['id'], ''),
              noteId: _string(row['noteId'], ''),
              type: _attachmentTypeIndex(_string(row['type'], 'file')),
              fileName: fileName,
              localPath: localPath,
              mimeType: _string(row['mimeType'], 'application/octet-stream'),
              sizeBytes: _int(row['sizeBytes'], 0),
              width: Value(row['width'] as int?),
              height: Value(row['height'] as int?),
              durationMs: Value(row['durationMs'] as int?),
              createdAt: _date(row['createdAt'], DateTime.now()),
            ),
          );
    }
  }

  int _attachmentTypeIndex(String type) {
    return switch (type) {
      'image' => 0,
      'audio' => 1,
      _ => 2,
    };
  }

  List<Map<String, Object?>> _list(Object? value) {
    if (value is! List) return const [];
    return value.map(_map).toList();
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map) {
      return value.map((key, value) => MapEntry(key.toString(), value));
    }
    return const {};
  }

  Map<String, Object?>? _nullableMap(Object? value) {
    if (value == null) return null;
    return _map(value);
  }

  String _string(Object? value, String fallback) {
    return value is String && value.isNotEmpty ? value : fallback;
  }

  bool _bool(Object? value, {bool fallback = false}) {
    return value is bool ? value : fallback;
  }

  int _int(Object? value, int fallback) {
    return value is num ? value.toInt() : fallback;
  }

  double _double(Object? value, double fallback) {
    return value is num ? value.toDouble() : fallback;
  }

  DateTime _date(Object? value, DateTime fallback) {
    return _nullableDate(value) ?? fallback;
  }

  DateTime? _nullableDate(Object? value) {
    if (value is! String || value.isEmpty) return null;
    return DateTime.tryParse(value);
  }
}
