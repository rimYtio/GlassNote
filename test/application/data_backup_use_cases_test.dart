import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/application/settings/export_data_backup_use_case.dart';
import 'package:glass_note/application/settings/import_data_backup_use_case.dart';
import 'package:glass_note/domain/entities/attachment.dart';
import 'package:glass_note/domain/entities/folder.dart';
import 'package:glass_note/domain/entities/note.dart';
import 'package:glass_note/domain/entities/timeline_task.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/repositories/ai_config_repository_impl.dart';
import 'package:glass_note/infrastructure/repositories/attachment_repository_impl.dart';
import 'package:glass_note/infrastructure/repositories/folder_repository_impl.dart';
import 'package:glass_note/infrastructure/repositories/note_repository_impl.dart';
import 'package:glass_note/infrastructure/repositories/settings_repository_impl.dart';
import 'package:glass_note/infrastructure/repositories/tag_repository_impl.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late AppDatabase database;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('glassnote-backup-test-');
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test(
    'exports JSON backup without secure secrets and includes attachment bytes',
    () async {
      final folders = FolderRepositoryImpl(database);
      final notes = NoteRepositoryImpl(database);
      final attachments = AttachmentRepositoryImpl(database);
      final tagRepo = TagRepositoryImpl(database);
      await folders.ensureUncategorized();
      final folder = await folders.create(
        const FolderDraft(name: '资料', parentId: null),
      );
      final note = await notes.create(
        NoteDraft(
          title: '备份笔记',
          plainText: '正文',
          richContentJson: '{}',
          folderId: folder.id,
        ),
      );
      final tag = await tagRepo.create('公开标签', 0xFF336699);
      await tagRepo.addTagToNote(note.id, tag.id);
      final file = File(p.join(tempDir.path, 'image.png'));
      await file.writeAsBytes([1, 2, 3, 4]);
      await attachments.save(
        Attachment(
          id: 'attachment-1',
          noteId: note.id,
          type: AttachmentType.image,
          fileName: 'image.png',
          localPath: file.path,
          mimeType: 'image/png',
          sizeBytes: 4,
          createdAt: DateTime(2026, 6, 5),
        ),
      );

      final backup = await ExportDataBackupUseCase(
        database: database,
        settingsRepository: SettingsRepositoryImpl(database),
        aiConfigRepository: AiConfigRepositoryImpl(database),
      ).exportJson();
      final decoded = jsonDecode(backup) as Map<String, Object?>;

      expect(decoded['version'], 1);
      expect(backup, isNot(contains('deepseek_api_key')));
      expect(backup, isNot(contains('volc_app_key')));
      expect(backup, isNot(contains('pin_hash')));
      final exportedAttachments = (decoded['attachments'] as List)
          .cast<Map<String, Object?>>();
      expect(
        exportedAttachments.single['base64Data'],
        base64Encode([1, 2, 3, 4]),
      );
      expect(exportedAttachments.single['missingFile'], isFalse);
    },
  );

  test('omits metadata timestamps when export metadata is disabled', () async {
    final settings = SettingsRepositoryImpl(database);
    final folders = FolderRepositoryImpl(database);
    final notes = NoteRepositoryImpl(database);

    await settings.save(
      (await settings.load()).copyWith(exportIncludeMetadata: false),
    );
    final folder = await folders.create(
      const FolderDraft(name: '项目', parentId: null),
    );
    await notes.create(
      NoteDraft(
        title: '无元数据笔记',
        plainText: '内容',
        richContentJson: '{}',
        folderId: folder.id,
      ),
    );

    final backup = await ExportDataBackupUseCase(
      database: database,
      settingsRepository: settings,
      aiConfigRepository: AiConfigRepositoryImpl(database),
    ).exportJson();
    final decoded = jsonDecode(backup) as Map<String, Object?>;
    final exportedFolder = (decoded['folders'] as List).first as Map;
    final exportedNote = (decoded['notes'] as List).first as Map;

    expect(decoded.containsKey('exportedAt'), isFalse);
    expect(exportedFolder.containsKey('createdAt'), isFalse);
    expect(exportedFolder.containsKey('updatedAt'), isFalse);
    expect(exportedNote.containsKey('createdAt'), isFalse);
    expect(exportedNote.containsKey('updatedAt'), isFalse);
  });

  test(
    'imports JSON backup and restores notes tasks tags and attachments',
    () async {
      final attachmentFileDir = Directory(p.join(tempDir.path, 'attachments'));
      final backup = jsonEncode({
        'version': 1,
        'exportedAt': '2026-06-05T10:00:00.000',
        'appSettings': {
          'themeMode': 'dark',
          'themeColor': '#5B6CFF',
          'enableAppLock': false,
          'autoTranscribeVoice': false,
          'defaultFolderId': Folder.uncategorizedId,
          'exportIncludeMetadata': true,
          'fontScale': 1.1,
          'defaultReminderLeadMinutes': 30,
          'hasRequestedStartupPermissions': true,
        },
        'aiConfig': null,
        'folders': [
          {
            'id': Folder.uncategorizedId,
            'name': '未分类',
            'parentId': null,
            'sortOrder': 0,
            'isSystem': true,
            'isStarred': false,
            'createdAt': '2026-06-05T10:00:00.000',
            'updatedAt': '2026-06-05T10:00:00.000',
          },
        ],
        'notes': [
          {
            'id': 'note-1',
            'title': '导入笔记',
            'plainText': '导入正文',
            'richContentJson': '{}',
            'folderId': Folder.uncategorizedId,
            'isStarred': true,
            'isDeleted': false,
            'createdAt': '2026-06-05T10:00:00.000',
            'updatedAt': '2026-06-05T10:00:00.000',
          },
        ],
        'attachments': [
          {
            'id': 'attachment-1',
            'noteId': 'note-1',
            'type': 'image',
            'fileName': 'restored.png',
            'mimeType': 'image/png',
            'sizeBytes': 3,
            'width': null,
            'height': null,
            'durationMs': null,
            'createdAt': '2026-06-05T10:00:00.000',
            'base64Data': base64Encode([9, 8, 7]),
            'missingFile': false,
          },
        ],
        'tags': [
          {
            'id': 'tag-1',
            'name': '导入标签',
            'color': 4281558681,
            'createdAt': '2026-06-05T10:00:00.000',
          },
        ],
        'noteTags': [
          {'noteId': 'note-1', 'tagId': 'tag-1'},
        ],
        'timelineTasks': [
          {
            'id': 'task-1',
            'title': '导入任务',
            'description': '',
            'taskDate': '2026-06-05T00:00:00.000',
            'startAt': null,
            'endAt': null,
            'importance': 'medium',
            'colorArgb': TimelineTaskDefaults.mediumColorArgb,
            'isCompleted': false,
            'isStarred': false,
            'isDeleted': false,
            'createdAt': '2026-06-05T10:00:00.000',
            'updatedAt': '2026-06-05T10:00:00.000',
          },
        ],
        'reminders': [],
      });

      await ImportDataBackupUseCase(
        database: database,
        attachmentDirectoryProvider: () async => attachmentFileDir.path,
      ).importJson(backup);

      expect((await database.notesDao.findById('note-1'))?.title, '导入笔记');
      expect(
        (await database.timelineTasksDao.findById('task-1'))?.title,
        '导入任务',
      );
      expect((await database.tagsDao.listByNote('note-1')).single.name, '导入标签');
      final restoredAttachment = (await database.attachmentsDao.listByNote(
        'note-1',
      )).single;
      expect(await File(restoredAttachment.localPath).readAsBytes(), [9, 8, 7]);
      expect((await database.settingsDao.loadSettings()).fontScale, 1.1);
      expect(
        (await database.settingsDao.loadSettings())
            .hasRequestedStartupPermissions,
        isTrue,
      );
    },
  );
}
