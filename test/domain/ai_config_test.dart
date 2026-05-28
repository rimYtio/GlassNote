import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/domain/entities/ai_config.dart';

void main() {
  test('creates default AI config for Volcengine ASR and DeepSeek', () {
    final now = DateTime(2026, 5, 28, 9);
    final config = AiConfig.defaults(now: now);

    expect(
      config.volcAsrEndpoint,
      'wss://openspeech.bytedance.com/api/v3/sauc/bigmodel_async',
    );
    expect(config.volcAsrResourceId, 'volc.seedasr.sauc.duration');
    expect(config.volcAsrLanguage, 'zh-CN');
    expect(config.deepSeekBaseUrl, 'https://api.deepseek.com');
    expect(config.deepSeekModel, 'deepseek-v4-flash');
    expect(config.temperature, 0.2);
    expect(config.timeoutSeconds, 45);
    expect(config.updatedAt, now);
  });
}
