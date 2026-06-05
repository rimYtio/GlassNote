// ignore_for_file: prefer_initializing_formals

import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../infrastructure/file_system/attachment_file_store.dart';

class SaveNoteImageAttachmentUseCase {
  const SaveNoteImageAttachmentUseCase({
    required AttachmentRepository attachmentRepository,
    required AttachmentFileStore fileStore,
  }) : _attachmentRepository = attachmentRepository,
       _fileStore = fileStore;

  final AttachmentRepository _attachmentRepository;
  final AttachmentFileStore _fileStore;

  Future<Attachment> call({
    required String noteId,
    required List<int> bytes,
    required String originalFileName,
  }) async {
    final id = const Uuid().v4();
    final ext = _extensionFor(originalFileName, fallback: '.png');
    final fileName = 'img_$id$ext';
    final localPath = await _fileStore.saveImage(
      Uint8List.fromList(bytes),
      fileName,
    );
    return _attachmentRepository.save(
      Attachment(
        id: id,
        noteId: noteId,
        type: AttachmentType.image,
        fileName: fileName,
        localPath: localPath,
        mimeType: _imageMime(ext),
        sizeBytes: bytes.length,
        createdAt: DateTime.now(),
      ),
    );
  }

  String _extensionFor(String name, {required String fallback}) {
    final ext = p.extension(name).toLowerCase();
    if (ext.isEmpty) return fallback;
    return ext;
  }

  String _imageMime(String ext) {
    return switch (ext.toLowerCase()) {
      '.jpg' || '.jpeg' => 'image/jpeg',
      '.gif' => 'image/gif',
      '.webp' => 'image/webp',
      _ => 'image/png',
    };
  }
}
