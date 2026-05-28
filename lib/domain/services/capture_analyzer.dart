import '../entities/ai_config.dart';
import '../entities/capture_draft_preview.dart';

abstract interface class CaptureAnalyzer {
  Future<CaptureDraftPreview> analyze({
    required String transcript,
    required AiConfig config,
    required AiSecrets secrets,
  });
}
