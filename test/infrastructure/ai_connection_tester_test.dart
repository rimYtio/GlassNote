import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/domain/entities/ai_config.dart';
import 'package:glass_note/domain/services/ai_connection_tester.dart';
import 'package:glass_note/infrastructure/ai/network_ai_connection_tester.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  final config = AiConfig.defaults(now: DateTime(2026));
  const secrets = AiSecrets(
    volcAppKey: 'volc-app',
    volcAccessKey: 'volc-access',
    deepSeekApiKey: 'deepseek-key',
  );

  test(
    'DeepSeek connection test sends ping with configured model and key',
    () async {
      http.Request? captured;
      final tester = NetworkAiConnectionTester(
        httpClient: MockClient((request) async {
          captured = request;
          return http.Response(
            jsonEncode({
              'choices': [
                {
                  'message': {'content': 'ok'},
                },
              ],
            }),
            200,
          );
        }),
      );

      final result = await tester.testDeepSeek(
        config: config,
        secrets: secrets,
      );
      final body = jsonDecode(captured!.body) as Map<String, Object?>;

      expect(result, const AiConnectionTestResult.success('DeepSeek 连接成功'));
      expect(
        captured!.url.toString(),
        'https://api.deepseek.com/chat/completions',
      );
      expect(captured!.headers['Authorization'], 'Bearer deepseek-key');
      expect(body['model'], 'deepseek-v4-flash');
      expect(body['max_tokens'], 8);
    },
  );

  test('DeepSeek connection test reports non-success response', () async {
    final tester = NetworkAiConnectionTester(
      httpClient: MockClient((request) async {
        return http.Response('invalid model', 400);
      }),
    );

    final result = await tester.testDeepSeek(config: config, secrets: secrets);

    expect(result.success, isFalse);
    expect(result.message, contains('DeepSeek 连接失败: 400'));
  });

  test('Volcengine ASR connection test sends setup packets', () async {
    _FakeWebSocketChannel? channel;
    final tester = NetworkAiConnectionTester(
      volcConnector: (config, secrets) async {
        channel = _FakeWebSocketChannel(
          Stream<Object>.value(
            utf8.encode(
              jsonEncode({
                'result': {'text': 'ok', 'definite': true},
              }),
            ),
          ),
        );
        return channel!;
      },
    );

    final result = await tester.testVolcAsr(config: config, secrets: secrets);

    expect(result, const AiConnectionTestResult.success('火山 ASR 连接成功'));
    expect(channel!.sink.sent, hasLength(greaterThanOrEqualTo(2)));
  });

  test('Volcengine ASR connection test reports service errors', () async {
    final tester = NetworkAiConnectionTester(
      volcConnector: (config, secrets) async {
        return _FakeWebSocketChannel(
          Stream<Object>.value(
            utf8.encode(jsonEncode({'code': 401, 'message': 'invalid token'})),
          ),
        );
      },
    );

    final result = await tester.testVolcAsr(config: config, secrets: secrets);

    expect(result.success, isFalse);
    expect(result.message, contains('invalid token'));
  });
}

class _FakeWebSocketChannel implements WebSocketChannel {
  _FakeWebSocketChannel(this.stream);

  @override
  final Stream<Object> stream;

  @override
  final _FakeWebSocketSink sink = _FakeWebSocketSink();

  @override
  int? get closeCode => null;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  @override
  Future<void> get ready => Future.value();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeWebSocketSink implements WebSocketSink {
  final sent = <Object?>[];
  bool closed = false;

  @override
  void add(Object? event) => sent.add(event);

  @override
  void addError(Object error, [StackTrace? stackTrace]) {}

  @override
  Future<void> addStream(Stream stream) async {
    await for (final event in stream) {
      add(event);
    }
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    closed = true;
  }

  @override
  Future<void> get done => Future.value();
}
