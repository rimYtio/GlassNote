import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();

  static bool enabled = true;

  static Future<void> pageSwitch() {
    return _playOneShot('sounds/page_switch.wav');
  }

  static Future<void> micArm() {
    return _playOneShot('sounds/mic_arm.wav', volume: 1.0);
  }

  static Future<void> _playOneShot(String asset, {double volume = 0.5}) async {
    if (!enabled) {
      return;
    }
    final player = AudioPlayer();
    try {
      await player
          .play(AssetSource(asset), volume: volume, mode: PlayerMode.lowLatency)
          .timeout(const Duration(milliseconds: 250));
      await Future<void>.delayed(const Duration(milliseconds: 150));
    } on Object {
      // Sound feedback should never block the capture gesture.
    } finally {
      unawaited(
        player
            .dispose()
            .timeout(const Duration(milliseconds: 250))
            .catchError((_) {}),
      );
    }
  }
}
