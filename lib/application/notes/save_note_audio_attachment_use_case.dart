// ignore_for_file: prefer_initializing_formals

import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../infrastructure/file_system/attachment_file_store.dart';

class SaveNoteAudioAttachmentUseCase {
  const SaveNoteAudioAttachmentUseCase({
    required AttachmentRepository attachmentRepository,
    required AttachmentFileStore fileStore,
  }) : _attachmentRepository = attachmentRepository,
       _fileStore = fileStore;

  final AttachmentRepository _attachmentRepository;
  final AttachmentFileStore _fileStore;

  Future<Attachment> call({
    required String noteId,
    required String tempFilePath,
    int? durationMs,
  }) async {
    final localPath = await _fileStore.saveAudio(tempFilePath);
    final file = File(localPath);
    final id = const Uuid().v4();
    final ext = p.extension(localPath).toLowerCase();
    final attachment = Attachment(
      id: id,
      noteId: noteId,
      type: AttachmentType.audio,
      fileName: p.basename(localPath),
      localPath: localPath,
      mimeType: ext == '.wav' ? 'audio/wav' : 'audio/mp4',
      sizeBytes: await file.length(),
      durationMs: durationMs,
      createdAt: DateTime.now(),
    );
    return _attachmentRepository.save(attachment);
  }
}
