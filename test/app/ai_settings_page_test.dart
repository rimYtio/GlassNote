import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_note/app/app.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/providers/infrastructure_providers.dart';
import 'package:glass_note/infrastructure/security/in_memory_secure_key_value_store.dart';

void main() {
  late AppDatabase database;
  late InMemorySecureKeyValueStore secrets;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    secrets = InMemorySecureKeyValueStore();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('API settings saves config and masks secret fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureKeyValueStoreProvider.overrideWithValue(secrets),
        ],
        child: const GlassNoteApp(),
      ),
    );
    await _pumpUi(tester);

    await tester.tap(find.text('设置').last);
    await _pumpUi(tester);
    await tester.tap(find.text('API 设置'));
    await _pumpUi(tester);

    await tester.enterText(
      find.byKey(const ValueKey('ai-volc-app-key-field')),
      'volc-app-secret',
    );
    await tester.enterText(
      find.byKey(const ValueKey('ai-volc-access-key-field')),
      'volc-access-secret',
    );
    await tester.enterText(
      find.byKey(const ValueKey('ai-deepseek-key-field')),
      'deepseek-secret',
    );
    await tester.enterText(
      find.byKey(const ValueKey('ai-deepseek-model-field')),
      'deepseek-v4-flash',
    );
    await tester.tap(find.text('保存 API 设置'));
    await _pumpUi(tester);

    expect(await secrets.readSecret('volc_app_key'), 'volc-app-secret');
    expect(await secrets.readSecret('volc_access_key'), 'volc-access-secret');
    expect(await secrets.readSecret('deepseek_api_key'), 'deepseek-secret');
    expect(find.text('volc-app-secret'), findsNothing);
    expect(find.text('volc-access-secret'), findsNothing);
    expect(find.text('deepseek-secret'), findsNothing);
    expect(find.text('已保存'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _pumpUi(WidgetTester tester) async {
  for (var i = 0; i < 5; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
