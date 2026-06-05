import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ai_config.dart';
import '../../domain/repositories/ai_config_repository.dart';
import '../../domain/repositories/attachment_repository.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import '../../domain/repositories/timeline_task_repository.dart';
import '../../domain/services/startup_permission_service.dart';
import '../../domain/services/ai_connection_tester.dart';
import '../../domain/services/audio_input_service.dart';
import '../../domain/services/capture_analyzer.dart';
import '../../domain/services/data_protection_service.dart';
import '../../domain/services/realtime_transcription_client.dart';
import '../../application/settings/startup_permission_service_impl.dart';
import '../ai/deepseek_capture_analyzer.dart';
import '../ai/openai_capture_analyzer.dart';
import '../ai/siliconflow_capture_analyzer.dart';
import '../ai/provider_selecting_capture_analyzer.dart';
import '../ai/network_ai_connection_tester.dart';
import '../ai/volcengine_streaming_asr_client.dart';
import '../audio/record_audio_input_service.dart';
import '../database/app_database.dart';
import '../file_system/attachment_file_store.dart';
import '../notifications/local_notification_service.dart';
import '../repositories/ai_config_repository_impl.dart';
import '../repositories/attachment_repository_impl.dart';
import '../repositories/folder_repository_impl.dart';
import '../repositories/note_repository_impl.dart';
import '../repositories/reminder_repository_impl.dart';
import '../repositories/settings_repository_impl.dart';
import '../repositories/tag_repository_impl.dart';
import '../repositories/timeline_task_repository_impl.dart';
import '../security/app_lock_service.dart';
import '../security/flutter_secure_key_value_store.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(appDatabaseProvider));
});

final aiConfigRepositoryProvider = Provider<AiConfigRepository>((ref) {
  return AiConfigRepositoryImpl(ref.watch(appDatabaseProvider));
});

final secureKeyValueStoreProvider = Provider<SecureKeyValueStore>((ref) {
  return FlutterSecureKeyValueStore();
});

final aiSecretsProvider = FutureProvider<AiSecrets>((ref) async {
  final store = ref.watch(secureKeyValueStoreProvider);
  return AiSecrets(
    volcAppKey: await store.readSecret(AiConfig.volcAppKeySecretKey) ?? '',
    volcAccessKey:
        await store.readSecret(AiConfig.volcAccessKeySecretKey) ?? '',
    deepSeekApiKey:
        await store.readSecret(AiConfig.deepSeekApiKeySecretKey) ?? '',
    openAIApiKey: await store.readSecret(AiConfig.openAIApiKeySecretKey) ?? '',
    siliconFlowApiKey:
        await store.readSecret(AiConfig.siliconFlowApiKeySecretKey) ?? '',
  );
});

final aiConnectionTesterProvider = Provider<AiConnectionTester>((ref) {
  return NetworkAiConnectionTester();
});

final audioInputServiceProvider = Provider<AudioInputService>((ref) {
  return RecordAudioInputService();
});

final realtimeTranscriptionClientProvider =
    Provider<RealtimeTranscriptionClient>((ref) {
      return VolcengineStreamingAsrClient();
    });

final captureAnalyzerProvider = Provider<CaptureAnalyzer>((ref) {
  return ProviderSelectingCaptureAnalyzer(
    deepSeek: DeepSeekCaptureAnalyzer(),
    openAI: OpenAICaptureAnalyzer(),
    siliconFlow: SiliconFlowCaptureAnalyzer(),
  );
});

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepositoryImpl(ref.watch(appDatabaseProvider));
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(
    ref.watch(appDatabaseProvider),
    fileStore: ref.watch(attachmentFileStoreProvider),
  );
});

final timelineTaskRepositoryProvider = Provider<TimelineTaskRepository>((ref) {
  return TimelineTaskRepositoryImpl(ref.watch(appDatabaseProvider));
});

final attachmentRepositoryProvider = Provider<AttachmentRepository>((ref) {
  return AttachmentRepositoryImpl(ref.watch(appDatabaseProvider));
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  return TagRepositoryImpl(ref.watch(appDatabaseProvider));
});

final attachmentFileStoreProvider = Provider<AttachmentFileStore>((ref) {
  return const AttachmentFileStore();
});

final appLockServiceProvider = Provider<AppLockService>((ref) {
  return AppLockService(
    settingsRepository: ref.watch(settingsRepositoryProvider),
    secureStore: ref.watch(secureKeyValueStoreProvider),
  );
});

final startupPermissionServiceProvider = Provider<StartupPermissionService>((
  ref,
) {
  return StartupPermissionServiceImpl(
    settingsRepository: ref.watch(settingsRepositoryProvider),
    notificationPermissions: ref.watch(localNotificationServiceProvider),
    audioInput: ref.watch(audioInputServiceProvider),
  );
});

final localNotificationServiceProvider = Provider<LocalNotificationService>((
  ref,
) {
  throw UnimplementedError(
    'localNotificationServiceProvider must be overridden in bootstrap',
  );
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  LocalNotificationService? notificationService;
  try {
    notificationService = ref.watch(localNotificationServiceProvider);
  } on Object {
    notificationService = null;
  }
  return ReminderRepositoryImpl(
    database: ref.watch(appDatabaseProvider),
    notificationService: notificationService,
  );
});
