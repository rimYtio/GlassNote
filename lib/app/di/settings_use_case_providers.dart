import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings/load_app_settings_use_case.dart';
import '../../application/settings/update_app_settings_use_case.dart';
import '../../infrastructure/providers/infrastructure_providers.dart';

final loadAppSettingsUseCaseProvider = Provider<LoadAppSettingsUseCase>((ref) {
  return LoadAppSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final updateAppSettingsUseCaseProvider = Provider<UpdateAppSettingsUseCase>((
  ref,
) {
  return UpdateAppSettingsUseCase(ref.watch(settingsRepositoryProvider));
});
