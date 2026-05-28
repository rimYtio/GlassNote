import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_note/app/app.dart';
import 'package:glass_note/domain/entities/ai_config.dart';
import 'package:glass_note/domain/services/ai_connection_tester.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/providers/infrastructure_providers.dart';
import 'package:glass_note/infrastructure/security/in_memory_secure_key_value_store.dart';

void main() {
  late AppDatabase database;
  late InMemorySecureKeyValueStore secrets;
  late _FakeAiConnectionTester connectionTester;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    secrets = InMemorySecureKeyValueStore();
    connectionTester = _FakeAiConnectionTester();
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('API settings saves config and masks secret fields', (
    tester,
  ) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureKeyValueStoreProvider.overrideWithValue(secrets),
          aiConnectionTesterProvider.overrideWithValue(connectionTester),
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
    expect(find.text('API 设置已保存'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('ai-volc-app-key-saved-chip')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ai-volc-access-key-saved-chip')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('ai-deepseek-key-saved-chip')),
      findsOneWidget,
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('API settings tests Volcengine and DeepSeek separately', (
    tester,
  ) async {
    _useTallViewport(tester);
    connectionTester.deepSeekResult = const AiConnectionTestResult.failure(
      'DeepSeek 连接失败: invalid model',
    );
    await secrets.writeSecret(key: 'volc_app_key', value: 'app');
    await secrets.writeSecret(key: 'volc_access_key', value: 'access');
    await secrets.writeSecret(key: 'deepseek_api_key', value: 'deepseek');

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureKeyValueStoreProvider.overrideWithValue(secrets),
          aiConnectionTesterProvider.overrideWithValue(connectionTester),
        ],
        child: const GlassNoteApp(),
      ),
    );
    await _pumpUi(tester);

    await tester.tap(find.text('设置').last);
    await _pumpUi(tester);
    await tester.tap(find.text('API 设置'));
    await _pumpUi(tester);

    await tester.ensureVisible(
      find.byKey(const ValueKey('ai-test-volc-button')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ai-test-volc-button')));
    await _pumpUi(tester);
    expect(connectionTester.volcCalls, 1);
    expect(find.text('火山 ASR 连接成功'), findsWidgets);

    await tester.ensureVisible(
      find.byKey(const ValueKey('ai-test-deepseek-button')),
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('ai-test-deepseek-button')));
    await _pumpUi(tester);
    expect(connectionTester.deepSeekCalls, 1);
    expect(find.textContaining('DeepSeek 连接失败: invalid model'), findsWidgets);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _pumpUi(WidgetTester tester) async {
  for (var i = 0; i < 5; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}

class _FakeAiConnectionTester implements AiConnectionTester {
  AiConnectionTestResult volcResult = const AiConnectionTestResult.success(
    '火山 ASR 连接成功',
  );
  AiConnectionTestResult deepSeekResult = const AiConnectionTestResult.success(
    'DeepSeek 连接成功',
  );
  int volcCalls = 0;
  int deepSeekCalls = 0;

  @override
  Future<AiConnectionTestResult> testVolcAsr({
    required AiConfig config,
    required AiSecrets secrets,
  }) async {
    volcCalls += 1;
    return volcResult;
  }

  @override
  Future<AiConnectionTestResult> testDeepSeek({
    required AiConfig config,
    required AiSecrets secrets,
  }) async {
    deepSeekCalls += 1;
    return deepSeekResult;
  }
}
