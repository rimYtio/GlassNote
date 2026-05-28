import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/domain/services/realtime_transcription_client.dart';
import 'package:glass_note/infrastructure/ai/volcengine_streaming_asr_client.dart';

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
}
