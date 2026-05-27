import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/application/folders/delete_folder_use_case.dart';
import 'package:glass_note/application/notes/create_note_use_case.dart';
import 'package:glass_note/application/notes/list_notes_use_case.dart';
import 'package:glass_note/domain/entities/folder.dart';
import 'package:glass_note/domain/entities/note.dart';
import 'package:glass_note/domain/repositories/folder_repository.dart';
import 'package:glass_note/domain/repositories/note_repository.dart';

void main() {
  test('creating a root note uses the uncategorized folder', () async {
    final notes = _FakeNoteRepository();
    final folders = _FakeFolderRepository();
    final useCase = CreateNoteUseCase(notes, folders);

    final note = await useCase(
      CreateNoteCommand(
        title: 'Root note',
        plainText: 'Text',
        richContentJson: '{}',
      ),
    );

    expect(note.folderId, Folder.uncategorizedId);
    expect(folders.ensureUncategorizedCalled, isTrue);
  });

  test('creating a note inside a folder keeps that folder id', () async {
    final notes = _FakeNoteRepository();
    final folders = _FakeFolderRepository();
    final useCase = CreateNoteUseCase(notes, folders);

    final note = await useCase(
      CreateNoteCommand(
        title: 'Folder note',
        plainText: '',
        richContentJson: '{}',
        folderId: 'work',
      ),
    );

    expect(note.folderId, 'work');
  });

  test('listing notes returns starred notes first', () async {
    final notes = _FakeNoteRepository()
      ..notes = [
        _note('normal', DateTime(2026, 5, 27, 9)),
        _note('starred', DateTime(2026, 5, 27, 8), isStarred: true),
      ];
    final useCase = ListNotesUseCase(notes);

    final listed = await useCase(folderId: Folder.uncategorizedId);

    expect(listed.map((note) => note.id), ['starred', 'normal']);
  });

  test('deleting a folder moves its notes to uncategorized', () async {
    final notes = _FakeNoteRepository();
    final folders = _FakeFolderRepository();
    final useCase = DeleteFolderUseCase(folders, notes);

    await useCase('work');

    expect(notes.movedFromFolderId, 'work');
    expect(notes.movedToFolderId, Folder.uncategorizedId);
    expect(folders.deletedFolderId, 'work');
  });
}

class _FakeNoteRepository implements NoteRepository {
  List<Note> notes = [];
  String? movedFromFolderId;
  String? movedToFolderId;

  @override
  Future<Note> create(NoteDraft draft) async {
    final now = DateTime(2026, 5, 27, 9);
    final note = Note(
      id: 'note-${notes.length + 1}',
      title: draft.title,
      plainText: draft.plainText,
      richContentJson: draft.richContentJson,
      folderId: draft.folderId,
      isStarred: false,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );
    notes.add(note);
    return note;
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<Note?> findById(String id) async => null;

  @override
  Future<List<Note>> listByFolder(String folderId) async =>
      notes.where((note) => note.folderId == folderId).toList();

  @override
  Future<void> moveNotesToFolder({
    required String fromFolderId,
    required String toFolderId,
  }) async {
    movedFromFolderId = fromFolderId;
    movedToFolderId = toFolderId;
  }

  @override
  Future<List<Note>> search(String query) async => const [];

  @override
  Future<Note> update(Note note) async => note;

  @override
  Stream<List<Note>> watchByFolder(String folderId) => const Stream.empty();
}

class _FakeFolderRepository implements FolderRepository {
  bool ensureUncategorizedCalled = false;
  String? deletedFolderId;

  @override
  Future<Folder> create(FolderDraft draft) {
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) async {
    deletedFolderId = id;
  }

  @override
  Future<Folder> ensureUncategorized() async {
    ensureUncategorizedCalled = true;
    return Folder.uncategorized(now: DateTime(2026, 5, 27, 9));
  }

  @override
  Future<Folder?> findById(String id) async => null;

  @override
  Future<List<Folder>> listAll() async => const [];

  @override
  Stream<List<Folder>> watchRootFolders() => const Stream.empty();
}

Note _note(String id, DateTime createdAt, {bool isStarred = false}) {
  return Note(
    id: id,
    title: id,
    plainText: '',
    richContentJson: '{}',
    folderId: Folder.uncategorizedId,
    isStarred: isStarred,
    isDeleted: false,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}
