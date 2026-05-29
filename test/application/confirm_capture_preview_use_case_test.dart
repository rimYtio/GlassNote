import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/application/capture/confirm_capture_preview_use_case.dart';
import 'package:glass_note/domain/entities/capture_draft_preview.dart';
import 'package:glass_note/domain/entities/folder.dart';
import 'package:glass_note/domain/entities/note.dart';
import 'package:glass_note/domain/entities/timeline_task.dart';
import 'package:glass_note/domain/repositories/folder_repository.dart';
import 'package:glass_note/domain/repositories/note_repository.dart';
import 'package:glass_note/domain/repositories/timeline_task_repository.dart';

void main() {
  test('confirming a note preview creates a folder and note', () async {
    final notes = _FakeNoteRepository();
    final folders = _FakeFolderRepository();
    final tasks = _FakeTimelineTaskRepository();
    final useCase = ConfirmCapturePreviewUseCase(
      notes: notes,
      folders: folders,
      tasks: tasks,
    );

    await useCase([
      CaptureDraftPreview.note(
        title: '项目想法',
        content: '把捕获页做成语音入口。',
        folderName: '灵感',
      ),
    ]);

    expect(folders.createdNames, ['灵感']);
    expect(notes.notes.single.title, '项目想法');
    expect(notes.notes.single.folderId, 'folder-1');
    expect(tasks.tasks, isEmpty);
  });

  test('confirming a task preview creates a timeline task', () async {
    final notes = _FakeNoteRepository();
    final folders = _FakeFolderRepository();
    final tasks = _FakeTimelineTaskRepository();
    final useCase = ConfirmCapturePreviewUseCase(
      notes: notes,
      folders: folders,
      tasks: tasks,
    );

    await useCase([
      CaptureDraftPreview.task(
        title: '提交周报',
        content: '周报发给团队。',
        taskDate: DateTime(2026, 6, 3),
        startTime: const CaptureClockTime(hour: 9, minute: 30),
        importance: TimelineImportance.high,
      ),
    ]);

    expect(notes.notes, isEmpty);
    expect(tasks.tasks.single.title, '提交周报');
    expect(tasks.tasks.single.taskDate, DateTime(2026, 6, 3));
    expect(tasks.tasks.single.startAt, DateTime(2026, 6, 3, 9, 30));
    expect(tasks.tasks.single.importance, TimelineImportance.high);
  });
}

class _FakeNoteRepository implements NoteRepository {
  final notes = <Note>[];

  @override
  Future<Note> create(NoteDraft draft) async {
    final now = DateTime(2026, 5, 28, 9);
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
  Future<List<Note>> listByFolder(String folderId) async => const [];

  @override
  Future<void> moveNotesToFolder({
    required String fromFolderId,
    required String toFolderId,
  }) async {}

  @override
  Future<List<Note>> search(String query) async => const [];

  @override
  Future<Note> update(Note note) async => note;

  @override
  Stream<List<Note>> watchByFolder(String folderId) => const Stream.empty();

  @override
  Future<List<Note>> listDeleted() async => const [];

  @override
  Future<void> restore(String id) async {}

  @override
  Future<void> permanentlyDelete(String id) async {}
}

class _FakeFolderRepository implements FolderRepository {
  final folders = <Folder>[];
  final createdNames = <String>[];

  @override
  Future<Folder> create(FolderDraft draft) async {
    createdNames.add(draft.name);
    final now = DateTime(2026, 5, 28, 9);
    final folder = Folder(
      id: 'folder-${folders.length + 1}',
      name: draft.name,
      parentId: draft.parentId,
      sortOrder: folders.length + 1,
      isSystem: false,
      isStarred: false,
      createdAt: now,
      updatedAt: now,
    );
    folders.add(folder);
    return folder;
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<Folder> ensureUncategorized() async =>
      Folder.uncategorized(now: DateTime(2026, 5, 28, 9));

  @override
  Future<Folder?> findById(String id) async => null;

  @override
  Future<List<Folder>> listAll() async => folders;

  @override
  Future<Folder> update(Folder folder) async => folder;

  @override
  Stream<List<Folder>> watchRootFolders() => const Stream.empty();
}

class _FakeTimelineTaskRepository implements TimelineTaskRepository {
  final tasks = <TimelineTaskDraft>[];

  @override
  Future<TimelineTask> create(TimelineTaskDraft draft) async {
    tasks.add(draft);
    return TimelineTask(
      id: 'task-${tasks.length}',
      title: draft.title,
      description: draft.description,
      taskDate: draft.taskDate,
      startAt: draft.startAt,
      endAt: draft.endAt,
      importance: draft.importance,
      colorArgb: draft.colorArgb,
      isCompleted: false,
      isStarred: false,
      isDeleted: false,
      createdAt: DateTime(2026, 5, 28, 9),
      updatedAt: DateTime(2026, 5, 28, 9),
    );
  }

  @override
  Future<void> delete(String id) async {}

  @override
  Future<TimelineTask?> findById(String id) async => null;

  @override
  Future<List<TimelineTask>> listRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async => const [];

  @override
  Future<List<TimelineTask>> search(String query) async => const [];

  @override
  Future<TimelineTask> update(TimelineTask task) async => task;

  @override
  Stream<List<TimelineTask>> watchRange({
    required DateTime startDate,
    required DateTime endDate,
  }) => const Stream.empty();
}
