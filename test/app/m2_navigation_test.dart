import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_note/app/app.dart';
import 'package:glass_note/domain/entities/folder.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/providers/infrastructure_providers.dart';

void main() {
  late AppDatabase database;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('shows the four-tab shell and settings entries', (tester) async {
    await _pumpApp(tester, database);

    expect(find.text('长按下方话筒，说出想法、笔记或任务。'), findsOneWidget);
    expect(find.text('捕获'), findsWidgets);
    expect(find.text('笔记'), findsOneWidget);
    expect(find.text('时间线'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);

    await tester.tap(find.text('设置').last);
    await _pumpUi(tester);

    expect(find.text('字体设置'), findsOneWidget);
    expect(find.text('API 设置'), findsOneWidget);
    expect(find.text('数据导出'), findsOneWidget);
    expect(find.text('数据导入'), findsOneWidget);

    await _disposeApp(tester);
  });

  testWidgets('plus menu creates a root note in uncategorized', (tester) async {
    await _pumpApp(tester, database);
    await _openNotes(tester);

    await tester.tap(find.byTooltip('新建'));
    await _pumpUi(tester);
    await tester.tap(find.text('新建笔记'));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('note-title-field')),
      '根目录笔记',
    );
    await tester.enterText(find.byKey(const ValueKey('note-body-field')), '正文');
    await tester.tap(find.text('完成'));
    await _flushAsyncUi(tester);

    final notes = await database.notesDao.listByFolder(Folder.uncategorizedId);
    await _pumpUi(tester);
    expect(notes.single.title, '根目录笔记');
    expect(find.text('根目录笔记'), findsOneWidget);

    await _disposeApp(tester);
  });

  testWidgets('notes create menu uses liquid glass surface', (tester) async {
    await _pumpApp(tester, database);
    await _openNotes(tester);

    await tester.tap(find.byTooltip('新建'));
    await _pumpUi(tester);

    expect(
      find.byKey(const ValueKey('notes-create-glass-menu-surface')),
      findsOneWidget,
    );
    expect(find.text('新建笔记'), findsOneWidget);
    expect(find.text('新建文件夹'), findsOneWidget);

    final surface = tester.widget<DecoratedBox>(
      find.byKey(const ValueKey('notes-create-glass-menu-surface')),
    );
    final decoration = surface.decoration as BoxDecoration;
    expect(decoration.color?.a, lessThan(0.5));

    await _disposeApp(tester);
  });

  testWidgets('opens a folder and creates a note inside it', (tester) async {
    await _pumpApp(tester, database);
    await _openNotes(tester);

    await tester.tap(find.byTooltip('新建'));
    await _pumpUi(tester);
    await tester.tap(find.text('新建文件夹'));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('folder-name-field')),
      '工作',
    );
    await tester.tap(find.text('创建'));
    await _flushAsyncUi(tester);

    await tester.tap(find.text('工作'));
    await _pumpUi(tester);
    expect(find.text('笔记 / 工作'), findsOneWidget);

    await tester.tap(find.byTooltip('新建').last);
    await _pumpUi(tester);
    await tester.tap(find.text('新建笔记'));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('note-title-field')),
      '工作笔记',
    );
    await tester.tap(find.text('完成'));
    await _flushAsyncUi(tester);

    final folder = (await database.foldersDao.listAll()).firstWhere(
      (folder) => folder.name == '工作',
    );
    final notes = await database.notesDao.listByFolder(folder.id);
    await _pumpUi(tester);
    expect(notes.single.title, '工作笔记');
    expect(find.text('工作笔记'), findsOneWidget);

    await _disposeApp(tester);
  });

  testWidgets('folder swipe actions rename star and delete user folders', (
    tester,
  ) async {
    await database.foldersDao.ensureUncategorized();
    await database.foldersDao.createFolder(
      FolderRowsCompanion.insert(
        id: 'work-folder',
        name: '工作',
        sortOrder: 1,
        isSystem: false,
        createdAt: DateTime(2026, 5, 27, 9),
        updatedAt: DateTime(2026, 5, 27, 9),
      ),
    );
    await database.notesDao.createNote(
      NoteRowsCompanion.insert(
        id: 'folder-note',
        title: '文件夹内笔记',
        plainText: '',
        richContentJson: '{}',
        folderId: 'work-folder',
        createdAt: DateTime(2026, 5, 27, 10),
        updatedAt: DateTime(2026, 5, 27, 10),
      ),
    );

    await _pumpApp(tester, database);
    await _openNotes(tester);

    await tester.drag(find.text('工作'), const Offset(500, 0));
    await _pumpUi(tester);
    expect(find.text('重命名'), findsOneWidget);
    expect(find.text('星标'), findsOneWidget);

    await tester.tap(find.text('星标'));
    await _pumpUi(tester);
    expect(
      (await database.foldersDao.findById('work-folder'))?.isStarred,
      isTrue,
    );

    await tester.drag(find.text('工作'), const Offset(500, 0));
    await _pumpUi(tester);
    await tester.tap(find.text('重命名'));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('folder-rename-field')),
      '项目',
    );
    await tester.tap(find.text('保存'));
    await _flushAsyncUi(tester);
    expect(find.text('项目'), findsOneWidget);
    expect((await database.foldersDao.findById('work-folder'))?.name, '项目');

    await tester.drag(find.text('项目'), const Offset(-500, 0));
    await _pumpUi(tester);
    expect(find.text('删除'), findsOneWidget);
    await tester.tap(find.text('删除'));
    await _pumpUi(tester);

    expect(await database.foldersDao.findById('work-folder'), isNull);
    expect(
      (await database.notesDao.findById('folder-note'))?.folderId,
      Folder.uncategorizedId,
    );

    await _disposeApp(tester);
  });

  testWidgets('swiping a note can star and delete it', (tester) async {
    await database.foldersDao.ensureUncategorized();
    await database.notesDao.createNote(
      NoteRowsCompanion.insert(
        id: 'n1',
        title: '待处理',
        plainText: '',
        richContentJson: '{}',
        folderId: Folder.uncategorizedId,
        createdAt: DateTime(2026, 5, 27, 9),
        updatedAt: DateTime(2026, 5, 27, 9),
      ),
    );
    await _pumpApp(tester, database);
    await _openNotes(tester);

    await tester.drag(find.text('待处理'), const Offset(-500, 0));
    await _pumpUi(tester);
    await tester.tap(find.text('星标'));
    await _pumpUi(tester);
    expect((await database.notesDao.findById('n1'))?.isStarred, isTrue);

    await tester.drag(find.text('待处理'), const Offset(-500, 0));
    await _pumpUi(tester);
    await tester.tap(find.text('删除'));
    await _pumpUi(tester);
    expect((await database.notesDao.findById('n1'))?.isDeleted, isTrue);

    await _disposeApp(tester);
  });

  testWidgets('tapping elsewhere closes an open note swipe action row', (
    tester,
  ) async {
    await database.foldersDao.ensureUncategorized();
    await database.notesDao.createNote(
      NoteRowsCompanion.insert(
        id: 'n-left',
        title: '左滑笔记',
        plainText: '',
        richContentJson: '{}',
        folderId: Folder.uncategorizedId,
        createdAt: DateTime(2026, 5, 27, 9),
        updatedAt: DateTime(2026, 5, 27, 9),
      ),
    );
    await database.notesDao.createNote(
      NoteRowsCompanion.insert(
        id: 'n-other',
        title: '其他笔记',
        plainText: '',
        richContentJson: '{}',
        folderId: Folder.uncategorizedId,
        createdAt: DateTime(2026, 5, 27, 10),
        updatedAt: DateTime(2026, 5, 27, 10),
      ),
    );
    await _pumpApp(tester, database);
    await _openNotes(tester);

    await tester.drag(find.text('左滑笔记'), const Offset(-500, 0));
    await _pumpUi(tester);
    expect(find.text('星标'), findsOneWidget);

    await tester.tap(find.text('其他笔记'));
    await _pumpUi(tester);
    expect(find.text('星标'), findsNothing);
    expect(find.byKey(const ValueKey('note-editor-page')), findsNothing);

    await _disposeApp(tester);
  });

  testWidgets('search finds matching folders and notes', (tester) async {
    await database.foldersDao.ensureUncategorized();
    await database.foldersDao.createFolder(
      FolderRowsCompanion.insert(
        id: 'work-folder',
        name: '工作',
        sortOrder: 1,
        isSystem: false,
        createdAt: DateTime(2026, 5, 27, 9),
        updatedAt: DateTime(2026, 5, 27, 9),
      ),
    );
    await database.notesDao.createNote(
      NoteRowsCompanion.insert(
        id: 'n-search',
        title: '项目计划',
        plainText: '周五前整理',
        richContentJson: '{}',
        folderId: Folder.uncategorizedId,
        createdAt: DateTime(2026, 5, 27, 10),
        updatedAt: DateTime(2026, 5, 27, 10),
      ),
    );
    await database.notesDao.createNote(
      NoteRowsCompanion.insert(
        id: 'n-hidden',
        title: '购物清单',
        plainText: '',
        richContentJson: '{}',
        folderId: Folder.uncategorizedId,
        createdAt: DateTime(2026, 5, 27, 11),
        updatedAt: DateTime(2026, 5, 27, 11),
      ),
    );

    await _pumpApp(tester, database);
    await _openNotes(tester);

    await tester.enterText(
      find.byKey(const ValueKey('notes-search-field')),
      '项目',
    );
    await _flushAsyncUi(tester);

    expect(find.text('项目计划'), findsOneWidget);
    expect(find.text('购物清单'), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('notes-search-field')),
      '工作',
    );
    await _flushAsyncUi(tester);

    expect(find.text('工作'), findsWidgets);
    expect(find.text('项目计划'), findsNothing);

    await _disposeApp(tester);
  });

  testWidgets('opening a note uses a full-screen editor without bottom tabs', (
    tester,
  ) async {
    await database.foldersDao.ensureUncategorized();
    await database.notesDao.createNote(
      NoteRowsCompanion.insert(
        id: 'n-edit',
        title: '会议记录',
        plainText: '已有内容',
        richContentJson: '{}',
        folderId: Folder.uncategorizedId,
        createdAt: DateTime(2026, 5, 27, 9),
        updatedAt: DateTime(2026, 5, 27, 9),
      ),
    );

    await _pumpApp(tester, database);
    await _openNotes(tester);
    await tester.tap(find.text('会议记录'));
    await _pumpUi(tester);

    expect(find.byKey(const ValueKey('note-editor-page')), findsOneWidget);
    expect(find.byKey(const ValueKey('note-editor-content')), findsOneWidget);
    expect(find.text('时间线').hitTestable(), findsNothing);
    expect(find.text('捕获').hitTestable(), findsNothing);

    await tester.enterText(
      find.byKey(const ValueKey('note-body-field')),
      '更新后的内容',
    );
    await tester.tap(find.text('完成'));
    await _flushAsyncUi(tester);

    expect((await database.notesDao.findById('n-edit'))?.plainText, '更新后的内容');

    await _disposeApp(tester);
  });

  testWidgets('timeline keeps the same search entry pattern', (tester) async {
    await _pumpApp(tester, database);

    await tester.tap(find.text('时间线').last);
    await _pumpUi(tester);

    expect(find.byTooltip('搜索任务'), findsOneWidget);
    await tester.tap(find.byTooltip('搜索任务'));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('timeline-search-overlay-field')),
      '明天',
    );
    await _pumpUi(tester);
    await tester.tap(find.byKey(const ValueKey('timeline-search-submit')));
    await _pumpUi(tester);
    expect(find.text('未找到相关任务'), findsOneWidget);

    await _disposeApp(tester);
  });
}

Future<void> _pumpApp(WidgetTester tester, AppDatabase database) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
      child: const GlassNoteApp(),
    ),
  );
  await _pumpUi(tester);
}

Future<void> _openNotes(WidgetTester tester) async {
  await tester.tap(find.text('笔记').last);
  await _pumpUi(tester);
}

Future<void> _pumpUi(WidgetTester tester) async {
  for (var i = 0; i < 5; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _flushAsyncUi(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await _pumpUi(tester);
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 1));
}
