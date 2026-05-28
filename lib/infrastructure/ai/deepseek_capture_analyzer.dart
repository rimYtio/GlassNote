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
    final prompt = _buildPrompt(dateStr, timeStr);
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
      throw StateError('DeepSeek 返回格式无效');
    }
    return CaptureDraftPreviewParser.parseList(items);
  }
}

String _buildPrompt(String date, String time) {
  return '''
你是 GlassNote 的捕获分类器。你必须返回一个 JSON 数组，每个元素是一个对象，不要返回 Markdown。
根据用户语音转写内容，分析其中的所有信息点（可能包含多个任务或笔记），为每个信息点创建一个对象。

当前系统日期：$date  当前系统时间：$time
"明天"指 $date 的下一天，"下周X"指下一周的星期X。

每个元素的格式：
{"type":"note","title":"...","content":"...","folderName":null,"task":null}
或：
{"type":"task","title":"...","content":"...","folderName":null,"task":{"date":"YYYY-MM-DD","startTime":"HH:mm","endTime":"HH:mm","importance":"low|medium|high"}}

重要程度 importance 判断规则：
- high：用户语气强烈、有截止日期压力、涉及金钱/健康/工作汇报
- medium：一般待办事项、日常安排
- low：可选事项、长期目标、不紧急

任务必须有明确日期（日期部分必须是具体 YYYY-MM-DD）；否则返回 note。
标题 title 需精炼（≤20 字），内容 content 为完整转写信息。
每个独立事项单独一个元素，即使只有一条也要用数组包裹。
''';
}
