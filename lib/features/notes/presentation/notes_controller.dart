import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/note_folder_use_case_providers.dart';
import '../../../application/notes/create_note_use_case.dart';
import '../../../domain/entities/folder.dart';
import '../../../domain/entities/note.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';

final ensureUncategorizedProvider = FutureProvider<Folder>((ref) {
  return ref.watch(folderRepositoryProvider).ensureUncategorized();
});

final allFoldersProvider = FutureProvider<List<Folder>>((ref) async {
  await ref.watch(ensureUncategorizedProvider.future);
  return ref.watch(folderRepositoryProvider).listAll();
});

final rootFoldersProvider = StreamProvider<List<Folder>>((ref) async* {
  await ref.watch(ensureUncategorizedProvider.future);
  yield* ref.watch(folderRepositoryProvider).watchRootFolders();
});

final notesByFolderProvider = StreamProvider.family<List<Note>, String>((
  ref,
  folderId,
) async* {
  await ref.watch(ensureUncategorizedProvider.future);
  yield* ref.watch(noteRepositoryProvider).watchByFolder(folderId);
});

final noteSearchProvider = FutureProvider.family<List<Note>, String>((
  ref,
  query,
) async {
  await ref.watch(ensureUncategorizedProvider.future);
  final trimmed = query.trim();
  if (trimmed.isEmpty) {
    return const [];
  }
  return ref.watch(noteRepositoryProvider).search(trimmed);
});

final noteByIdProvider = FutureProvider.family<Note?, String>((ref, noteId) {
  return ref.watch(noteRepositoryProvider).findById(noteId);
});

final notesActionsProvider = Provider<NotesActions>((ref) {
  return NotesActions(ref);
});

class NotesActions {
  const NotesActions(this._ref);

  final Ref _ref;

  Future<Folder> createFolder(String name, {String? parentId}) async {
    final folder = await _ref
        .read(folderRepositoryProvider)
        .create(FolderDraft(name: name, parentId: parentId));
    _ref.invalidate(allFoldersProvider);
    return folder;
  }

  Future<Note> createNote({
    required String title,
    required String plainText,
    required String richContentJson,
    String? folderId,
  }) {
    return _ref.read(createNoteUseCaseProvider)(
      CreateNoteCommand(
        title: title,
        plainText: plainText,
        richContentJson: richContentJson,
        folderId: folderId,
      ),
    );
  }

  Future<Note> updateNote(Note note) {
    return _ref.read(noteRepositoryProvider).update(note);
  }

  Future<void> toggleStar(Note note) {
    return _ref
        .read(noteRepositoryProvider)
        .update(note.copyWith(isStarred: !note.isStarred));
  }

  Future<void> deleteNote(Note note) {
    return _ref.read(noteRepositoryProvider).delete(note.id);
  }

  Future<void> deleteFolder(String folderId) {
    return _ref.read(deleteFolderUseCaseProvider)(folderId);
  }
}
