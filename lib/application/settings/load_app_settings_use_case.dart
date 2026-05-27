import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class LoadAppSettingsUseCase {
  const LoadAppSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> call() {
    return _repository.load();
  }
}
