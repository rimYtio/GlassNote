import '../../domain/entities/ai_config.dart';
import '../../domain/services/audio_input_service.dart';
import '../../domain/services/realtime_transcription_client.dart';

class RunVoiceCaptureUseCase {
  const RunVoiceCaptureUseCase(this._audioInput, this._transcription);

  final AudioInputService _audioInput;
  final RealtimeTranscriptionClient _transcription;

  Future<bool> requestPermission() {
    return _audioInput.requestPermission();
  }

  Stream<TranscriptionEvent> start({
    required AiConfig config,
    required AiSecrets secrets,
  }) {
    final audio = _audioInput.startPcm16Stream();
    return _transcription.transcribe(
      audio: audio,
      config: config,
      secrets: secrets,
    );
  }

  Future<void> stop() {
    return _audioInput.stop();
  }
}
