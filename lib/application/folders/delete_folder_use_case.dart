import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/repositories/note_repository.dart';

class DeleteFolderUseCase {
  const DeleteFolderUseCase(this._folders, this._notes);

  final FolderRepository _folders;
  final NoteRepository _notes;

  Future<void> call(String folderId) async {
    if (folderId == Folder.uncategorizedId) {
      return;
    }

    await _folders.ensureUncategorized();
    await _notes.moveNotesToFolder(
      fromFolderId: folderId,
      toFolderId: Folder.uncategorizedId,
    );
    await _folders.delete(folderId);
  }
}
