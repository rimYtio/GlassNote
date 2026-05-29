import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_note/app/app.dart';
import 'package:glass_note/domain/entities/ai_config.dart';
import 'package:glass_note/domain/entities/capture_draft_preview.dart';
import 'package:glass_note/domain/services/audio_input_service.dart';
import 'package:glass_note/domain/services/capture_analyzer.dart';
import 'package:glass_note/domain/services/realtime_transcription_client.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/providers/infrastructure_providers.dart';
import 'package:glass_note/infrastructure/security/in_memory_secure_key_value_store.dart';

void main() {
  late AppDatabase database;
  late InMemorySecureKeyValueStore secrets;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    secrets = InMemorySecureKeyValueStore();
    await secrets.writeSecret(key: 'volc_app_key', value: 'app');
    await secrets.writeSecret(key: 'volc_access_key', value: 'access');
    await secrets.writeSecret(key: 'deepseek_api_key', value: 'deepseek');
  });

  tearDown(() async {
    await database.close();
  });

  testWidgets('capture records transcript and confirms note preview', (
    tester,
  ) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureKeyValueStoreProvider.overrideWithValue(secrets),
          audioInputServiceProvider.overrideWithValue(_FakeAudioInputService()),
          realtimeTranscriptionClientProvider.overrideWithValue(
            _FakeRealtimeTranscriptionClient(),
          ),
          captureAnalyzerProvider.overrideWithValue(_FakeCaptureAnalyzer()),
        ],
        child: const GlassNoteApp(),
      ),
    );
    await _pumpUi(tester);

    final button = find.byKey(const ValueKey('capture-mic-button'));
    expect(button, findsOneWidget);

    final gesture = await _startLongPress(tester, button);
    await _pumpUi(tester);
    expect(find.byKey(const ValueKey('capture-voice-orb')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('capture-transcript-glass')),
      findsOneWidget,
    );
    expect(find.textContaining('记录一个想法'), findsOneWidget);

    await gesture.up();
    await _pumpUi(tester);
    expect(find.byKey(const ValueKey('capture-preview-card')), findsOneWidget);
    expect(find.text('语音想法'), findsOneWidget);

    final confirmButton = find.widgetWithText(FilledButton, '确认创建全部 (1)');
    await tester.ensureVisible(confirmButton);
    await tester.tap(confirmButton);
    await _pumpUi(tester);

    final notes = await database.notesDao.search('语音想法');
    expect(notes.single.plainText, '记录一个想法');

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('capture page keeps voice orb above transcript glass at idle', (
    tester,
  ) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureKeyValueStoreProvider.overrideWithValue(secrets),
          audioInputServiceProvider.overrideWithValue(_FakeAudioInputService()),
          realtimeTranscriptionClientProvider.overrideWithValue(
            _EmptyRealtimeTranscriptionClient(),
          ),
          captureAnalyzerProvider.overrideWithValue(_FakeCaptureAnalyzer()),
        ],
        child: const GlassNoteApp(),
      ),
    );
    await _pumpUi(tester);

    final orb = find.byKey(const ValueKey('capture-voice-orb'));
    final transcriptGlass = find.byKey(
      const ValueKey('capture-transcript-glass'),
    );
    expect(orb, findsOneWidget);
    expect(transcriptGlass, findsOneWidget);
    expect(
      tester.getBottomLeft(orb).dy,
      lessThan(tester.getTopLeft(transcriptGlass).dy),
    );
    expect(find.text('字幕会在你说话时出现在这里。'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('voice orb grows from microphone amplitude while recording', (
    tester,
  ) async {
    _useTallViewport(tester);
    final audio = _FakeAudioInputService();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureKeyValueStoreProvider.overrideWithValue(secrets),
          audioInputServiceProvider.overrideWithValue(audio),
          realtimeTranscriptionClientProvider.overrideWithValue(
            _EmptyRealtimeTranscriptionClient(),
          ),
          captureAnalyzerProvider.overrideWithValue(_FakeCaptureAnalyzer()),
        ],
        child: const GlassNoteApp(),
      ),
    );
    await _pumpUi(tester);

    final button = find.byKey(const ValueKey('capture-mic-button'));
    final gesture = await _startLongPress(tester, button);
    await _pumpUi(tester);

    audio.emitAmplitude(0.85);
    await tester.pump(const Duration(milliseconds: 120));
    final loudScale = tester.widget<AnimatedScale>(
      find.byKey(const ValueKey('capture-voice-orb-scale')),
    );
    expect(loudScale.scale, greaterThan(1.08));

    await gesture.up();
    await _pumpUi(tester);
    final idleScale = tester.widget<AnimatedScale>(
      find.byKey(const ValueKey('capture-voice-orb-scale')),
    );
    expect(idleScale.scale, lessThan(loudScale.scale));

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('capture clears missing API error after settings are saved', (
    tester,
  ) async {
    _useTallViewport(tester);
    secrets = InMemorySecureKeyValueStore();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureKeyValueStoreProvider.overrideWithValue(secrets),
          audioInputServiceProvider.overrideWithValue(_FakeAudioInputService()),
          realtimeTranscriptionClientProvider.overrideWithValue(
            _EmptyRealtimeTranscriptionClient(),
          ),
          captureAnalyzerProvider.overrideWithValue(_FakeCaptureAnalyzer()),
        ],
        child: const GlassNoteApp(),
      ),
    );
    await _pumpUi(tester);

    final button = find.byKey(const ValueKey('capture-mic-button'));
    final gesture = await _startLongPress(tester, button);
    await gesture.up();
    await _pumpUi(tester);
    expect(find.text('捕获失败'), findsOneWidget);
    expect(find.textContaining('请先在 API 设置中填写'), findsOneWidget);

    await tester.tap(find.text('设置').last);
    await _pumpUi(tester);
    await tester.tap(find.text('API 设置'));
    await _pumpUi(tester);
    await tester.enterText(
      find.byKey(const ValueKey('ai-volc-app-key-field')),
      'app',
    );
    await tester.enterText(
      find.byKey(const ValueKey('ai-volc-access-key-field')),
      'access',
    );
    await tester.enterText(
      find.byKey(const ValueKey('ai-deepseek-key-field')),
      'deepseek',
    );
    await tester.tap(find.byTooltip('保存'));
    await _pumpUi(tester);

    await tester.tap(find.text('捕获').last);
    await _pumpUi(tester);
    expect(find.text('捕获失败'), findsNothing);
    expect(find.text('语音捕获'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('mic button scales down and shows halo while pressed', (
    tester,
  ) async {
    _useTallViewport(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          secureKeyValueStoreProvider.overrideWithValue(secrets),
          audioInputServiceProvider.overrideWithValue(_FakeAudioInputService()),
          realtimeTranscriptionClientProvider.overrideWithValue(
            _EmptyRealtimeTranscriptionClient(),
          ),
          captureAnalyzerProvider.overrideWithValue(_FakeCaptureAnalyzer()),
        ],
        child: const GlassNoteApp(),
      ),
    );
    await _pumpUi(tester);

    final button = find.byKey(const ValueKey('capture-mic-button'));
    final gesture = await _startLongPress(tester, button);
    await tester.pump(const Duration(milliseconds: 50));

    final pressedScale = tester.widget<AnimatedScale>(
      find.byKey(const ValueKey('capture-mic-scale')),
    );
    final halo = tester.widget<AnimatedOpacity>(
      find.byKey(const ValueKey('capture-mic-halo')),
    );
    expect(pressedScale.scale, lessThan(1));
    expect(halo.opacity, greaterThan(0));

    await gesture.up();
    await tester.pump(const Duration(milliseconds: 50));
    final releasedScale = tester.widget<AnimatedScale>(
      find.byKey(const ValueKey('capture-mic-scale')),
    );
    expect(releasedScale.scale, 1);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

class _FakeAudioInputService implements AudioInputService {
  final _amplitudes = StreamController<double>.broadcast();

  @override
  Future<bool> requestPermission() async => true;

  @override
  Stream<List<int>> startPcm16Stream() => Stream.value([0, 1, 2, 3]);

  @override
  Stream<double> get amplitudeStream => _amplitudes.stream;

  void emitAmplitude(double value) {
    _amplitudes.add(value);
  }

  @override
  Future<void> stop() async {
    emitAmplitude(0);
  }
}

class _FakeRealtimeTranscriptionClient implements RealtimeTranscriptionClient {
  @override
  Stream<TranscriptionEvent> transcribe({
    required Stream<List<int>> audio,
    required AiConfig config,
    required AiSecrets secrets,
  }) async* {
    yield const TranscriptionEvent.delta('记录一个想法');
    yield const TranscriptionEvent.completed('记录一个想法');
  }
}

class _EmptyRealtimeTranscriptionClient implements RealtimeTranscriptionClient {
  @override
  Stream<TranscriptionEvent> transcribe({
    required Stream<List<int>> audio,
    required AiConfig config,
    required AiSecrets secrets,
  }) async* {}
}

class _FakeCaptureAnalyzer implements CaptureAnalyzer {
  @override
  Future<List<CaptureDraftPreview>> analyze({
    required String transcript,
    required AiConfig config,
    required AiSecrets secrets,
  }) async {
    return [CaptureDraftPreview.note(title: '语音想法', content: transcript)];
  }
}

Future<void> _pumpUi(WidgetTester tester) async {
  for (var i = 0; i < 5; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Future<TestGesture> _startLongPress(WidgetTester tester, Finder target) async {
  final gesture = await tester.startGesture(tester.getCenter(target));
  await tester.pump(const Duration(milliseconds: 650));
  return gesture;
}

void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(800, 1200);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
