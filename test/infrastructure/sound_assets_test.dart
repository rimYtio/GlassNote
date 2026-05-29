import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('microphone arm sound is a short low-frequency click', () {
    final wav = _readWav('assets/sounds/mic_arm.wav');

    expect(wav.durationMs, lessThanOrEqualTo(140));
    expect(wav.zeroCrossingHz, lessThanOrEqualTo(700));
    expect(wav.peak, lessThanOrEqualTo(0.45));
  });
}

_WavStats _readWav(String path) {
  final bytes = File(path).readAsBytesSync();
  final data = ByteData.sublistView(Uint8List.fromList(bytes));
  final channels = data.getUint16(22, Endian.little);
  final sampleRate = data.getUint32(24, Endian.little);
  final bitsPerSample = data.getUint16(34, Endian.little);
  var offset = 12;
  var dataOffset = -1;
  var dataLength = 0;
  while (offset + 8 <= bytes.length) {
    final chunkId = String.fromCharCodes(bytes.sublist(offset, offset + 4));
    final chunkLength = data.getUint32(offset + 4, Endian.little);
    if (chunkId == 'data') {
      dataOffset = offset + 8;
      dataLength = chunkLength;
      break;
    }
    offset += 8 + chunkLength + (chunkLength.isOdd ? 1 : 0);
  }
  if (dataOffset < 0 || bitsPerSample != 16) {
    throw StateError('Unsupported WAV file: $path');
  }

  final samples = <double>[];
  final frameSize = channels * 2;
  for (var i = dataOffset; i + 1 < dataOffset + dataLength; i += frameSize) {
    samples.add(data.getInt16(i, Endian.little) / 32768);
  }
  final peak = samples.fold<double>(
    0,
    (value, sample) => math.max(value, sample.abs()),
  );
  var crossings = 0;
  for (var i = 1; i < samples.length; i += 1) {
    if ((samples[i - 1] < 0 && samples[i] >= 0) ||
        (samples[i - 1] >= 0 && samples[i] < 0)) {
      crossings += 1;
    }
  }
  return _WavStats(
    durationMs: samples.length / sampleRate * 1000,
    zeroCrossingHz: crossings * sampleRate / (2 * samples.length),
    peak: peak,
  );
}

class _WavStats {
  const _WavStats({
    required this.durationMs,
    required this.zeroCrossingHz,
    required this.peak,
  });

  final double durationMs;
  final double zeroCrossingHz;
  final double peak;
}
