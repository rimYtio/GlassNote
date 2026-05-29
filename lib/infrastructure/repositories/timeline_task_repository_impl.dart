import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/timeline_task.dart';
import '../../domain/repositories/timeline_task_repository.dart';
import '../database/app_database.dart';

class TimelineTaskRepositoryImpl implements TimelineTaskRepository {
  const TimelineTaskRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<TimelineTask> create(TimelineTaskDraft draft) {
    final now = DateTime.now();
    final title = draft.title.trim().isEmpty ? '未命名任务' : draft.title.trim();
    return _database.timelineTasksDao.createTask(
      TimelineTaskRowsCompanion.insert(
        id: const Uuid().v4(),
        title: title,
        description: draft.description,
        taskDate: _dateOnly(draft.taskDate),
        startAt: Value(draft.startAt),
        endAt: Value(draft.endAt),
        importance: draft.importance.name,
        colorArgb: draft.colorArgb,
        isCompleted: Value(draft.isCompleted),
        isStarred: Value(draft.isStarred),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<void> delete(String id) {
    return _database.timelineTasksDao.softDelete(id);
  }

  @override
  Future<TimelineTask?> findById(String id) {
    return _database.timelineTasksDao.findById(id);
  }

  @override
  Future<List<TimelineTask>> listRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _database.timelineTasksDao.listRange(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<TimelineTask>> search(String query) {
    return _database.timelineTasksDao.search(query);
  }

  @override
  Future<TimelineTask> update(TimelineTask task) {
    return _database.timelineTasksDao.updateTask(
      task.copyWith(updatedAt: DateTime.now()),
    );
  }

  @override
  Stream<List<TimelineTask>> watchRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _database.timelineTasksDao.watchRange(
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Stream<List<TimelineTask>> watchByDate(DateTime date) {
    return _database.timelineTasksDao.watchRange(
      startDate: _dateOnly(date),
      endDate: _dateOnly(date),
    );
  }
}

DateTime _dateOnly(DateTime value) {
  return DateTime(value.year, value.month, value.day);
}
