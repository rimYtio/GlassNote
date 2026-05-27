import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/settings_use_case_providers.dart';
import '../../../domain/entities/app_settings.dart';

final settingsControllerProvider =
    AsyncNotifierProvider<SettingsController, AppSettings>(
      SettingsController.new,
    );

class SettingsController extends AsyncNotifier<AppSettings> {
  @override
  Future<AppSettings> build() {
    return ref.watch(loadAppSettingsUseCaseProvider)();
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    final current =
        state.asData?.value ?? await ref.read(loadAppSettingsUseCaseProvider)();
    final updated = current.copyWith(
      themeMode: themeMode,
      updatedAt: DateTime.now(),
    );

    state = AsyncData(updated);
    state = await AsyncValue.guard(
      () => ref.read(updateAppSettingsUseCaseProvider)(updated),
    );
  }
}
