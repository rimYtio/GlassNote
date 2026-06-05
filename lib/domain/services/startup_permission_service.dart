class StartupPermissionStatus {
  const StartupPermissionStatus({
    required this.notificationsGranted,
    required this.exactAlarmsGranted,
    required this.microphoneGranted,
  });

  final bool notificationsGranted;
  final bool exactAlarmsGranted;
  final bool microphoneGranted;

  bool get allGranted =>
      notificationsGranted && exactAlarmsGranted && microphoneGranted;

  bool get canDeliverScheduledNotifications =>
      notificationsGranted && exactAlarmsGranted;
}

abstract interface class StartupPermissionService {
  Future<StartupPermissionStatus> checkStatus();

  Future<StartupPermissionStatus> requestAll();

  Future<StartupPermissionStatus?> requestAtFirstLaunch();
}
