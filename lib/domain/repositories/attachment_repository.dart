import '../entities/attachment.dart';

abstract interface class AttachmentRepository {
  Future<Attachment> save(Attachment attachment);

  Future<List<Attachment>> listByNote(String noteId);

  Future<void> delete(String id);

  Future<void> deleteAllByNote(String noteId);

  Stream<List<Attachment>> watchByNote(String noteId);
}
