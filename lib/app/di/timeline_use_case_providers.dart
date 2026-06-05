import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/timeline/create_timeline_task_use_case.dart';
import '../../application/timeline/ensure_task_default_reminder_use_case.dart';
import '../../infrastructure/providers/infrastructure_providers.dart';

final ensureTaskDefaultReminderUseCaseProvider =
    Provider<EnsureTaskDefaultReminderUseCase>((ref) {
      return EnsureTaskDefaultReminderUseCase(
        settingsRepository: ref.watch(settingsRepositoryProvider),
        reminderRepository: ref.watch(reminderRepositoryProvider),
        scheduleNotification: (request) async {
          try {
            final notificationService = ref.read(
              localNotificationServiceProvider,
            );
            final result = await notificationService.schedule(
              notificationId: request.notificationId,
              title: request.title,
              body: request.body,
              triggerTime: request.triggerTime,
              payload: request.payload,
            );
            return result.isOk;
          } on Object {
            return false;
          }
        },
      );
    });

final createTimelineTaskUseCaseProvider = Provider<CreateTimelineTaskUseCase>((
  ref,
) {
  return CreateTimelineTaskUseCase(
    ref.watch(timelineTaskRepositoryProvider),
    defaultReminder: ref.watch(ensureTaskDefaultReminderUseCaseProvider),
  );
});
