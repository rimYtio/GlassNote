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

enum CaptureErrorType {
  configuration,
  permission,
  transcription,
  emptyTranscript,
  analysis,
}

class CaptureState {
  const CaptureState({
    required this.status,
    required this.transcript,
    this.previews = const [],
    this.errorMessage,
    this.errorType,
  });

  factory CaptureState.initial() {
    return const CaptureState(status: CaptureStatus.idle, transcript: '');
  }

  final CaptureStatus status;
  final String transcript;
  final List<CaptureDraftPreview> previews;
  final String? errorMessage;
  final CaptureErrorType? errorType;

  CaptureState copyWith({
    CaptureStatus? status,
    String? transcript,
    List<CaptureDraftPreview>? previews,
    String? errorMessage,
    CaptureErrorType? errorType,
    bool clearPreviews = false,
    bool clearError = false,
  }) {
    return CaptureState(
      status: status ?? this.status,
      transcript: transcript ?? this.transcript,
      previews: clearPreviews ? const [] : previews ?? this.previews,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      errorType: clearError ? null : errorType ?? this.errorType,
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
    _finalTranscript = '';
    _transcriptionDone = Completer<void>();
    state = const CaptureState(status: CaptureStatus.recording, transcript: '');
    try {
      final config = await ref.read(aiConfigRepositoryProvider).load();
      final secrets = await _loadSecrets();
      if (!secrets.hasCaptureKeys) {
        state = state.copyWith(
          status: CaptureStatus.error,
          errorMessage: '请先在 API 设置中填写火山引擎和 DeepSeek Key',
          errorType: CaptureErrorType.configuration,
          clearPreviews: true,
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
          errorType: CaptureErrorType.permission,
          clearPreviews: true,
        );
        return;
      }

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
    } on Object catch (error) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: '启动录音失败: $error',
        errorType: CaptureErrorType.transcription,
      );
    }
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
    final subscription = _subscription;
    _subscription = null;
    _transcriptionDone = null;
    if (subscription != null) {
      unawaited(subscription.cancel().catchError((_) {}));
    }
    if (transcript.isEmpty) {
      state = state.copyWith(status: CaptureStatus.idle, clearError: true);
      return;
    }

    state = state.copyWith(
      status: CaptureStatus.analyzing,
      transcript: transcript,
      clearError: true,
    );
    try {
      final previews =
          await AnalyzeCaptureTextUseCase(ref.read(captureAnalyzerProvider))(
            transcript: transcript,
            config: await ref.read(aiConfigRepositoryProvider).load(),
            secrets: await _loadSecrets(),
          );
      state = state.copyWith(status: CaptureStatus.preview, previews: previews);
    } on Object catch (error) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: 'AI 分析失败: $error',
        errorType: CaptureErrorType.analysis,
      );
    }
  }

  Future<void> confirmPreview() async {
    if (state.previews.isEmpty) {
      return;
    }
    state = state.copyWith(status: CaptureStatus.saving);
    try {
      await ConfirmCapturePreviewUseCase(
        notes: ref.read(noteRepositoryProvider),
        folders: ref.read(folderRepositoryProvider),
        tasks: ref.read(timelineTaskRepositoryProvider),
      )(state.previews);
      state = CaptureState(
        status: CaptureStatus.success,
        transcript: state.transcript,
      );
    } on Object catch (error) {
      state = state.copyWith(
        status: CaptureStatus.error,
        errorMessage: '创建失败: $error',
        errorType: CaptureErrorType.analysis,
      );
    }
  }

  void cancelPreview() {
    state = CaptureState.initial();
  }

  void clearConfigurationError() {
    if (state.status == CaptureStatus.error &&
        state.errorType == CaptureErrorType.configuration) {
      state = CaptureState.initial();
    }
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
          errorType: CaptureErrorType.transcription,
        );
    }
  }

  Future<AiSecrets> _loadSecrets() async {
    return ref.read(aiSecretsProvider.future);
  }
}
