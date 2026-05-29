import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/timeline_use_case_providers.dart';
import '../../../domain/entities/timeline_task.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';

typedef TimelineRange = ({DateTime startDate, DateTime endDate});

final timelineTasksRangeProvider =
    StreamProvider.family<List<TimelineTask>, TimelineRange>((ref, range) {
      return ref
          .watch(timelineTaskRepositoryProvider)
          .watchRange(startDate: range.startDate, endDate: range.endDate);
    });

final timelineTaskSearchProvider =
    FutureProvider.family<List<TimelineTask>, String>((ref, query) {
      final trimmed = query.trim();
      if (trimmed.isEmpty) {
        return Future.value(const []);
      }
      return ref.watch(timelineTaskRepositoryProvider).search(trimmed);
    });

final timelineActionsProvider = Provider<TimelineActions>((ref) {
  return TimelineActions(ref);
});

class TimelineActions {
  const TimelineActions(this._ref);

  final Ref _ref;

  Future<TimelineTask> create(TimelineTaskDraft draft) {
    return _ref.read(createTimelineTaskUseCaseProvider)(draft);
  }

  Future<TimelineTask> update(TimelineTask task) {
    return _ref.read(timelineTaskRepositoryProvider).update(task);
  }

  Future<void> toggleCompleted(TimelineTask task) {
    return update(task.copyWith(isCompleted: !task.isCompleted));
  }

  Future<void> toggleStar(TimelineTask task) {
    return update(task.copyWith(isStarred: !task.isStarred));
  }

  Future<void> delete(TimelineTask task) async {
    await _ref.read(reminderRepositoryProvider).cancelByTarget(task.id);
    return _ref.read(timelineTaskRepositoryProvider).delete(task.id);
  }
}
