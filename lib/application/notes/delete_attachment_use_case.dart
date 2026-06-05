// ignore_for_file: prefer_initializing_formals

import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../infrastructure/file_system/attachment_file_store.dart';

class DeleteAttachmentUseCase {
  const DeleteAttachmentUseCase({
    required AttachmentRepository attachmentRepository,
    required AttachmentFileStore fileStore,
  }) : _attachmentRepository = attachmentRepository,
       _fileStore = fileStore;

  final AttachmentRepository _attachmentRepository;
  final AttachmentFileStore _fileStore;

  Future<void> call(Attachment attachment) async {
    await _attachmentRepository.delete(attachment.id);
    await _fileStore.deleteFile(attachment.localPath);
  }
}
