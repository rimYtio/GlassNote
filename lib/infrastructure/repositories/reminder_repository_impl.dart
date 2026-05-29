import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/reminder.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../database/app_database.dart';
import '../notifications/local_notification_service.dart';

class ReminderRepositoryImpl implements ReminderRepository {
  ReminderRepositoryImpl({
    required AppDatabase database,
    required LocalNotificationService notificationService,
  })  : _database = database,
        _notificationService = notificationService;

  final AppDatabase _database;
  final LocalNotificationService _notificationService;

  @override
  Future<Reminder> create({
    required String targetType,
    required String targetId,
    required DateTime triggerTime,
    required int notificationId,
  }) async {
    final now = DateTime.now();
    final reminder = await _database.remindersDao.create(
      ReminderRowsCompanion.insert(
        id: const Uuid().v4(),
        targetType: targetType,
        targetId: targetId,
        triggerTime: triggerTime,
        notificationId: notificationId,
        createdAt: now,
      ),
    );
    debugPrint('Created reminder: ${reminder.id} for $targetType $targetId');
    return reminder;
  }

  @override
  Future<void> cancel(int notificationId) async {
    debugPrint('Cancelling reminder with notificationId: $notificationId');
    await _notificationService.cancel(notificationId);
    await _database.remindersDao.cancelByNotificationId(notificationId);
  }

  @override
  Future<void> cancelByTarget(String targetId) async {
    debugPrint('Cancelling all reminders for target: $targetId');
    final reminders = await _database.remindersDao.listByTarget(targetId);
    for (final reminder in reminders) {
      await _notificationService.cancel(reminder.notificationId);
    }
    await _database.remindersDao.cancelByTarget(targetId);
  }

  @override
  Future<List<Reminder>> listByTarget(String targetId) {
    return _database.remindersDao.listByTarget(targetId);
  }

  @override
  Future<List<Reminder>> listPending() {
    return _database.remindersDao.listPending();
  }
}
