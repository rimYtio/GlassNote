import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:glass_note/domain/entities/timeline_task.dart';
import 'package:glass_note/infrastructure/database/app_database.dart';
import 'package:glass_note/infrastructure/repositories/timeline_task_repository_impl.dart';

void main() {
  late AppDatabase database;
  late TimelineTaskRepositoryImpl repository;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    repository = TimelineTaskRepositoryImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'creates, lists, searches, updates, and soft deletes timeline tasks',
    () async {
      final today = DateTime(2026, 5, 27);
      final tomorrow = DateTime(2026, 5, 28);

      final task = await repository.create(
        TimelineTaskDraft(
          title: '提交周报',
          description: '整理本周计划',
          taskDate: today,
          startAt: DateTime(2026, 5, 27, 9),
          endAt: DateTime(2026, 5, 27, 10),
          importance: TimelineImportance.high,
          colorArgb: TimelineTaskDefaults.highColorArgb,
        ),
      );

      await repository.create(
        TimelineTaskDraft(title: '明天任务', taskDate: tomorrow),
      );

      final range = await repository.listRange(
        startDate: DateTime(2026, 5, 27),
        endDate: DateTime(2026, 5, 27),
      );
      expect(range.single.title, '提交周报');
      expect(range.single.importance, TimelineImportance.high);

      final search = await repository.search('计划');
      expect(search.single.id, task.id);

      final updated = await repository.update(
        task.copyWith(isCompleted: true, isStarred: true),
      );
      expect(updated.isCompleted, isTrue);
      expect(updated.isStarred, isTrue);

      await repository.delete(task.id);
      expect(await repository.findById(task.id), isNull);
      expect(await repository.search('周报'), isEmpty);
    },
  );
}
