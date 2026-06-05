import '../../domain/entities/timeline_task.dart';
import '../../domain/repositories/timeline_task_repository.dart';
import 'ensure_task_default_reminder_use_case.dart';

class CreateTimelineTaskUseCase {
  const CreateTimelineTaskUseCase(this._tasks, {this.defaultReminder});

  final TimelineTaskRepository _tasks;
  final EnsureTaskDefaultReminderUseCase? defaultReminder;

  Future<TimelineTask> call(TimelineTaskDraft draft) async {
    final task = await _tasks.create(draft);
    try {
      await defaultReminder?.call(task);
    } on Object {
      // A reminder failure must not block creating the local task.
    }
    return task;
  }
}
