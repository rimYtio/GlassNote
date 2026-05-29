import '../../domain/entities/attachment.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../database/app_database.dart';

class AttachmentRepositoryImpl implements AttachmentRepository {
  const AttachmentRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Attachment> save(Attachment attachment) {
    return _database.attachmentsDao.save(attachment);
  }

  @override
  Future<List<Attachment>> listByNote(String noteId) {
    return _database.attachmentsDao.listByNote(noteId);
  }

  @override
  Future<void> delete(String id) {
    return _database.attachmentsDao.deleteAttachment(id);
  }

  @override
  Future<void> deleteAllByNote(String noteId) {
    return _database.attachmentsDao.deleteAllByNote(noteId);
  }

  @override
  Stream<List<Attachment>> watchByNote(String noteId) {
    return _database.attachmentsDao.watchByNote(noteId);
  }
}
