import '../entities/ai_config.dart';

enum TranscriptionEventType { delta, completed, error }

class TranscriptionEvent {
  const TranscriptionEvent._({required this.type, required this.text});

  const TranscriptionEvent.delta(String text)
    : this._(type: TranscriptionEventType.delta, text: text);

  const TranscriptionEvent.completed(String text)
    : this._(type: TranscriptionEventType.completed, text: text);

  const TranscriptionEvent.error(String text)
    : this._(type: TranscriptionEventType.error, text: text);

  final TranscriptionEventType type;
  final String text;
}

abstract interface class RealtimeTranscriptionClient {
  Stream<TranscriptionEvent> transcribe({
    required Stream<List<int>> audio,
    required AiConfig config,
    required AiSecrets secrets,
  });
}
