import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/application/settings/load_app_settings_use_case.dart';
import 'package:glass_note/application/settings/update_app_settings_use_case.dart';
import 'package:glass_note/domain/entities/app_settings.dart';
import 'package:glass_note/domain/repositories/settings_repository.dart';

void main() {
  test('load app settings use case reads through the repository', () async {
    final settings = AppSettings.defaults(now: DateTime(2026, 5, 27, 9));
    final repository = _FakeSettingsRepository(settings);
    final useCase = LoadAppSettingsUseCase(repository);

    final loaded = await useCase();

    expect(loaded, settings);
  });

  test(
    'update app settings use case persists through the repository',
    () async {
      final initial = AppSettings.defaults(now: DateTime(2026, 5, 27, 9));
      final repository = _FakeSettingsRepository(initial);
      final useCase = UpdateAppSettingsUseCase(repository);
      final updated = initial.copyWith(themeMode: AppThemeMode.dark);

      final saved = await useCase(updated);

      expect(saved.themeMode, AppThemeMode.dark);
      expect(repository.savedSettings, updated);
    },
  );
}

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._settings);

  AppSettings _settings;
  AppSettings? savedSettings;

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<AppSettings> save(AppSettings settings) async {
    savedSettings = settings;
    _settings = settings;
    return settings;
  }
}
