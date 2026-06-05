import '../../domain/entities/timeline_task.dart';
import '../../domain/repositories/reminder_repository.dart';
import '../../domain/repositories/settings_repository.dart';

typedef TaskReminderScheduler =
    Future<bool> Function(TaskReminderNotificationRequest request);

class TaskReminderNotificationRequest {
  const TaskReminderNotificationRequest({
    required this.notificationId,
    required this.title,
    required this.body,
    required this.triggerTime,
    required this.payload,
  });

  final int notificationId;
  final String title;
  final String body;
  final DateTime triggerTime;
  final String payload;
}

class TaskDefaultReminderResult {
  const TaskDefaultReminderResult({
    required this.created,
    required this.scheduled,
  });

  static const skipped = TaskDefaultReminderResult(
    created: false,
    scheduled: false,
  );

  final bool created;
  final bool scheduled;
}

class EnsureTaskDefaultReminderUseCase {
  const EnsureTaskDefaultReminderUseCase({
    required this.settingsRepository,
    required this.reminderRepository,
    required this.scheduleNotification,
  });

  final SettingsRepository settingsRepository;
  final ReminderRepository reminderRepository;
  final TaskReminderScheduler scheduleNotification;

  Future<TaskDefaultReminderResult> call(TimelineTask task) async {
    final startAt = task.startAt;
    if (startAt == null) {
      return TaskDefaultReminderResult.skipped;
    }

    final settings = await settingsRepository.load();
    final reminderAt = _computeDefaultReminder(
      startAt: startAt,
      leadMinutes: settings.defaultReminderLeadMinutes,
    );
    if (reminderAt == null) {
      return TaskDefaultReminderResult.skipped;
    }

    final existing = await reminderRepository.listByTarget(task.id);
    if (existing.any((reminder) => reminder.enabled)) {
      return TaskDefaultReminderResult.skipped;
    }

    final notificationId = _stableNotificationId('schedule:${task.id}');
    await reminderRepository.create(
      targetType: 'schedule',
      targetId: task.id,
      triggerTime: reminderAt,
      notificationId: notificationId,
    );

    var scheduled = false;
    try {
      scheduled = await scheduleNotification(
        TaskReminderNotificationRequest(
          notificationId: notificationId,
          title: task.title.isNotEmpty ? task.title : '任务提醒',
          body: '任务即将开始',
          triggerTime: reminderAt,
          payload: 'schedule:${task.id}',
        ),
      );
    } on Object {
      scheduled = false;
    }

    return TaskDefaultReminderResult(created: true, scheduled: scheduled);
  }
}

DateTime? _computeDefaultReminder({
  required DateTime startAt,
  required int leadMinutes,
}) {
  final now = DateTime.now();
  if (!startAt.isAfter(now)) return null;

  final lead = Duration(minutes: leadMinutes);
  final reminderAt = startAt.subtract(lead);
  return reminderAt.isAfter(now) ? reminderAt : startAt;
}

int _stableNotificationId(String value) {
  var hash = 0x811c9dc5;
  for (final unit in value.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0x7fffffff;
  }
  return hash == 0 ? 1 : hash;
}
