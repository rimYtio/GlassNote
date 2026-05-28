import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../domain/entities/ai_config.dart';
import '../../domain/services/ai_connection_tester.dart';
import '../../domain/services/realtime_transcription_client.dart';
import 'volcengine_streaming_asr_client.dart';

class NetworkAiConnectionTester implements AiConnectionTester {
  NetworkAiConnectionTester({
    WebSocketConnector? volcConnector,
    http.Client? httpClient,
  }) : _volcConnector = volcConnector ?? defaultVolcengineConnector,
       _httpClient = httpClient ?? http.Client();

  final WebSocketConnector _volcConnector;
  final http.Client _httpClient;

  @override
  Future<AiConnectionTestResult> testVolcAsr({
    required AiConfig config,
    required AiSecrets secrets,
  }) async {
    if (secrets.volcAppKey.trim().isEmpty ||
        secrets.volcAccessKey.trim().isEmpty) {
      return const AiConnectionTestResult.failure('火山 ASR 连接失败: Key 未填写');
    }
    try {
      final channel = await _volcConnector(config, secrets);
      try {
        await channel.ready.timeout(_shortTimeout(config));
        channel.sink.add(
          buildVolcengineFullClientRequest(config, const Uuid().v4()),
        );
        channel.sink.add(buildVolcengineAudioRequest(const [], isLast: true));
        final message = await channel.stream.first.timeout(
          const Duration(seconds: 3),
        );
        final event = decodeVolcengineServerMessage(message);
        if (event.type == TranscriptionEventType.error) {
          return AiConnectionTestResult.failure('火山 ASR 连接失败: ${event.text}');
        }
        return const AiConnectionTestResult.success('火山 ASR 连接成功');
      } on TimeoutException {
        return const AiConnectionTestResult.success('火山 ASR 连接成功');
      } on StateError {
        return const AiConnectionTestResult.success('火山 ASR 连接成功');
      } finally {
        unawaited(channel.sink.close());
      }
    } on Object catch (error) {
      return AiConnectionTestResult.failure('火山 ASR 连接失败: $error');
    }
  }

  @override
  Future<AiConnectionTestResult> testDeepSeek({
    required AiConfig config,
    required AiSecrets secrets,
  }) async {
    if (secrets.deepSeekApiKey.trim().isEmpty) {
      return const AiConnectionTestResult.failure('DeepSeek 连接失败: API Key 未填写');
    }
    try {
      final uri = Uri.parse(
        config.deepSeekBaseUrl,
      ).resolve('/v1/chat/completions');
      final response = await _httpClient
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer ${secrets.deepSeekApiKey}',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': config.deepSeekModel,
              'temperature': 0,
              'max_tokens': 8,
              'messages': [
                {'role': 'user', 'content': 'ping'},
              ],
            }),
          )
          .timeout(_shortTimeout(config));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return AiConnectionTestResult.failure(
          'DeepSeek 连接失败: ${response.statusCode} ${_snippet(response.body)}',
        );
      }
      final decoded = jsonDecode(response.body);
      if (decoded is Map &&
          decoded['choices'] is List &&
          (decoded['choices'] as List).isNotEmpty) {
        return const AiConnectionTestResult.success('DeepSeek 连接成功');
      }
      return const AiConnectionTestResult.failure('DeepSeek 连接失败: 返回格式无效');
    } on TimeoutException {
      return const AiConnectionTestResult.failure('DeepSeek 连接失败: 请求超时');
    } on Object catch (error) {
      return AiConnectionTestResult.failure('DeepSeek 连接失败: $error');
    }
  }

  Duration _shortTimeout(AiConfig config) {
    final configured = config.timeoutSeconds;
    final seconds = configured < 1
        ? 1
        : configured > 15
        ? 15
        : configured;
    return Duration(seconds: seconds);
  }

  String _snippet(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= 80) {
      return trimmed;
    }
    return trimmed.substring(0, 80);
  }
}
