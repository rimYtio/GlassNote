import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_note/app/app.dart';
import 'package:glass_note/domain/entities/app_settings.dart';
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

  testWidgets('starts on capture shell and navigates to settings tab', (
    tester,
  ) async {
    await _pumpApp(tester, database);

    expect(find.byKey(const ValueKey('capture-voice-orb')), findsOneWidget);
    expect(find.text('捕获'), findsWidgets);
    expect(find.text('笔记'), findsOneWidget);
    expect(find.text('时间线'), findsOneWidget);
    expect(find.text('设置'), findsOneWidget);

    await tester.tap(find.text('设置').last);
    await _pumpUi(tester);
    expect(find.text('字体设置'), findsOneWidget);
    expect(find.text('API 设置'), findsOneWidget);

    await _disposeApp(tester);
  });

  testWidgets('settings page persists theme mode through Riverpod and Drift', (
    tester,
  ) async {
    await _pumpApp(tester, database);

    await tester.tap(find.text('设置').last);
    await _pumpUi(tester);
    await tester.tap(find.text('Dark'));
    await _pumpUi(tester);

    final stored = await database.settingsDao.loadSettings();
    expect(stored.themeMode, AppThemeMode.dark);
    expect(find.byType(MaterialApp), findsOneWidget);

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

Future<void> _pumpUi(WidgetTester tester) async {
  for (var i = 0; i < 5; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<void> _disposeApp(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 1));
  await tester.pump(const Duration(milliseconds: 1));
}
