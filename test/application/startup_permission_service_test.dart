import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/application/settings/startup_permission_service_impl.dart';
import 'package:glass_note/domain/entities/app_settings.dart';
import 'package:glass_note/domain/repositories/settings_repository.dart';
import 'package:glass_note/domain/services/audio_input_service.dart';
import 'package:glass_note/domain/services/notification_permission_service.dart';

void main() {
  test(
    'requests startup permissions in order and marks them requested',
    () async {
      final settingsRepository = _FakeSettingsRepository();
      final notifications = _FakeNotificationPermissionService();
      final audio = _FakeAudioInputService();
      final service = StartupPermissionServiceImpl(
        settingsRepository: settingsRepository,
        notificationPermissions: notifications,
        audioInput: audio,
      );

      final status = await service.requestAtFirstLaunch();

      expect(status?.notificationsGranted, isTrue);
      expect(status?.exactAlarmsGranted, isFalse);
      expect(status?.microphoneGranted, isTrue);
      expect(notifications.calls, [
        'requestNotifications',
        'requestExactAlarms',
      ]);
      expect(audio.calls, ['requestMicrophone']);
      expect(
        settingsRepository.saved.single.hasRequestedStartupPermissions,
        isTrue,
      );

      await service.requestAtFirstLaunch();

      expect(notifications.calls, [
        'requestNotifications',
        'requestExactAlarms',
      ]);
      expect(audio.calls, ['requestMicrophone']);
    },
  );

  test(
    'checks permission status without marking startup permissions requested',
    () async {
      final settingsRepository = _FakeSettingsRepository();
      final notifications = _FakeNotificationPermissionService();
      final audio = _FakeAudioInputService();
      final service = StartupPermissionServiceImpl(
        settingsRepository: settingsRepository,
        notificationPermissions: notifications,
        audioInput: audio,
      );

      final status = await service.checkStatus();

      expect(status.notificationsGranted, isTrue);
      expect(status.exactAlarmsGranted, isFalse);
      expect(status.microphoneGranted, isFalse);
      expect(notifications.calls, ['checkNotifications', 'checkExactAlarms']);
      expect(audio.calls, ['checkMicrophone']);
      expect(settingsRepository.saved, isEmpty);
    },
  );
}

class _FakeSettingsRepository implements SettingsRepository {
  var _settings = AppSettings.defaults(now: DateTime(2026, 6, 5));
  final saved = <AppSettings>[];

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<AppSettings> save(AppSettings settings) async {
    _settings = settings;
    saved.add(settings);
    return settings;
  }
}

class _FakeNotificationPermissionService
    implements NotificationPermissionService {
  final calls = <String>[];

  @override
  Future<bool> areNotificationsEnabled() async {
    calls.add('checkNotifications');
    return true;
  }

  @override
  Future<bool> canScheduleExactAlarms() async {
    calls.add('checkExactAlarms');
    return false;
  }

  @override
  Future<bool> requestExactAlarmPermission() async {
    calls.add('requestExactAlarms');
    return false;
  }

  @override
  Future<bool> requestNotificationPermission() async {
    calls.add('requestNotifications');
    return true;
  }
}

class _FakeAudioInputService implements AudioInputService {
  final calls = <String>[];

  @override
  Future<bool> checkPermission() async {
    calls.add('checkMicrophone');
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    calls.add('requestMicrophone');
    return true;
  }

  @override
  Stream<List<int>> startPcm16Stream() => const Stream.empty();

  @override
  Stream<double> get amplitudeStream => const Stream.empty();

  @override
  Future<void> stop() async {}
}
