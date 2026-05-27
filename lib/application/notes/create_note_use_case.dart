import '../../domain/entities/folder.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/repositories/note_repository.dart';

class CreateNoteCommand {
  const CreateNoteCommand({
    required this.title,
    required this.plainText,
    required this.richContentJson,
    this.folderId,
  });

  final String title;
  final String plainText;
  final String richContentJson;
  final String? folderId;
}

class CreateNoteUseCase {
  const CreateNoteUseCase(this._notes, this._folders);

  final NoteRepository _notes;
  final FolderRepository _folders;

  Future<Note> call(CreateNoteCommand command) async {
    final folderId = command.folderId ?? Folder.uncategorizedId;
    if (folderId == Folder.uncategorizedId) {
      await _folders.ensureUncategorized();
    }

    return _notes.create(
      NoteDraft(
        title: command.title,
        plainText: command.plainText,
        richContentJson: command.richContentJson,
        folderId: folderId,
      ),
    );
  }
}
