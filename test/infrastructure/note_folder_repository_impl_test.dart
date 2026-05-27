import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/domain/entities/folder.dart';
import 'package:glass_note/domain/entities/note.dart';
import 'package:glass_note/domain/entities/app_settings.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/repositories/folder_repository_impl.dart';
import 'package:glass_note/infrastructure/repositories/note_repository_impl.dart';

void main() {
  late AppDatabase database;
  late FolderRepositoryImpl folders;
  late NoteRepositoryImpl notes;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    folders = FolderRepositoryImpl(database);
    notes = NoteRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('seeds uncategorized folder and keeps settings readable', () async {
    final folder = await folders.ensureUncategorized();
    final settings = await database.settingsDao.loadSettings();

    expect(folder.id, Folder.uncategorizedId);
    expect(folder.name, '未分类');
    expect(folder.isStarred, isFalse);
    expect(settings.id, AppSettings.defaultId);
  });

  test('updates folder name and starred state', () async {
    final work = await folders.create(
      const FolderDraft(name: '工作', parentId: null),
    );

    final updated = await folders.update(
      work.copyWith(name: '项目', isStarred: true),
    );

    expect(updated.name, '项目');
    expect(updated.isStarred, isTrue);
    expect((await folders.findById(work.id))?.name, '项目');
    expect((await folders.findById(work.id))?.isStarred, isTrue);
  });

  test('creates folders and notes, searches notes, and soft deletes', () async {
    final work = await folders.create(
      const FolderDraft(name: '工作', parentId: null),
    );
    final note = await notes.create(
      NoteDraft(
        title: '项目计划',
        plainText: '周五整理迁移方案',
        richContentJson: '{}',
        folderId: work.id,
      ),
    );

    final found = await notes.search('迁移');
    expect(found.single.id, note.id);

    await notes.delete(note.id);
    final afterDelete = await notes.listByFolder(work.id);
    expect(afterDelete, isEmpty);
  });

  test('moves notes to uncategorized before deleting a folder', () async {
    final work = await folders.create(
      const FolderDraft(name: '工作', parentId: null),
    );
    final note = await notes.create(
      NoteDraft(
        title: '待移动',
        plainText: '',
        richContentJson: '{}',
        folderId: work.id,
      ),
    );

    await notes.moveNotesToFolder(
      fromFolderId: work.id,
      toFolderId: Folder.uncategorizedId,
    );
    await folders.delete(work.id);

    final moved = await notes.findById(note.id);
    expect(moved?.folderId, Folder.uncategorizedId);
    expect(await folders.findById(work.id), isNull);
  });
}
