import '../../domain/entities/ai_config.dart';
import '../../domain/entities/capture_draft_preview.dart';
import '../../domain/services/capture_analyzer.dart';

class AnalyzeCaptureTextUseCase {
  const AnalyzeCaptureTextUseCase(this._analyzer);

  final CaptureAnalyzer _analyzer;

  Future<CaptureDraftPreview> call({
    required String transcript,
    required AiConfig config,
    required AiSecrets secrets,
  }) {
    return _analyzer.analyze(
      transcript: transcript,
      config: config,
      secrets: secrets,
    );
  }
}
