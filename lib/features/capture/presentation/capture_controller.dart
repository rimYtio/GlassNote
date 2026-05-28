import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../application/capture/analyze_capture_text_use_case.dart';
import '../../../application/capture/confirm_capture_preview_use_case.dart';
import '../../../application/capture/run_voice_capture_use_case.dart';
import '../../../domain/entities/ai_config.dart';
import '../../../domain/entities/capture_draft_preview.dart';
import '../../../domain/services/realtime_transcription_client.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';

final captureControllerProvider =
    NotifierProvider<CaptureController, CaptureState>(CaptureController.new);

enum CaptureStatus {
  idle,
  recording,
  analyzing,
  preview,
  saving,
  success,
  error,
}

class CaptureState {
  const CaptureState({
    required this.status,
    required this.transcript,
    this.preview,
    this.errorMessage,
  });

  factory CaptureState.initial() {
    return const CaptureState(status: CaptureStatus.idle, transcript: '');
  }

  final CaptureStatus status;
  final String transcript;
  final CaptureDraftPreview? preview;
  final String? errorMessage;

  CaptureState copyWith({
    CaptureStatus? status,
    String? transcript,
    CaptureDraftPreview? preview,
    String? errorMessage,
    bool clearPreview = false,
    bool clearError = false,
  }) {
    return CaptureState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      preview: clearPreview ? null : preview ?? this.preview,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}

class CaptureController extends Notifier<CaptureState> {
  StreamSubscription<TranscriptionEvent>? _subscription;
  Completer<void>? _transcriptionDone;
  String _finalTranscript = '';

  @override
  CaptureState build() {
    ref.onDispose(() {
      _subscription?.cancel();
    });
    return CaptureState.initial();
  }

  Future<void> startRecording() async {
    if (state.status == CaptureStatus.recording) {
      return;
    }
    final config = await ref.read(aiConfigRepositoryProvider).load();
    final secrets = await _loadSecrets();
    if (!secrets.hasCaptureKeys) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: '请先在 API 设置中填写火山引擎和 DeepSeek Key',
        clearPreview: true,
      );
      return;
    }

    final voice = RunVoiceCaptureUseCase(
      ref.read(audioInputServiceProvider),
      ref.read(realtimeTranscriptionClientProvider),
    );
    final granted = await voice.requestPermission();
    if (!granted) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: '未获得麦克风权限',
        clearPreview: true,
      );
      return;
    }

    _finalTranscript = '';
    _transcriptionDone = Completer<void>();
    state = const CaptureState(status: CaptureStatus.recording, transcript: '');
    _subscription = voice
        .start(config: config, secrets: secrets)
        .listen(
          _handleTranscriptionEvent,
          onDone: () {
            if (!(_transcriptionDone?.isCompleted ?? true)) {
              _transcriptionDone?.complete();
            }
          },
          onError: (Object error) {
            if (!(_transcriptionDone?.isCompleted ?? true)) {
              _transcriptionDone?.completeError(error);
            }
          },
        );
  }

  Future<void> stopRecording() async {
    if (state.status != CaptureStatus.recording) {
      return;
    }
    await ref.read(audioInputServiceProvider).stop();
    try {
      await _transcriptionDone?.future.timeout(const Duration(seconds: 2));
    } on Object {
      // Keep the best transcript collected so far.
    }

    final transcript = _finalTranscript.trim().isEmpty
        ? state.transcript.trim()
        : _finalTranscript.trim();
    if (transcript.isEmpty) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: '没有识别到语音内容',
      );
      return;
    }

    state = state.copyWith(
      status: CaptureStatus.analyzing,
      transcript: transcript,
    );
    try {
      final preview =
          await AnalyzeCaptureTextUseCase(ref.read(captureAnalyzerProvider))(
            transcript: transcript,
            config: await ref.read(aiConfigRepositoryProvider).load(),
            secrets: await _loadSecrets(),
          );
      state = state.copyWith(status: CaptureStatus.preview, preview: preview);
    } on Object catch (error) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: 'AI 分析失败: $error',
      );
    }
  }

  Future<void> confirmPreview() async {
    final preview = state.preview;
    if (preview == null) {
      return;
    }
    state = state.copyWith(status: CaptureStatus.saving);
    await ConfirmCapturePreviewUseCase(
      notes: ref.read(noteRepositoryProvider),
      folders: ref.read(folderRepositoryProvider),
      tasks: ref.read(timelineTaskRepositoryProvider),
    )(preview);
    state = CaptureState(
      status: CaptureStatus.success,
      transcript: state.transcript,
    );
  }

  void cancelPreview() {
    state = CaptureState.initial();
  }

  void _handleTranscriptionEvent(TranscriptionEvent event) {
    switch (event.type) {
      case TranscriptionEventType.delta:
        state = state.copyWith(transcript: event.text);
      case TranscriptionEventType.completed:
        _finalTranscript = event.text;
        state = state.copyWith(transcript: event.text);
      case TranscriptionEventType.error:
        state = state.copyWith(
          status: CaptureStatus.error,
          errorMessage: event.text,
        );
    }
  }

  Future<AiSecrets> _loadSecrets() async {
    final store = ref.read(secureKeyValueStoreProvider);
    return AiSecrets(
      volcAppKey: await store.readSecret(AiConfig.volcAppKeySecretKey) ?? '',
      volcAccessKey:
          await store.readSecret(AiConfig.volcAccessKeySecretKey) ?? '',
      deepSeekApiKey:
          await store.readSecret(AiConfig.deepSeekApiKeySecretKey) ?? '',
    );
  }
}
