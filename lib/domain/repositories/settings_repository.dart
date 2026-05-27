import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<AppSettings> load();

  Future<AppSettings> save(AppSettings settings);
}
