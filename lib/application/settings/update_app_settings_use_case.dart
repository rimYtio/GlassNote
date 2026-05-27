import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class UpdateAppSettingsUseCase {
  const UpdateAppSettingsUseCase(this._repository);

  final SettingsRepository _repository;

  Future<AppSettings> call(AppSettings settings) {
    return _repository.save(settings);
  }
}
