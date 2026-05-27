import '../entities/timeline_task.dart';

abstract interface class TimelineTaskRepository {
  Future<TimelineTask> create(TimelineTaskDraft draft);

  Future<TimelineTask> update(TimelineTask task);

  Future<void> delete(String id);

  Future<TimelineTask?> findById(String id);

  Future<List<TimelineTask>> listRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<List<TimelineTask>> search(String query);

  Stream<List<TimelineTask>> watchRange({
    required DateTime startDate,
    required DateTime endDate,
  });
}
