import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../application/capture/capture_draft_preview_parser.dart';
import '../../domain/entities/ai_config.dart';
import '../../domain/entities/capture_draft_preview.dart';
import '../../domain/services/capture_analyzer.dart';
import 'capture_prompt.dart';

class DeepSeekCaptureAnalyzer implements CaptureAnalyzer {
  DeepSeekCaptureAnalyzer({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

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
              {'role': 'system', 'content': prompt},
              {'role': 'user', 'content': userMessage},
            ],
          }),
        )
        .timeout(Duration(seconds: config.timeoutSeconds));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw StateError('DeepSeek 分析失败: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    final rawContent =
        decoded['choices']?[0]?['message']?['content']?.toString() ?? '[]';
    final List<Map<String, Object?>> items;
    try {
      final previewJson = jsonDecode(rawContent);
      if (previewJson is List) {
        items = previewJson.whereType<Map<String, Object?>>().toList();
      } else if (previewJson is Map<String, Object?>) {
        items = [previewJson];
      } else {
        items = [];
      }
    } on FormatException {
      // DeepSeek returned non-JSON content — use raw transcript as note
      return [
        CaptureDraftPreview.note(
          title: _extractTitle(transcript),
          content: transcript,
        ),
      ];
    }
    if (items.isEmpty) {
      return [
        CaptureDraftPreview.note(
          title: _extractTitle(transcript),
          content: transcript,
        ),
      ];
    }
    return CaptureDraftPreviewParser.parseList(items);
  }

  static String _extractTitle(String transcript) {
    final trimmed = transcript.trim();
    if (trimmed.length <= 20) return trimmed;
    return '${trimmed.substring(0, 20)}…';
  }
}

