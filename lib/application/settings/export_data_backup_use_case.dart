// ignore_for_file: prefer_initializing_formals

import 'dart:convert';
import 'dart:io';

import '../../domain/entities/ai_config.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/attachment.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/reminder.dart';
import '../../domain/entities/tag.dart';
import '../../domain/entities/timeline_task.dart';
import '../../domain/repositories/ai_config_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../infrastructure/database/app_database.dart';

class ExportDataBackupUseCase {
  const ExportDataBackupUseCase({
    required AppDatabase database,
    required SettingsRepository settingsRepository,
    required AiConfigRepository aiConfigRepository,
  }) : _database = database,
       _settingsRepository = settingsRepository,
       _aiConfigRepository = aiConfigRepository;

  final AppDatabase _database;
  final SettingsRepository _settingsRepository;
  final AiConfigRepository _aiConfigRepository;

  Future<String> exportJson() async {
    final settings = await _settingsRepository.load();
    final includeMetadata = settings.exportIncludeMetadata;
    final aiConfig = await _aiConfigRepository.load();
    final folders = await _database.foldersDao.listAll();
    final notes = await _database.notesDao.listAll();
    final attachments = <Attachment>[];
    for (final note in notes) {
      attachments.addAll(await _database.attachmentsDao.listByNote(note.id));
    }
    final tasks = await _database.timelineTasksDao.listAll(
      includeDeleted: true,
    );
    final tags = await _database.tagsDao.listAll();
    final noteTagRows = await _database.select(_database.noteTags).get();
    final reminders = await _database.remindersDao.listAll();

    final encodedAttachments = <Map<String, Object?>>[];
    for (final attachment in attachments) {
      final file = File(attachment.localPath);
      final exists = await file.exists();
      encodedAttachments.add({
        ..._attachmentToJson(attachment, includeMetadata),
        'base64Data': exists ? base64Encode(await file.readAsBytes()) : null,
        'missingFile': !exists,
      });
    }

    final data = {
      'version': 1,
      if (includeMetadata) 'exportedAt': DateTime.now().toIso8601String(),
      'appSettings': _settingsToJson(settings),
      'aiConfig': _aiConfigToJson(aiConfig, includeMetadata: includeMetadata),
      'folders': folders
          .map((folder) => _folderToJson(folder, includeMetadata))
          .toList(),
      'notes': notes.map((note) => _noteToJson(note, includeMetadata)).toList(),
      'attachments': encodedAttachments,
      'tags': tags.map((tag) => _tagToJson(tag, includeMetadata)).toList(),
      'noteTags': noteTagRows
          .map((row) => {'noteId': row.noteId, 'tagId': row.tagId})
          .toList(),
      'timelineTasks': tasks
          .map((task) => _taskToJson(task, includeMetadata))
          .toList(),
      'reminders': reminders
          .map((reminder) => _reminderToJson(reminder, includeMetadata))
          .toList(),
    };
    return const JsonEncoder.withIndent('  ').convert(data);
  }

  Map<String, Object?> _settingsToJson(AppSettings settings) => {
    'themeMode': settings.themeMode.name,
    'themeColor': settings.themeColor,
    'enableAppLock': settings.enableAppLock,
    'autoTranscribeVoice': settings.autoTranscribeVoice,
    'defaultFolderId': settings.defaultFolderId,
    'exportIncludeMetadata': settings.exportIncludeMetadata,
    'fontScale': settings.fontScale,
    'defaultReminderLeadMinutes': settings.defaultReminderLeadMinutes,
    'hasRequestedStartupPermissions': settings.hasRequestedStartupPermissions,
  };

  Map<String, Object?> _aiConfigToJson(
    AiConfig config, {
    required bool includeMetadata,
  }) => {
    'volcAsrEndpoint': config.volcAsrEndpoint,
    'volcAsrResourceId': config.volcAsrResourceId,
    'volcAsrLanguage': config.volcAsrLanguage,
    'deepSeekBaseUrl': config.deepSeekBaseUrl,
    'deepSeekModel': config.deepSeekModel,
    'temperature': config.temperature,
    'timeoutSeconds': config.timeoutSeconds,
    'providerType': config.providerType.name,
    'apiBaseUrl': config.apiBaseUrl,
    'apiModelName': config.apiModelName,
    if (includeMetadata) 'updatedAt': config.updatedAt.toIso8601String(),
  };

  Map<String, Object?> _folderToJson(Folder folder, bool includeMetadata) => {
    'id': folder.id,
    'name': folder.name,
    'parentId': folder.parentId,
    'sortOrder': folder.sortOrder,
    'isSystem': folder.isSystem,
    'isStarred': folder.isStarred,
    if (includeMetadata) 'createdAt': folder.createdAt.toIso8601String(),
    if (includeMetadata) 'updatedAt': folder.updatedAt.toIso8601String(),
  };

  Map<String, Object?> _noteToJson(Note note, bool includeMetadata) => {
    'id': note.id,
    'title': note.title,
    'plainText': note.plainText,
    'richContentJson': note.richContentJson,
    'folderId': note.folderId,
    'isStarred': note.isStarred,
    'isDeleted': note.isDeleted,
    if (includeMetadata) 'createdAt': note.createdAt.toIso8601String(),
    if (includeMetadata) 'updatedAt': note.updatedAt.toIso8601String(),
  };

  Map<String, Object?> _attachmentToJson(
    Attachment attachment,
    bool includeMetadata,
  ) => {
    'id': attachment.id,
    'noteId': attachment.noteId,
    'type': attachment.type.name,
    'fileName': attachment.fileName,
    'mimeType': attachment.mimeType,
    'sizeBytes': attachment.sizeBytes,
    'width': attachment.width,
    'height': attachment.height,
    'durationMs': attachment.durationMs,
    if (includeMetadata) 'createdAt': attachment.createdAt.toIso8601String(),
  };

  Map<String, Object?> _tagToJson(Tag tag, bool includeMetadata) => {
    'id': tag.id,
    'name': tag.name,
    'color': tag.color,
    if (includeMetadata) 'createdAt': tag.createdAt.toIso8601String(),
  };

  Map<String, Object?> _taskToJson(TimelineTask task, bool includeMetadata) => {
    'id': task.id,
    'title': task.title,
    'description': task.description,
    'taskDate': task.taskDate.toIso8601String(),
    'startAt': task.startAt?.toIso8601String(),
    'endAt': task.endAt?.toIso8601String(),
    'importance': task.importance.name,
    'colorArgb': task.colorArgb,
    'isCompleted': task.isCompleted,
    'isStarred': task.isStarred,
    'isDeleted': task.isDeleted,
    if (includeMetadata) 'createdAt': task.createdAt.toIso8601String(),
    if (includeMetadata) 'updatedAt': task.updatedAt.toIso8601String(),
  };

  Map<String, Object?> _reminderToJson(
    Reminder reminder,
    bool includeMetadata,
  ) => {
    'id': reminder.id,
    'targetType': reminder.targetType,
    'targetId': reminder.targetId,
    'triggerTime': reminder.triggerTime.toIso8601String(),
    'notificationId': reminder.notificationId,
    'enabled': reminder.enabled,
    if (includeMetadata) 'createdAt': reminder.createdAt.toIso8601String(),
  };
}
