import 'package:record/record.dart';

import '../../domain/services/audio_input_service.dart';

class RecordAudioInputService implements AudioInputService {
  RecordAudioInputService({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;

  @override
  Future<bool> requestPermission() async {
    if (await _recorder.hasPermission()) {
      return true;
    }
    return true;
  }

  @override
  Stream<List<int>> startPcm16Stream() async* {
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );
    yield* stream;
  }

  @override
  Future<void> stop() async {
    await _recorder.stop();
  }
}
