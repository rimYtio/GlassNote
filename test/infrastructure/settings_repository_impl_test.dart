import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/domain/entities/app_settings.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/repositories/settings_repository_impl.dart';

void main() {
  late AppDatabase database;
  late SettingsRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = SettingsRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('loads default settings when no row exists', () async {
    final loaded = await repository.load();

    expect(loaded.id, AppSettings.defaultId);
    expect(loaded.themeMode, AppThemeMode.system);
  });

  test('saves and reloads settings from drift', () async {
    final initial = await repository.load();
    final updated = initial.copyWith(
      themeMode: AppThemeMode.dark,
      fontScale: 1.2,
      defaultReminderLeadMinutes: 30,
      hasRequestedStartupPermissions: true,
    );

    await repository.save(updated);
    final reloaded = await repository.load();

    expect(reloaded.themeMode, AppThemeMode.dark);
    expect(reloaded.fontScale, 1.2);
    expect(reloaded.defaultReminderLeadMinutes, 30);
    expect(reloaded.hasRequestedStartupPermissions, isTrue);
    expect(reloaded.id, initial.id);
  });
}
