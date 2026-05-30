import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../database/app_database.dart';

class NoteRepositoryImpl implements NoteRepository {
  const NoteRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Note> create(NoteDraft draft) {
    final now = DateTime.now();
    return _database.notesDao.createNote(
      NoteRowsCompanion.insert(
        id: const Uuid().v4(),
        title: draft.title.trim().isEmpty ? '无标题笔记' : draft.title.trim(),
        plainText: draft.plainText,
        richContentJson: draft.richContentJson,
        folderId: draft.folderId,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> delete(String id) {
    return _database.notesDao.softDelete(id);
  }

  @override
  Future<Note?> findById(String id) {
    return _database.notesDao.findById(id);
  }

  @override
  Future<List<Note>> listByFolder(String folderId) {
    return _database.notesDao.listByFolder(folderId);
  }

  @override
  Future<void> moveNotesToFolder({
    required String fromFolderId,
    required String toFolderId,
  }) {
    return _database.notesDao.moveNotesToFolder(
      fromFolderId: fromFolderId,
      toFolderId: toFolderId,
    );
  }

  @override
  Future<List<Note>> search(String query) {
    return _database.notesDao.search(query);
  }

  @override
  Future<Note> update(Note note) {
    debugPrint('[NoteRepo] updateNote IN id=${note.id} contentLen=${note.plainText.length} deltaLen=${note.richContentJson.length}');
    return _database.notesDao.updateNote(
      note.copyWith(updatedAt: DateTime.now()),
    );
  }

  @override
  Stream<List<Note>> watchByFolder(String folderId) {
    return _database.notesDao.watchByFolder(folderId);
  }

  @override
  Future<List<Note>> listDeleted() {
    return _database.notesDao.listDeleted();
  }

  @override
  Future<void> restore(String id) {
    return _database.notesDao.restore(id);
  }

  @override
  Future<void> permanentlyDelete(String id) {
    return _database.notesDao.permanentlyDelete(id);
  }

  @override
  Stream<List<Note>> watchRecent({int limit = 5}) {
    return _database.notesDao.watchRecent(limit: limit);
  }

  @override
  Stream<List<Note>> watchAll() {
    return _database.notesDao.watchAll();
  }
}
