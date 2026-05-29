import '../../domain/entities/ai_config.dart';
import '../../domain/entities/capture_draft_preview.dart';
import '../../domain/services/capture_analyzer.dart';

class ProviderSelectingCaptureAnalyzer implements CaptureAnalyzer {
  const ProviderSelectingCaptureAnalyzer({
    required this.deepSeek,
    required this.openAI,
    required this.siliconFlow,
  });

  final CaptureAnalyzer deepSeek;
  final CaptureAnalyzer openAI;
  final CaptureAnalyzer siliconFlow;

  @override
  Future<List<CaptureDraftPreview>> analyze({
    required String transcript,
    required AiConfig config,
    required AiSecrets secrets,
  }) {
    return _analyzerFor(config.providerType).analyze(
      transcript: transcript,
      config: config,
      secrets: secrets,
    );
  }

  CaptureAnalyzer _analyzerFor(AiProviderType type) {
    return switch (type) {
      AiProviderType.deepSeek => deepSeek,
      AiProviderType.openAI => openAI,
      AiProviderType.siliconFlow => siliconFlow,
      AiProviderType.custom => openAI, // Custom uses OpenAI-compatible API
    };
  }
}
