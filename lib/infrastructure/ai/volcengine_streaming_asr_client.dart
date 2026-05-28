import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/entities/ai_config.dart';
import '../../domain/services/realtime_transcription_client.dart';

class VolcengineStreamingAsrClient implements RealtimeTranscriptionClient {
  VolcengineStreamingAsrClient({WebSocketConnector? connector})
    : _connector = connector ?? _defaultConnector;

  final WebSocketConnector _connector;

  @override
  Stream<TranscriptionEvent> transcribe({
    required Stream<List<int>> audio,
    required AiConfig config,
    required AiSecrets secrets,
  }) async* {
    final channel = await _connector(config, secrets);
    final requestId = const Uuid().v4();
    channel.sink.add(_buildFullClientRequest(config, requestId));

    final incoming = channel.stream
        .cast<Object>()
        .map<TranscriptionEvent>(_decodeServerMessage)
        .where((event) => event.text.trim().isNotEmpty);

    final audioDone = Completer<void>();
    unawaited(
      audio
          .listen(
            (chunk) => channel.sink.add(_buildAudioRequest(chunk)),
            onDone: () {
              channel.sink.add(_buildAudioRequest(const [], isLast: true));
              audioDone.complete();
            },
            onError: (Object error) {
              if (!audioDone.isCompleted) {
                audioDone.completeError(error);
              }
            },
            cancelOnError: true,
          )
          .asFuture<void>(),
    );

    try {
      yield* incoming;
      await audioDone.future;
    } finally {
      unawaited(channel.sink.close());
    }
  }
}

typedef WebSocketConnector =
    Future<WebSocketChannel> Function(AiConfig config, AiSecrets secrets);

Future<WebSocketChannel> _defaultConnector(
  AiConfig config,
  AiSecrets secrets,
) async {
  return IOWebSocketChannel.connect(
    Uri.parse(config.volcAsrEndpoint),
    headers: {
      'X-Api-App-Key': secrets.volcAppKey,
      'X-Api-Access-Key': secrets.volcAccessKey,
      'X-Api-Resource-Id': config.volcAsrResourceId,
      'X-Api-Connect-Id': const Uuid().v4(),
    },
  );
}

class VolcengineAsrEventParser {
  const VolcengineAsrEventParser._();

  static TranscriptionEvent parsePayload(List<int> payload) {
    final decoded = utf8.decode(payload, allowMalformed: true);
    final json = jsonDecode(decoded);
    if (json is! Map<String, Object?>) {
      return const TranscriptionEvent.error('语音识别返回格式无效');
    }
    final code = json['code'];
    if (code != null && code.toString() != '0') {
      return TranscriptionEvent.error(
        (json['message'] ?? json['msg'] ?? '语音识别失败').toString(),
      );
    }

    final text = _extractText(json);
    if (_isFinal(json)) {
      return TranscriptionEvent.completed(text);
    }
    return TranscriptionEvent.delta(text);
  }

  static String _extractText(Map<String, Object?> json) {
    final result = json['result'];
    if (result is Map) {
      final text = result['text'];
      if (text != null) {
        return text.toString();
      }
    }
    final payload = json['payload_msg'];
    if (payload is Map) {
      final result = payload['result'];
      if (result is Map && result['text'] != null) {
        return result['text'].toString();
      }
    }
    return (json['text'] ?? '').toString();
  }

  static bool _isFinal(Map<String, Object?> json) {
    final result = json['result'];
    if (result is Map) {
      final utterances = result['utterances'];
      if (utterances is List && utterances.isNotEmpty) {
        return utterances.any((item) {
          return item is Map && item['definite'] == true;
        });
      }
      return result['definite'] == true;
    }
    return json['definite'] == true || json['is_final'] == true;
  }
}

TranscriptionEvent _decodeServerMessage(Object message) {
  if (message is String) {
    return VolcengineAsrEventParser.parsePayload(utf8.encode(message));
  }
  if (message is List<int>) {
    return VolcengineAsrEventParser.parsePayload(_extractPayload(message));
  }
  return const TranscriptionEvent.error('语音识别返回格式无效');
}

Uint8List _buildFullClientRequest(AiConfig config, String requestId) {
  final payload = utf8.encode(
    jsonEncode({
      'user': {'uid': 'glassnote-local'},
      'audio': {
        'format': 'pcm',
        'codec': 'raw',
        'rate': 24000,
        'bits': 16,
        'channel': 1,
      },
      'request': {
        'model_name': 'bigmodel',
        'enable_itn': true,
        'enable_punc': true,
        'language': config.volcAsrLanguage,
        'reqid': requestId,
      },
    }),
  );
  return _buildPacket(messageType: 1, payload: payload);
}

Uint8List _buildAudioRequest(List<int> audio, {bool isLast = false}) {
  return _buildPacket(messageType: 2, payload: audio, isLast: isLast);
}

Uint8List _buildPacket({
  required int messageType,
  required List<int> payload,
  bool isLast = false,
}) {
  final header = <int>[
    0x11,
    (messageType << 4) | (isLast ? 0x02 : 0x00),
    0x10,
    0x00,
  ];
  final length = ByteData(4)..setInt32(0, payload.length, Endian.big);
  return Uint8List.fromList([
    ...header,
    ...length.buffer.asUint8List(),
    ...payload,
  ]);
}

Uint8List _extractPayload(List<int> packet) {
  if (packet.length < 8) {
    return Uint8List.fromList(packet);
  }
  final headerLength = (packet[0] & 0x0f) * 4;
  if (packet.length < headerLength + 4) {
    return Uint8List.fromList(packet);
  }
  final length = ByteData.sublistView(
    Uint8List.fromList(packet),
    headerLength,
    headerLength + 4,
  ).getInt32(0, Endian.big);
  final start = headerLength + 4;
  final end = (start + length).clamp(start, packet.length);
  return Uint8List.fromList(packet.sublist(start, end));
}
