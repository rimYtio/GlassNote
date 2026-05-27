import '../../domain/entities/timeline_task.dart';
import '../../domain/repositories/timeline_task_repository.dart';

class CreateTimelineTaskUseCase {
  const CreateTimelineTaskUseCase(this._tasks);

  final TimelineTaskRepository _tasks;

  Future<TimelineTask> call(TimelineTaskDraft draft) {
    return _tasks.create(draft);
  }
}
