import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/ai_config_repository.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/timeline_task_repository.dart';
import '../../domain/services/audio_input_service.dart';
import '../../domain/services/capture_analyzer.dart';
import '../../domain/services/data_protection_service.dart';
import '../../domain/services/realtime_transcription_client.dart';
import '../ai/deepseek_capture_analyzer.dart';
import '../ai/volcengine_streaming_asr_client.dart';
import '../audio/record_audio_input_service.dart';
import '../database/app_database.dart';
import '../repositories/ai_config_repository_impl.dart';
import '../repositories/folder_repository_impl.dart';
import '../repositories/note_repository_impl.dart';
import '../repositories/settings_repository_impl.dart';
import '../repositories/timeline_task_repository_impl.dart';
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

final audioInputServiceProvider = Provider<AudioInputService>((ref) {
  return RecordAudioInputService();
});

final realtimeTranscriptionClientProvider =
    Provider<RealtimeTranscriptionClient>((ref) {
      return VolcengineStreamingAsrClient();
    });

final captureAnalyzerProvider = Provider<CaptureAnalyzer>((ref) {
  return DeepSeekCaptureAnalyzer();
});

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepositoryImpl(ref.watch(appDatabaseProvider));
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(ref.watch(appDatabaseProvider));
});

final timelineTaskRepositoryProvider = Provider<TimelineTaskRepository>((ref) {
  return TimelineTaskRepositoryImpl(ref.watch(appDatabaseProvider));
});
