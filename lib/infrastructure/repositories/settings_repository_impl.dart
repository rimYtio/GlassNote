import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../database/app_database.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<AppSettings> load() {
    return _database.settingsDao.loadSettings();
  }

  @override
  Future<AppSettings> save(AppSettings settings) {
    return _database.settingsDao.saveSettings(settings);
  }
}
