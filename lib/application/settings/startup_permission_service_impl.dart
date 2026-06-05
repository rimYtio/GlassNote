// ignore_for_file: prefer_initializing_formals

import '../../domain/repositories/settings_repository.dart';
import '../../domain/services/audio_input_service.dart';
import '../../domain/services/notification_permission_service.dart';
import '../../domain/services/startup_permission_service.dart';

class StartupPermissionServiceImpl implements StartupPermissionService {
  const StartupPermissionServiceImpl({
    required SettingsRepository settingsRepository,
    required NotificationPermissionService notificationPermissions,
    required AudioInputService audioInput,
  }) : _settingsRepository = settingsRepository,
       _notificationPermissions = notificationPermissions,
       _audioInput = audioInput;

  final SettingsRepository _settingsRepository;
  final NotificationPermissionService _notificationPermissions;
  final AudioInputService _audioInput;

  @override
  Future<StartupPermissionStatus> checkStatus() async {
    final notificationsGranted = await _safeBool(
      _notificationPermissions.areNotificationsEnabled,
    );
    final exactAlarmsGranted = await _safeBool(
      _notificationPermissions.canScheduleExactAlarms,
    );
    final microphoneGranted = await _safeBool(_audioInput.checkPermission);
    return StartupPermissionStatus(
      notificationsGranted: notificationsGranted,
      exactAlarmsGranted: exactAlarmsGranted,
      microphoneGranted: microphoneGranted,
    );
  }

  @override
  Future<StartupPermissionStatus> requestAll() async {
    final notificationsGranted = await _safeBool(
      _notificationPermissions.requestNotificationPermission,
    );
    final exactAlarmsGranted = await _safeBool(
      _notificationPermissions.requestExactAlarmPermission,
    );
    final microphoneGranted = await _safeBool(_audioInput.requestPermission);
    await _markRequested();
    return StartupPermissionStatus(
      notificationsGranted: notificationsGranted,
      exactAlarmsGranted: exactAlarmsGranted,
      microphoneGranted: microphoneGranted,
    );
  }

  @override
  Future<StartupPermissionStatus?> requestAtFirstLaunch() async {
    final settings = await _settingsRepository.load();
    if (settings.hasRequestedStartupPermissions) {
      return null;
    }
    return requestAll();
  }

  Future<void> _markRequested() async {
    final settings = await _settingsRepository.load();
    await _settingsRepository.save(
      settings.copyWith(
        hasRequestedStartupPermissions: true,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<bool> _safeBool(Future<bool> Function() action) async {
    try {
      return await action();
    } on Object {
      return false;
    }
  }
}
