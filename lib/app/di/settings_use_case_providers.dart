import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/settings/export_data_backup_use_case.dart';
import '../../application/settings/import_data_backup_use_case.dart';
import '../../application/settings/load_app_settings_use_case.dart';
import '../../application/settings/update_app_settings_use_case.dart';
import '../../infrastructure/file_system/attachment_file_store.dart';
import '../../infrastructure/providers/infrastructure_providers.dart';

final loadAppSettingsUseCaseProvider = Provider<LoadAppSettingsUseCase>((ref) {
  return LoadAppSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final updateAppSettingsUseCaseProvider = Provider<UpdateAppSettingsUseCase>((
  ref,
) {
  return UpdateAppSettingsUseCase(ref.watch(settingsRepositoryProvider));
});

final exportDataBackupUseCaseProvider = Provider<ExportDataBackupUseCase>((
  ref,
) {
  return ExportDataBackupUseCase(
    database: ref.watch(appDatabaseProvider),
    settingsRepository: ref.watch(settingsRepositoryProvider),
    aiConfigRepository: ref.watch(aiConfigRepositoryProvider),
  );
});

final importDataBackupUseCaseProvider = Provider<ImportDataBackupUseCase>((
  ref,
) {
  return ImportDataBackupUseCase(
    database: ref.watch(appDatabaseProvider),
    attachmentDirectoryProvider:
        const AttachmentFileStore().attachmentsDirectory,
  );
});
