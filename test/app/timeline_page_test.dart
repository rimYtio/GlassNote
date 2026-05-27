import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_note/app/app.dart';
import 'package:glass_note/domain/entities/timeline_task.dart';
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

  testWidgets('timeline creates a task from the floating add sheet', (
    tester,
  ) async {
    await _pumpApp(tester, database);
    await _openTimeline(tester);

    expect(find.byTooltip('搜索任务'), findsOneWidget);
    expect(find.byTooltip('新增任务'), findsOneWidget);

    await tester.tap(find.byTooltip('新增任务'));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('timeline-task-title-field')),
      '完成项目计划',
    );
    await tester.tap(find.text('高'));
    await _pumpUi(tester);
    await tester.tap(find.text('保存任务'));
    await _flushAsyncUi(tester);

    expect(find.text('完成项目计划'), findsOneWidget);
    expect(
      (await database.timelineTasksDao.search('项目')).single.title,
      '完成项目计划',
    );

    await _disposeApp(tester);
  });

  testWidgets('timeline searches all active tasks from a search dialog', (
    tester,
  ) async {
    await _seedTask(
      database,
      id: 'today-task',
      title: '今天汇报',
      taskDate: DateTime.now(),
    );
    await _seedTask(
      database,
      id: 'future-task',
      title: '未来会议',
      taskDate: DateTime.now().add(const Duration(days: 8)),
    );

    await _pumpApp(tester, database);
    await _openTimeline(tester);

    await tester.tap(find.byTooltip('搜索任务'));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('timeline-search-dialog-field')),
      '未来',
    );
    await _flushAsyncUi(tester);

    final dialog = find.byType(AlertDialog);
    expect(
      find.descendant(of: dialog, matching: find.text('未来会议')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('今天汇报')),
      findsNothing,
    );

    await _disposeApp(tester);
  });

  testWidgets('timeline swipe gestures star and delete tasks', (tester) async {
    await _seedTask(
      database,
      id: 'gesture-task',
      title: '滑动任务',
      taskDate: DateTime.now(),
    );

    await _pumpApp(tester, database);
    await _openTimeline(tester);

    await tester.drag(find.text('滑动任务'), const Offset(500, 0));
    await _pumpUi(tester);
    expect(
      (await database.timelineTasksDao.findById('gesture-task'))?.isStarred,
      isTrue,
    );

    await tester.drag(find.text('滑动任务'), const Offset(-500, 0));
    await _pumpUi(tester);
    expect((await database.timelineTasksDao.findById('gesture-task')), isNull);

    await _disposeApp(tester);
  });

  testWidgets('timeline edits a task from its row', (tester) async {
    await _seedTask(
      database,
      id: 'edit-task',
      title: '原任务',
      taskDate: DateTime.now(),
    );

    await _pumpApp(tester, database);
    await _openTimeline(tester);

    await tester.tap(find.text('原任务'));
    await _pumpUi(tester);
    expect(find.text('编辑任务'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('timeline-task-title-field')),
      '改任务',
    );
    await tester.tap(find.text('保存任务'));
    await _flushAsyncUi(tester);

    expect(find.text('改任务'), findsOneWidget);
    expect(
      (await database.timelineTasksDao.findById('edit-task'))?.title,
      '改任务',
    );

    await _disposeApp(tester);
  });
}

Future<void> _seedTask(
  AppDatabase database, {
  required String id,
  required String title,
  required DateTime taskDate,
}) {
  final now = DateTime(2026, 5, 27, 9);
  return database.timelineTasksDao.createTask(
    TimelineTaskRowsCompanion.insert(
      id: id,
      title: title,
      description: '',
      taskDate: DateTime(taskDate.year, taskDate.month, taskDate.day),
      startAt: Value(DateTime(taskDate.year, taskDate.month, taskDate.day, 9)),
      endAt: const Value(null),
      importance: TimelineImportance.medium.name,
      colorArgb: TimelineTaskDefaults.mediumColorArgb,
      createdAt: now,
      updatedAt: now,
    ),
  );
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

Future<void> _openTimeline(WidgetTester tester) async {
  await tester.tap(find.text('时间线').last);
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
