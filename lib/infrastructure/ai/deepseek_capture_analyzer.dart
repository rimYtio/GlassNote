import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../application/capture/capture_draft_preview_parser.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/capture_draft_preview.dart';
import '../../domain/services/capture_analyzer.dart';

class DeepSeekCaptureAnalyzer implements CaptureAnalyzer {
  DeepSeekCaptureAnalyzer({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  @override
  Future<CaptureDraftPreview> analyze({
    required String transcript,
    required AiConfig config,
    required AiSecrets secrets,
  }) async {
    final uri = Uri.parse(config.deepSeekBaseUrl).resolve('/chat/completions');
    final response = await _client
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer ${secrets.deepSeekApiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': config.deepSeekModel,
            'temperature': config.temperature,
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': _systemPrompt},
              {'role': 'user', 'content': transcript},
            ],
          }),
        )
        .timeout(Duration(seconds: config.timeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('DeepSeek 分析失败: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final content =
        decoded['choices']?[0]?['message']?['content']?.toString() ?? '{}';
    final previewJson = jsonDecode(content);
    if (previewJson is! Map<String, Object?>) {
      throw StateError('DeepSeek 返回格式无效');
    }
    return CaptureDraftPreviewParser.parse(previewJson);
  }
}

const _systemPrompt = '''
你是 GlassNote 的捕获分类器。你只能返回一个 JSON object，不要返回 Markdown。
根据用户语音转写内容判断创建 note 或 task。
格式：
{"type":"note","title":"...","content":"...","folderName":null,"task":null}
或：
{"type":"task","title":"...","content":"...","folderName":null,"task":{"date":"YYYY-MM-DD","startTime":"HH:mm","endTime":null,"importance":"low|medium|high"}}
任务必须有明确日期；否则返回 note。
''';
