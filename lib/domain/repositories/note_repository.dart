import '../entities/note.dart';

abstract interface class NoteRepository {
  Future<Note> create(NoteDraft draft);

  Future<Note> update(Note note);

  Future<void> delete(String id);

  Future<Note?> findById(String id);

  Future<List<Note>> listByFolder(String folderId);

  Future<List<Note>> search(String query);

  Future<void> moveNotesToFolder({
    required String fromFolderId,
    required String toFolderId,
  });

  Stream<List<Note>> watchByFolder(String folderId);
}
