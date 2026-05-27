import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/domain/entities/timeline_task.dart';

void main() {
  test('timeline tasks sort by day, time, and starred state', () {
    final day = DateTime(2026, 5, 27);
    final tomorrow = DateTime(2026, 5, 28);
    final tasks = [
      _task(
        id: 'later',
        title: 'Later',
        taskDate: day,
        startAt: DateTime(2026, 5, 27, 16),
      ),
      _task(
        id: 'tomorrow',
        title: 'Tomorrow',
        taskDate: tomorrow,
        startAt: DateTime(2026, 5, 28, 9),
      ),
      _task(
        id: 'starred',
        title: 'Starred',
        taskDate: day,
        startAt: DateTime(2026, 5, 27, 9),
        isStarred: true,
      ),
      _task(
        id: 'normal',
        title: 'Normal',
        taskDate: day,
        startAt: DateTime(2026, 5, 27, 9),
      ),
    ];

    final sorted = TimelineTaskSort.sortedForTimeline(tasks);

    expect(sorted.map((task) => task.id), [
      'starred',
      'normal',
      'later',
      'tomorrow',
    ]);
  });

  test(
    'timeline task draft defaults to medium importance and preset color',
    () {
      final draft = TimelineTaskDraft(
        title: 'Plan',
        taskDate: DateTime(2026, 5, 27),
      );

      expect(draft.importance, TimelineImportance.medium);
      expect(draft.colorArgb, TimelineTaskDefaults.mediumColorArgb);
      expect(draft.isCompleted, isFalse);
      expect(draft.isStarred, isFalse);
    },
  );
}

TimelineTask _task({
  required String id,
  required String title,
  required DateTime taskDate,
  DateTime? startAt,
  bool isStarred = false,
}) {
  final now = DateTime(2026, 5, 27, 8);
  return TimelineTask(
    id: id,
    title: title,
    description: '',
    taskDate: taskDate,
    startAt: startAt,
    endAt: null,
    importance: TimelineImportance.medium,
    colorArgb: TimelineTaskDefaults.mediumColorArgb,
    isCompleted: false,
    isStarred: isStarred,
    isDeleted: false,
    createdAt: now,
    updatedAt: now,
  );
}
