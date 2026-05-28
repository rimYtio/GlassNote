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
    expect(find.text(_ordinalDay(DateTime.now().day)), findsNothing);
    expect(
      (await database.timelineTasksDao.search('项目')).single.title,
      '完成项目计划',
    );

    await _disposeApp(tester);
  });

  testWidgets(
    'timeline searches all active tasks from a glass search overlay',
    (tester) async {
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
      try {
        await _openTimeline(tester);

        await tester.tap(find.byTooltip('搜索任务'));
        await _pumpUi(tester);
        expect(
          find.byKey(const ValueKey('timeline-search-overlay')),
          findsOneWidget,
        );
        expect(find.byType(AlertDialog), findsNothing);

        await tester.enterText(
          find.byKey(const ValueKey('timeline-search-overlay-field')),
          '未来',
        );
        await _flushAsyncUi(tester);
        expect(find.text('未来会议'), findsNothing);

        await tester.tap(find.byKey(const ValueKey('timeline-search-submit')));
        await _flushAsyncUi(tester);

        final results = find.byKey(const ValueKey('timeline-search-results'));
        expect(
          find.descendant(of: results, matching: find.text('未来会议')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: results, matching: find.text('今天汇报')),
          findsNothing,
        );

        await tester.tapAt(const Offset(8, 8));
        await _pumpUi(tester);
        expect(
          find.byKey(const ValueKey('timeline-search-overlay')),
          findsNothing,
        );
      } finally {
        await _disposeApp(tester);
      }
    },
  );

  testWidgets('timeline search supports dates and jumps to the selected task', (
    tester,
  ) async {
    final targetDate = DateTime(2026, 2, 23);
    await _seedTask(
      database,
      id: 'date-search-task',
      title: '日期搜索任务',
      taskDate: targetDate,
    );

    await _pumpApp(tester, database);
    try {
      await _openTimeline(tester);

      await tester.tap(find.byTooltip('搜索任务'));
      await _pumpUi(tester);
      await tester.enterText(
        find.byKey(const ValueKey('timeline-search-overlay-field')),
        '2026.2.23',
      );
      await tester.tap(find.byKey(const ValueKey('timeline-search-submit')));
      await _flushAsyncUi(tester);

      final results = find.byKey(const ValueKey('timeline-search-results'));
      expect(
        find.descendant(of: results, matching: find.text('日期搜索任务')),
        findsOneWidget,
      );

      await tester.tap(find.text('日期搜索任务'));
      await _pumpUi(tester);

      expect(
        find.byKey(const ValueKey('timeline-search-overlay')),
        findsNothing,
      );
      expect(find.byKey(ValueKey(_daySectionKey(targetDate))), findsOneWidget);
      expect(find.text('日期搜索任务'), findsOneWidget);
    } finally {
      await _disposeApp(tester);
    }
  });

  testWidgets('timeline search overlay blurs background', (tester) async {
    await _pumpApp(tester, database);
    try {
      await _openTimeline(tester);

      await tester.tap(find.byTooltip('搜索任务'));
      await _pumpUi(tester);

      expect(
        find.byKey(const ValueKey('timeline-search-backdrop')),
        findsOneWidget,
      );
    } finally {
      await _disposeApp(tester);
    }
  });

  testWidgets('timeline task row stretches color rail with long content', (
    tester,
  ) async {
    await _seedTask(
      database,
      id: 'long-task',
      title: '很长的任务标题用于验证任务行布局不会在中间留下大块空白',
      description: '第一行摘要内容比较长\n第二行摘要继续撑高任务条',
      taskDate: DateTime.now(),
    );

    await _pumpApp(tester, database);
    try {
      await _openTimeline(tester);

      final tile = find.byKey(const ValueKey('timeline-task-long-task'));
      final rail = find.byKey(
        const ValueKey('timeline-task-color-rail-long-task'),
      );
      final content = find.byKey(
        const ValueKey('timeline-task-content-long-task'),
      );

      expect(tile, findsOneWidget);
      expect(rail, findsOneWidget);
      expect(content, findsOneWidget);
      expect(tester.getSize(rail).height, greaterThan(60));
      expect(
        (tester.getSize(rail).height - tester.getSize(content).height).abs(),
        lessThan(4),
      );
      expect(tester.getSize(content).width, greaterThan(250));
      expect(
        tester.getTopLeft(find.byType(Checkbox).first).dx,
        greaterThan(430),
      );
    } finally {
      await _disposeApp(tester);
    }
  });

  testWidgets('timeline add task button is liquid glass', (tester) async {
    await _pumpApp(tester, database);
    try {
      await _openTimeline(tester);

      final fab = find.byKey(const ValueKey('timeline-glass-fab'));
      expect(fab, findsOneWidget);

      final surface = tester.widget<DecoratedBox>(
        find.byKey(const ValueKey('timeline-glass-fab-surface')),
      );
      final decoration = surface.decoration as BoxDecoration;
      expect(decoration.color?.a, lessThan(0.5));
    } finally {
      await _disposeApp(tester);
    }
  });

  testWidgets('timeline date sections are continuous and use day-only labels', (
    tester,
  ) async {
    final today = DateTime.now();
    final twoDaysAgo = today.subtract(const Duration(days: 2));
    final yesterday = today.subtract(const Duration(days: 1));

    await _pumpApp(tester, database);
    try {
      await _openTimeline(tester);

      final twoDaysAgoSection = find.byKey(
        ValueKey(_daySectionKey(twoDaysAgo)),
      );
      final yesterdaySection = find.byKey(ValueKey(_daySectionKey(yesterday)));
      final todaySection = find.byKey(ValueKey(_daySectionKey(today)));

      await _dragTimelineUntilVisible(
        tester,
        twoDaysAgoSection,
        const Offset(0, 360),
        maxIterations: 4,
      );

      expect(twoDaysAgoSection, findsOneWidget);
      expect(yesterdaySection, findsOneWidget);
      expect(todaySection, findsOneWidget);
      expect(find.text(_dateLabel(twoDaysAgo)), findsNothing);
      expect(find.text(_ordinalDay(twoDaysAgo.day)), findsOneWidget);

      final twoDaysAgoTop = tester.getTopLeft(twoDaysAgoSection).dy;
      final yesterdayTop = tester.getTopLeft(yesterdaySection).dy;
      final todayTop = tester.getTopLeft(todaySection).dy;

      expect(twoDaysAgoTop, lessThan(yesterdayTop));
      expect(yesterdayTop, lessThan(todayTop));
    } finally {
      await _disposeApp(tester);
    }
  });

  testWidgets(
    'timeline scroll lazily reaches dates outside the initial window',
    (tester) async {
      final today = DateTime.now();
      final pastDate = today.subtract(const Duration(days: 45));
      final futureDate = today.add(const Duration(days: 45));

      await _pumpApp(tester, database);
      try {
        await _openTimeline(tester);

        await _dragTimelineUntilVisible(
          tester,
          find.byKey(ValueKey(_daySectionKey(pastDate))),
          const Offset(0, 220),
          maxIterations: 60,
        );
        expect(find.byKey(ValueKey(_daySectionKey(pastDate))), findsOneWidget);

        await _dragTimelineUntilVisible(
          tester,
          find.byKey(ValueKey(_daySectionKey(futureDate))),
          const Offset(0, -220),
          maxIterations: 90,
        );
        expect(
          find.byKey(ValueKey(_daySectionKey(futureDate))),
          findsOneWidget,
        );
      } finally {
        await _disposeApp(tester);
      }
    },
  );

  testWidgets('timeline uses bouncing vertical scroll physics', (tester) async {
    await _pumpApp(tester, database);
    await _openTimeline(tester);

    final scrollView = tester.widget<CustomScrollView>(
      find.byKey(const ValueKey('timeline-scroll-view')),
    );

    expect(scrollView.physics, isA<BouncingScrollPhysics>());
    expect(
      (scrollView.physics! as BouncingScrollPhysics).parent,
      isA<AlwaysScrollableScrollPhysics>(),
    );

    await _disposeApp(tester);
  });

  testWidgets('timeline calendar shows heat counts and selects a date', (
    tester,
  ) async {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, now.day);
    await _seedTask(
      database,
      id: 'calendar-task',
      title: '跨月任务',
      taskDate: target,
    );

    await _pumpApp(tester, database);
    await _openTimeline(tester);

    expect(find.byTooltip('查看任务日历'), findsOneWidget);
    await tester.tap(find.byTooltip('查看任务日历'));
    await _pumpUi(tester);

    expect(
      find.byKey(const ValueKey('timeline-calendar-dialog')),
      findsOneWidget,
    );
    expect(
      find.descendant(
        of: find.byKey(ValueKey('timeline-calendar-month-${target.month}')),
        matching: find.text('1'),
      ),
      findsOneWidget,
    );

    expect(
      find.descendant(
        of: find.byKey(ValueKey('timeline-calendar-day-${target.day}')),
        matching: find.text('1 项'),
      ),
      findsOneWidget,
    );

    final dayCell = find.byKey(ValueKey('timeline-calendar-day-${target.day}'));
    await tester.ensureVisible(dayCell);
    await tester.tap(dayCell);
    await _pumpUi(tester);

    expect(find.text('跨月任务'), findsOneWidget);

    await _disposeApp(tester);
  });

  testWidgets('timeline calendar keeps year and grid dimensions stable', (
    tester,
  ) async {
    await _pumpApp(tester, database);
    await _openTimeline(tester);

    await tester.tap(find.byTooltip('查看任务日历'));
    await _pumpUi(tester);

    final surface = find.byKey(const ValueKey('timeline-calendar-surface'));
    final grid = find.byKey(const ValueKey('timeline-calendar-month-grid'));
    final january = find.byKey(const ValueKey('timeline-calendar-month-1'));
    final bottomNavigation = find.byKey(
      const ValueKey('glass-bottom-navigation-surface'),
    );
    final initialDialogSize = tester.getSize(surface);
    final initialGridSize = tester.getSize(grid);
    final initialMonthSize = tester.getSize(january);
    expect(
      tester.getBottomLeft(surface).dy,
      lessThanOrEqualTo(tester.getTopLeft(bottomNavigation).dy - 8),
    );

    await tester.tap(find.byTooltip('下一年'));
    await _pumpUi(tester);
    expect(tester.getSize(surface), initialDialogSize);
    expect(tester.getSize(grid), initialGridSize);
    expect(tester.getSize(january), initialMonthSize);

    await tester.tap(find.byTooltip('下一年'));
    await _pumpUi(tester);
    expect(tester.getSize(surface), initialDialogSize);
    expect(tester.getSize(grid), initialGridSize);
    expect(tester.getSize(january), initialMonthSize);

    await _disposeApp(tester);
  });

  testWidgets('timeline scroll shows year month overlay then hides it', (
    tester,
  ) async {
    await _pumpApp(tester, database);
    await _openTimeline(tester);

    await tester.drag(
      find.byKey(const ValueKey('timeline-scroll-view')),
      const Offset(0, -360),
    );
    await tester.pump();

    expect(find.byKey(const ValueKey('timeline-date-overlay')), findsOneWidget);
    expect(find.text('${DateTime.now().year}'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const ValueKey('timeline-date-overlay')), findsNothing);

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
  String description = '',
}) {
  final now = DateTime(2026, 5, 27, 9);
  return database.timelineTasksDao.createTask(
    TimelineTaskRowsCompanion.insert(
      id: id,
      title: title,
      description: description,
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

Future<void> _dragTimelineUntilVisible(
  WidgetTester tester,
  Finder finder,
  Offset offset, {
  int maxIterations = 12,
}) async {
  final scrollable = find.byKey(const ValueKey('timeline-scroll-view'));
  for (var i = 0; i < maxIterations && finder.evaluate().isEmpty; i += 1) {
    await tester.drag(scrollable, offset);
    await _pumpUi(tester);
  }
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 1));
}

String _ordinalDay(int day) {
  if (day % 100 >= 11 && day % 100 <= 13) {
    return '${day}th';
  }
  final suffix = switch (day % 10) {
    1 => 'st',
    2 => 'nd',
    3 => 'rd',
    _ => 'th',
  };
  return '$day$suffix';
}

String _dateLabel(DateTime value) {
  return '${value.year}/${value.month}/${value.day}';
}

String _daySectionKey(DateTime value) {
  return 'timeline-day-${value.year}-${value.month}-${value.day}';
}
