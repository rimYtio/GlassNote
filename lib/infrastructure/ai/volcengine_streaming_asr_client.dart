import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../domain/entities/ai_config.dart';
import '../../domain/services/realtime_transcription_client.dart';

class VolcengineStreamingAsrClient implements RealtimeTranscriptionClient {
  VolcengineStreamingAsrClient({WebSocketConnector? connector})
    : _connector = connector ?? defaultVolcengineConnector;

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

    final events = StreamController<TranscriptionEvent>();
    var lastTranscript = '';
    late final StreamSubscription<Object> incomingSub;
    incomingSub = channel.stream.cast<Object>().listen(
      (message) {
        final event = _decodeServerMessage(message);
        if (event.text.trim().isEmpty) {
          return;
        }
        switch (event.type) {
          case TranscriptionEventType.delta:
            lastTranscript = event.text;
            events.add(event);
          case TranscriptionEventType.completed:
            lastTranscript = event.text;
            events.add(event);
            unawaited(events.close());
          case TranscriptionEventType.error:
            if (_isWaitingNextPacketTimeout(event.text) &&
                lastTranscript.trim().isNotEmpty) {
              events.add(TranscriptionEvent.completed(lastTranscript));
            } else {
              events.add(event);
            }
            unawaited(events.close());
        }
      },
      onDone: () {
        unawaited(events.close());
      },
      onError: (Object error) {
        events.add(TranscriptionEvent.error('语音识别错误: $error'));
        unawaited(events.close());
      },
    );
    final audioDone = _sendAudio(audio, channel);
    try {
      audioDone.catchError((Object error) {
        if (!events.isClosed) {
          events.add(TranscriptionEvent.error('录音失败: $error'));
          unawaited(events.close());
        }
      });
      yield* events.stream;
      unawaited(incomingSub.cancel());
      await audioDone;
    } finally {
      unawaited(channel.sink.close());
    }
  }

  Future<void> _sendAudio(
    Stream<List<int>> audio,
    WebSocketChannel channel,
  ) async {
    List<int>? pending;
    await for (final chunk in audio) {
      if (pending != null) {
        channel.sink.add(_buildAudioRequest(pending));
      }
      pending = chunk;
    }
    channel.sink.add(_buildAudioRequest(pending ?? const [], isLast: true));
  }
}

typedef WebSocketConnector =
    Future<WebSocketChannel> Function(AiConfig config, AiSecrets secrets);

Future<WebSocketChannel> defaultVolcengineConnector(
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

Uint8List buildVolcengineFullClientRequest(AiConfig config, String requestId) {
  return _buildFullClientRequest(config, requestId);
}

Uint8List buildVolcengineAudioRequest(List<int> audio, {bool isLast = false}) {
  return _buildAudioRequest(audio, isLast: isLast);
}

TranscriptionEvent decodeVolcengineServerMessage(Object message) {
  return _decodeServerMessage(message);
}

class VolcengineAsrEventParser {
  const VolcengineAsrEventParser._();

  static TranscriptionEvent parsePayload(List<int> payload) {
    final decoded = utf8.decode(payload, allowMalformed: true);
    final json = jsonDecode(decoded);
    if (json is! Map<String, Object?>) {
      return const TranscriptionEvent.error('语音识别返回格式无效');
    }
    final error = json['error'];
    if (error != null) {
      return TranscriptionEvent.error(error.toString());
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
  try {
    if (message is String) {
      return VolcengineAsrEventParser.parsePayload(utf8.encode(message));
    }
    if (message is List<int>) {
      return VolcengineAsrEventParser.parsePayload(_extractPayload(message));
    }
  } on FormatException catch (error) {
    return TranscriptionEvent.error('语音识别返回格式无效: ${error.message}');
  }
  return const TranscriptionEvent.error('语音识别返回格式无效');
}

Uint8List _buildFullClientRequest(AiConfig config, String requestId) {
  final payload = gzip.encode(
    utf8.encode(
      jsonEncode({
        'user': {'uid': 'glassnote-local'},
        'audio': {
          'format': 'pcm',
          'codec': 'raw',
          'rate': 16000,
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
    ),
  );
  return _buildPacket(messageType: 1, payload: payload, compressionMethod: 1);
}

Uint8List _buildAudioRequest(List<int> audio, {bool isLast = false}) {
  return _buildPacket(
    messageType: 2,
    payload: gzip.encode(audio),
    isLast: isLast,
    serializationMethod: 0,
    compressionMethod: 1,
  );
}

Uint8List _buildPacket({
  required int messageType,
  required List<int> payload,
  bool isLast = false,
  int serializationMethod = 1,
  int compressionMethod = 0,
}) {
  final header = <int>[
    0x11,
    (messageType << 4) | (isLast ? 0x02 : 0x00),
    (serializationMethod << 4) | compressionMethod,
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
  if (packet.length < headerLength) {
    return Uint8List.fromList(packet);
  }
  final messageType = packet[1] >> 4;
  final flags = packet[1] & 0x0f;
  final compressionMethod = packet[2] & 0x0f;
  var cursor = headerLength;
  if (_packetHasSequence(messageType, flags) && packet.length >= cursor + 4) {
    cursor += 4;
  }
  if (messageType == 15 && packet.length >= cursor + 4) {
    cursor += 4;
  }
  if (packet.length < cursor + 4) {
    return Uint8List.fromList(packet.sublist(cursor));
  }
  final length = ByteData.sublistView(
    Uint8List.fromList(packet),
    cursor,
    cursor + 4,
  ).getInt32(0, Endian.big);
  final start = cursor + 4;
  final end = (start + length).clamp(start, packet.length);
  final payload = Uint8List.fromList(packet.sublist(start, end));
  if (compressionMethod == 1) {
    return Uint8List.fromList(gzip.decode(payload));
  }
  return payload;
}

bool _packetHasSequence(int messageType, int flags) {
  if (messageType != 9 && messageType != 11) {
    return false;
  }
  return flags == 1 || flags == 3;
}

bool _isWaitingNextPacketTimeout(String text) {
  return text.contains('Timeout waiting next packet') ||
      text.contains('waiting next packet timeout');
}
