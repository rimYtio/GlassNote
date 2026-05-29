import 'package:uuid/uuid.dart';

import '../../domain/entities/note.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tag_repository.dart';
import '../database/app_database.dart';

class TagRepositoryImpl implements TagRepository {
  const TagRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Tag> create(String name, int color) {
    final now = DateTime.now();
    return _database.tagsDao.createTag(
      TagRowsCompanion.insert(
        id: const Uuid().v4(),
        name: name.trim(),
        color: color,
        createdAt: now,
      ),
    );
  }

  @override
  Future<List<Tag>> listAll() {
    return _database.tagsDao.listAll();
  }

  @override
  Stream<List<Tag>> watchAll() {
    return _database.tagsDao.watchAll();
  }

  @override
  Future<void> delete(String id) {
    return _database.tagsDao.deleteTag(id);
  }

  @override
  Future<void> rename(String id, String name) {
    return _database.tagsDao.renameTag(id, name.trim());
  }

  @override
  Future<List<Tag>> listByNote(String noteId) {
    return _database.tagsDao.listByNote(noteId);
  }

  @override
  Future<void> addTagToNote(String noteId, String tagId) {
    return _database.tagsDao.addTagToNote(noteId, tagId);
  }

  @override
  Future<void> removeTagFromNote(String noteId, String tagId) {
    return _database.tagsDao.removeTagFromNote(noteId, tagId);
  }

  @override
  Future<List<Note>> listNotesByTag(String tagId) {
    return _database.tagsDao.listNotesByTag(tagId);
  }
}
