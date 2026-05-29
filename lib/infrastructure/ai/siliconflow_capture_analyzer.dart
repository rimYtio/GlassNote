import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../application/capture/capture_draft_preview_parser.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/capture_draft_preview.dart';
import '../../domain/services/capture_analyzer.dart';
import 'capture_prompt.dart';

class SiliconFlowCaptureAnalyzer implements CaptureAnalyzer {
  SiliconFlowCaptureAnalyzer({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  static const _baseUrl = 'https://api.siliconflow.cn/v1';
  static const _defaultModel = 'deepseek-ai/DeepSeek-V3';

  @override
  Future<List<CaptureDraftPreview>> analyze({
    required String transcript,
    required AiConfig config,
    required AiSecrets secrets,
  }) async {
    final now = DateTime.now();
    final dateStr =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    final prompt = buildCapturePrompt(dateStr, timeStr);
    final userMessage = '当前时间：$dateStr $timeStr，语音转写：$transcript';

    final model = config.apiModelName ?? _defaultModel;
    final uri = Uri.parse(_baseUrl).resolve('/chat/completions');
    final response = await _client
        .post(
          uri,
          headers: {
            'Authorization': 'Bearer ${secrets.siliconFlowApiKey}',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'model': model,
            'temperature': config.temperature,
            'response_format': {'type': 'json_object'},
            'messages': [
              {'role': 'system', 'content': prompt},
              {'role': 'user', 'content': userMessage},
            ],
          }),
        )
        .timeout(Duration(seconds: config.timeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('SiliconFlow 分析失败: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final content =
        decoded['choices']?[0]?['message']?['content']?.toString() ?? '[]';
    final previewJson = jsonDecode(content);
    final items = <Map<String, Object?>>[];
    if (previewJson is List) {
      for (final item in previewJson) {
        if (item is Map<String, Object?>) {
          items.add(item);
        }
      }
    } else if (previewJson is Map<String, Object?>) {
      items.add(previewJson);
    }
    if (items.isEmpty) {
      throw StateError('SiliconFlow 返回格式无效');
    }
    return CaptureDraftPreviewParser.parseList(items);
  }
}
