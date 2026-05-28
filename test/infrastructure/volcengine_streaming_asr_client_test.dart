import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/domain/entities/ai_config.dart';
import 'package:glass_note/domain/services/realtime_transcription_client.dart';
import 'package:glass_note/infrastructure/ai/volcengine_streaming_asr_client.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  test('parses Volcengine ASR delta and final transcript payloads', () {
    final delta = VolcengineAsrEventParser.parsePayload(
      utf8.encode(
        jsonEncode({
          'result': {'text': '今天开会', 'utterances': []},
        }),
      ),
    );
    final completed = VolcengineAsrEventParser.parsePayload(
      utf8.encode(
        jsonEncode({
          'result': {
            'text': '今天开会整理计划',
            'utterances': [
              {'text': '今天开会整理计划', 'definite': true},
            ],
          },
        }),
      ),
    );

    expect(delta.type, TranscriptionEventType.delta);
    expect(delta.text, '今天开会');
    expect(completed.type, TranscriptionEventType.completed);
    expect(completed.text, '今天开会整理计划');
  });

  test('parses Volcengine ASR error payload into readable event', () {
    final event = VolcengineAsrEventParser.parsePayload(
      utf8.encode(jsonEncode({'code': 401, 'message': 'invalid token'})),
    );

    expect(event.type, TranscriptionEventType.error);
    expect(event.text, contains('invalid token'));
  });

  test('decodes full server response packet with sequence number', () {
    final packet = _serverPacket(
      messageType: 9,
      flags: 1,
      sequence: 1,
      payload: utf8.encode(
        jsonEncode({
          'result': {'text': '只羡鸳鸯不羡仙', 'definite': true},
        }),
      ),
    );

    final event = decodeVolcengineServerMessage(packet);

    expect(event.type, TranscriptionEventType.completed);
    expect(event.text, '只羡鸳鸯不羡仙');
  });

  test(
    'decodes error response packet without leaking packet bytes into JSON',
    () {
      final packet = _serverPacket(
        messageType: 15,
        errorCode: 106,
        payload: utf8.encode(
          jsonEncode({
            'error':
                '[Timeout waiting next packet]\nwaiting next packet timeout: 8.',
          }),
        ),
      );

      final event = decodeVolcengineServerMessage(packet);

      expect(event.type, TranscriptionEventType.error);
      expect(event.text, contains('Timeout waiting next packet'));
    },
  );

  test('decodes gzip-compressed server packet payload', () {
    final packet = _serverPacket(
      messageType: 9,
      flags: 1,
      sequence: 2,
      compression: 1,
      payload: gzip.encode(
        utf8.encode(
          jsonEncode({
            'result': {'text': '测试音频', 'definite': true},
          }),
        ),
      ),
    );

    final event = decodeVolcengineServerMessage(packet);

    expect(event.type, TranscriptionEventType.completed);
    expect(event.text, '测试音频');
  });

  test('builds gzip audio packets with binary serialization flags', () {
    final config = AiConfig.defaults(now: DateTime(2026, 5, 28));
    final fullRequest = buildVolcengineFullClientRequest(config, 'request-id');
    final audioRequest = buildVolcengineAudioRequest([1, 2, 3, 4]);
    final finalRequest = buildVolcengineAudioRequest(const [], isLast: true);

    expect(fullRequest[1] >> 4, 1);
    expect(fullRequest[2], 0x11);
    expect(audioRequest[1] >> 4, 2);
    expect(audioRequest[2], 0x01);
    expect(finalRequest[1] & 0x0f, 0x02);
    expect(finalRequest[2], 0x01);
  });

  test('transcribe marks the final real audio chunk as last packet', () async {
    final channel = _FakeWebSocketChannel(const Stream<Object>.empty());
    final client = VolcengineStreamingAsrClient(
      connector: (config, secrets) async => channel,
    );

    final sub = client
        .transcribe(
          audio: Stream.fromIterable([
            [1, 2],
            [3, 4],
          ]),
          config: AiConfig.defaults(now: DateTime(2026, 5, 28)),
          secrets: const AiSecrets(
            volcAppKey: 'app',
            volcAccessKey: 'access',
            deepSeekApiKey: '',
          ),
        )
        .listen((_) {});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await sub.cancel();

    expect(channel.sink.sent, hasLength(3));
    final firstAudio = channel.sink.sent[1] as List<int>;
    final lastAudio = channel.sink.sent[2] as List<int>;
    expect(firstAudio[1] & 0x0f, 0);
    expect(lastAudio[1] & 0x0f, 0x02);
    expect(_clientPayload(lastAudio), [3, 4]);
  });

  test(
    'transcribe treats timeout after transcript as completed text',
    () async {
      final channel = _FakeWebSocketChannel(
        Stream<Object>.fromIterable([
          _serverPacket(
            messageType: 9,
            flags: 1,
            sequence: 1,
            payload: utf8.encode(
              jsonEncode({
                'result': {'text': '只羡鸳鸯不羡仙'},
              }),
            ),
          ),
          _serverPacket(
            messageType: 15,
            errorCode: 106,
            payload: utf8.encode(
              jsonEncode({'error': '[Timeout waiting next packet]'}),
            ),
          ),
        ]),
      );
      final client = VolcengineStreamingAsrClient(
        connector: (config, secrets) async => channel,
      );

      final events = await client
          .transcribe(
            audio: Stream.value([1, 2]),
            config: AiConfig.defaults(now: DateTime(2026, 5, 28)),
            secrets: const AiSecrets(
              volcAppKey: 'app',
              volcAccessKey: 'access',
              deepSeekApiKey: '',
            ),
          )
          .toList();

      expect(events.last.type, TranscriptionEventType.completed);
      expect(events.last.text, '只羡鸳鸯不羡仙');
    },
  );
}

Uint8List _serverPacket({
  required int messageType,
  required List<int> payload,
  int flags = 0,
  int serialization = 1,
  int compression = 0,
  int? sequence,
  int? errorCode,
}) {
  final bytes = <int>[
    0x11,
    (messageType << 4) | flags,
    (serialization << 4) | compression,
    0x00,
  ];
  if (sequence != null) {
    bytes.addAll(_int32(sequence));
  }
  if (errorCode != null) {
    bytes.addAll(_int32(errorCode));
  }
  bytes
    ..addAll(_int32(payload.length))
    ..addAll(payload);
  return Uint8List.fromList(bytes);
}

List<int> _int32(int value) {
  final data = ByteData(4)..setInt32(0, value, Endian.big);
  return data.buffer.asUint8List();
}

List<int> _clientPayload(List<int> packet) {
  final length = ByteData.sublistView(
    Uint8List.fromList(packet),
    4,
    8,
  ).getInt32(0, Endian.big);
  final payload = packet.sublist(8, 8 + length);
  return gzip.decode(payload);
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
  Future<void> close([int? closeCode, String? closeReason]) async {}

  @override
  Future<void> get done => Future.value();
}
