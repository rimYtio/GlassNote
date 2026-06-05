import 'dart:io';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/application/notes/delete_attachment_use_case.dart';
import 'package:glass_note/application/notes/save_note_audio_attachment_use_case.dart';
import 'package:glass_note/application/notes/save_note_image_attachment_use_case.dart';
import 'package:glass_note/domain/entities/attachment.dart';
import 'package:glass_note/domain/entities/folder.dart';
import 'package:glass_note/domain/entities/note.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/file_system/attachment_file_store.dart';
import 'package:glass_note/infrastructure/repositories/attachment_repository_impl.dart';
import 'package:glass_note/infrastructure/repositories/folder_repository_impl.dart';
import 'package:glass_note/infrastructure/repositories/note_repository_impl.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory tempDir;
  late AppDatabase database;
  late Note note;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp(
      'glassnote-attachment-test-',
    );
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await FolderRepositoryImpl(database).ensureUncategorized();
    note = await NoteRepositoryImpl(database).create(
      NoteDraft(
        title: '附件笔记',
        plainText: '',
        richContentJson: '{}',
        folderId: Folder.uncategorizedId,
      ),
    );
  });

  tearDown(() async {
    await database.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('saves image attachment bytes and stores metadata', () async {
    final useCase = SaveNoteImageAttachmentUseCase(
      attachmentRepository: AttachmentRepositoryImpl(database),
      fileStore: _TestAttachmentFileStore(tempDir),
    );

    final attachment = await useCase.call(
      noteId: note.id,
      bytes: [1, 2, 3],
      originalFileName: 'photo.png',
    );

    expect(attachment.type, AttachmentType.image);
    expect(attachment.mimeType, 'image/png');
    expect(await File(attachment.localPath).readAsBytes(), [1, 2, 3]);
    expect(
      (await database.attachmentsDao.listByNote(note.id)).single.id,
      attachment.id,
    );
  });

  test('saves audio attachment from a temporary recording', () async {
    final source = File(p.join(tempDir.path, 'recording.m4a'));
    await source.writeAsBytes([4, 5, 6, 7]);
    final useCase = SaveNoteAudioAttachmentUseCase(
      attachmentRepository: AttachmentRepositoryImpl(database),
      fileStore: _TestAttachmentFileStore(tempDir),
    );

    final attachment = await useCase.call(
      noteId: note.id,
      tempFilePath: source.path,
      durationMs: 1200,
    );

    expect(attachment.type, AttachmentType.audio);
    expect(attachment.mimeType, 'audio/mp4');
    expect(attachment.durationMs, 1200);
    expect(await File(attachment.localPath).readAsBytes(), [4, 5, 6, 7]);
  });

  test('deletes attachment record and file together', () async {
    final file = File(p.join(tempDir.path, 'delete-me.png'));
    await file.writeAsBytes([1]);
    final repo = AttachmentRepositoryImpl(database);
    final attachment = await repo.save(
      Attachment(
        id: 'delete-me',
        noteId: note.id,
        type: AttachmentType.image,
        fileName: 'delete-me.png',
        localPath: file.path,
        mimeType: 'image/png',
        sizeBytes: 1,
        createdAt: DateTime(2026, 6, 5),
      ),
    );

    await DeleteAttachmentUseCase(
      attachmentRepository: repo,
      fileStore: _TestAttachmentFileStore(tempDir),
    ).call(attachment);

    expect(await file.exists(), isFalse);
    expect(await database.attachmentsDao.listByNote(note.id), isEmpty);
  });
}

class _TestAttachmentFileStore extends AttachmentFileStore {
  _TestAttachmentFileStore(this.directory);

  final Directory directory;

  @override
  Future<String> saveImage(Uint8List bytes, String fileName) async {
    final file = File(p.join(directory.path, fileName));
    await file.writeAsBytes(bytes);
    return file.path;
  }

  @override
  Future<String> saveAudio(String tempPath) async {
    final target = File(
      p.join(directory.path, 'audio-${p.basename(tempPath)}'),
    );
    await File(tempPath).copy(target.path);
    return target.path;
  }
}
