import '../entities/note.dart';
import '../entities/tag.dart';

abstract interface class TagRepository {
  Future<Tag> create(String name, int color);

  Future<List<Tag>> listAll();

  Future<void> delete(String id);

  Future<void> rename(String id, String name);

  Stream<List<Tag>> watchAll();

  Future<List<Tag>> listByNote(String noteId);

  Future<void> addTagToNote(String noteId, String tagId);

  Future<void> removeTagFromNote(String noteId, String tagId);

  Future<List<Note>> listNotesByTag(String tagId);
}
