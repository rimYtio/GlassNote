import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/repositories/ai_config_repository_impl.dart';

void main() {
  late AppDatabase database;
  late AiConfigRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = AiConfigRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('loads defaults then saves non-secret AI config to Drift', () async {
    final defaults = await repository.load();
    expect(defaults.deepSeekModel, 'deepseek-v4-flash');

    final updated = defaults.copyWith(
      volcAsrEndpoint: 'wss://example.com/asr',
      volcAsrResourceId: 'resource-id',
      volcAsrLanguage: 'zh-CN',
      deepSeekBaseUrl: 'https://api.deepseek.com',
      deepSeekModel: 'deepseek-v4-flash',
      temperature: 0.1,
      timeoutSeconds: 30,
      updatedAt: DateTime(2026, 5, 28, 10),
    );

    await repository.save(updated);
    final loaded = await repository.load();

    expect(loaded.volcAsrEndpoint, 'wss://example.com/asr');
    expect(loaded.temperature, 0.1);

    final rows = await database
        .customSelect('select * from ai_config_rows')
        .get();
    final serialized = rows.single.data.values.join(' ');
    expect(serialized, isNot(contains('volc_app_key')));
    expect(serialized, isNot(contains('volc_access_key')));
    expect(serialized, isNot(contains('deepseek_api_key')));
  });
}
