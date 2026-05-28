import '../entities/ai_config.dart';

abstract interface class AiConfigRepository {
  Future<AiConfig> load();

  Future<AiConfig> save(AiConfig config);
}
