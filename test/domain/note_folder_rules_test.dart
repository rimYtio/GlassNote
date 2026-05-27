import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/application/folders/build_folder_path_use_case.dart';
import 'package:glass_note/domain/entities/folder.dart';
import 'package:glass_note/domain/entities/note.dart';

void main() {
  test('default uncategorized folder is a system root folder', () {
    final now = DateTime(2026, 5, 27, 9);

    final folder = Folder.uncategorized(now: now);

    expect(folder.id, Folder.uncategorizedId);
    expect(folder.name, '未分类');
    expect(folder.parentId, isNull);
    expect(folder.isSystem, isTrue);
    expect(folder.isStarred, isFalse);
    expect(folder.createdAt, now);
    expect(folder.updatedAt, now);
  });

  test('folders sort with system folders first then starred user folders', () {
    final now = DateTime(2026, 5, 27, 9);
    final folders = [
      _folder('normal-old', sortOrder: 1, createdAt: now),
      _folder('starred-new', sortOrder: 2, createdAt: now, isStarred: true),
      _folder('system', sortOrder: 0, createdAt: now, isSystem: true),
      _folder('normal-new', sortOrder: 3, createdAt: now),
    ];

    final sorted = FolderSort.sortedForList(folders);

    expect(sorted.map((folder) => folder.id), [
      'system',
      'starred-new',
      'normal-old',
      'normal-new',
    ]);
  });

  test('notes sort with starred notes first then created time descending', () {
    final older = DateTime(2026, 5, 27, 9);
    final newer = DateTime(2026, 5, 27, 10);
    final notes = [
      _note('normal-old', createdAt: older),
      _note('starred-old', createdAt: older, isStarred: true),
      _note('normal-new', createdAt: newer),
      _note('starred-new', createdAt: newer, isStarred: true),
    ];

    final sorted = NoteSort.sortedForList(notes);

    expect(sorted.map((note) => note.id), [
      'starred-new',
      'starred-old',
      'normal-new',
      'normal-old',
    ]);
  });

  test('folder path resolves from root to current folder', () {
    final now = DateTime(2026, 5, 27, 9);
    final work = Folder(
      id: 'work',
      name: '工作',
      parentId: null,
      sortOrder: 1,
      isSystem: false,
      isStarred: false,
      createdAt: now,
      updatedAt: now,
    );
    final project = work.copyWith(
      id: 'project-a',
      name: '项目A',
      parentId: work.id,
    );

    final path = const BuildFolderPathUseCase()(
      folderId: project.id,
      folders: [project, work],
    );

    expect(path, ['笔记', '工作', '项目A']);
  });
}

Folder _folder(
  String id, {
  required int sortOrder,
  required DateTime createdAt,
  bool isSystem = false,
  bool isStarred = false,
}) {
  return Folder(
    id: id,
    name: id,
    parentId: null,
    sortOrder: sortOrder,
    isSystem: isSystem,
    isStarred: isStarred,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

Note _note(String id, {required DateTime createdAt, bool isStarred = false}) {
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
