import '../entities/reminder.dart';

abstract interface class ReminderRepository {
  Future<Reminder> create({
    required String targetType,
    required String targetId,
    required DateTime triggerTime,
    required int notificationId,
  });

  Future<void> cancel(int notificationId);

  Future<void> cancelByTarget(String targetId);

  Future<List<Reminder>> listByTarget(String targetId);

  Future<List<Reminder>> listPending();
}
