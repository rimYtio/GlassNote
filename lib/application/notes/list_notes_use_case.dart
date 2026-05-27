import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';

class ListNotesUseCase {
  const ListNotesUseCase(this._notes);

  final NoteRepository _notes;

  Future<List<Note>> call({required String folderId}) async {
    return NoteSort.sortedForList(await _notes.listByFolder(folderId));
  }
}
