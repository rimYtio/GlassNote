abstract interface class NotificationPermissionService {
  Future<bool> requestNotificationPermission();

  Future<bool> requestExactAlarmPermission();

  Future<bool> areNotificationsEnabled();

  Future<bool> canScheduleExactAlarms();
}
