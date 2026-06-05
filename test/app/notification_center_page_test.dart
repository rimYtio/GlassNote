import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:glass_note/domain/entities/app_settings.dart';
import 'package:glass_note/domain/entities/note.dart';
import 'package:glass_note/domain/entities/reminder.dart';
import 'package:glass_note/domain/entities/timeline_task.dart';
import 'package:glass_note/domain/repositories/note_repository.dart';
import 'package:glass_note/domain/repositories/reminder_repository.dart';
import 'package:glass_note/domain/repositories/settings_repository.dart';
import 'package:glass_note/domain/repositories/timeline_task_repository.dart';
import 'package:glass_note/domain/services/startup_permission_service.dart';
import 'package:glass_note/features/settings/presentation/notification_center_page.dart';
import 'package:glass_note/infrastructure/providers/infrastructure_providers.dart';

void main() {
  testWidgets('notification center cancels a pending reminder', (tester) async {
    final reminders = _FakeReminderRepository();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reminderRepositoryProvider.overrideWithValue(reminders),
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
          noteRepositoryProvider.overrideWithValue(_FakeNoteRepository()),
          startupPermissionServiceProvider.overrideWithValue(
            _FakeStartupPermissionService(),
          ),
        ],
        child: const MaterialApp(home: NotificationCenterPage()),
      ),
    );
    await _pumpUi(tester);

    expect(find.text('测试提醒'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('notification-cancel-42')));
    await _pumpUi(tester);

    expect(reminders.cancelledIds, [42]);
    expect(find.text('测试提醒'), findsNothing);
  });

  testWidgets('notification center shows schedule reminder task title', (
    tester,
  ) async {
    final reminders = _FakeReminderRepository(
      items: [
        Reminder(
          id: 'reminder-task',
          targetType: 'schedule',
          targetId: 'task-1',
          triggerTime: DateTime.now().add(const Duration(hours: 2)),
          notificationId: 99,
          enabled: true,
          createdAt: DateTime.now(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          reminderRepositoryProvider.overrideWithValue(reminders),
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository(),
          ),
          noteRepositoryProvider.overrideWithValue(_FakeNoteRepository()),
          timelineTaskRepositoryProvider.overrideWithValue(
            _FakeTimelineTaskRepository(),
          ),
          startupPermissionServiceProvider.overrideWithValue(
            _FakeStartupPermissionService(
              status: const StartupPermissionStatus(
                notificationsGranted: false,
                exactAlarmsGranted: false,
                microphoneGranted: true,
              ),
            ),
          ),
        ],
        child: const MaterialApp(home: NotificationCenterPage()),
      ),
    );
    await _pumpUi(tester);

    expect(find.text('准备设计评审'), findsOneWidget);
    expect(find.text('行程提醒'), findsOneWidget);
    expect(find.textContaining('系统通知可能不会按时弹出'), findsWidgets);
  });
}

Future<void> _pumpUi(WidgetTester tester) async {
  for (var i = 0; i < 5; i += 1) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

class _FakeReminderRepository implements ReminderRepository {
  _FakeReminderRepository({List<Reminder>? items})
    : _items =
          items ??
          [
            Reminder(
              id: 'reminder-1',
              targetType: 'note',
              targetId: 'note-1',
              triggerTime: DateTime.now().add(const Duration(hours: 1)),
              notificationId: 42,
              enabled: true,
              createdAt: DateTime.now(),
            ),
          ];

  final cancelledIds = <int>[];
  List<Reminder> _items;

  @override
  Future<Reminder> create({
    required String targetType,
    required String targetId,
    required DateTime triggerTime,
    required int notificationId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> cancel(int notificationId) async {
    cancelledIds.add(notificationId);
    _items = _items.where((r) => r.notificationId != notificationId).toList();
  }

  @override
  Future<void> cancelByTarget(String targetId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Reminder>> listByTarget(String targetId) {
    throw UnimplementedError();
  }

  @override
  Future<List<Reminder>> listPending() async => _items;
}

class _FakeNoteRepository implements NoteRepository {
  @override
  Future<Note?> findById(String id) async {
    return Note(
      id: id,
      title: '测试提醒',
      plainText: '',
      richContentJson: '{}',
      folderId: 'inbox',
      isStarred: false,
      isDeleted: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<Note> create(NoteDraft draft) => throw UnimplementedError();
  @override
  Future<void> delete(String id) => throw UnimplementedError();
  @override
  Future<List<Note>> listByFolder(String folderId) =>
      throw UnimplementedError();
  @override
  Future<List<Note>> listDeleted() => throw UnimplementedError();
  @override
  Future<void> moveNotesToFolder({
    required String fromFolderId,
    required String toFolderId,
  }) => throw UnimplementedError();
  @override
  Future<void> permanentlyDelete(String id) => throw UnimplementedError();
  @override
  Future<void> restore(String id) => throw UnimplementedError();
  @override
  Future<List<Note>> search(String query) => throw UnimplementedError();
  @override
  Future<Note> update(Note note) => throw UnimplementedError();
  @override
  Stream<List<Note>> watchAll() => throw UnimplementedError();
  @override
  Stream<List<Note>> watchByFolder(String folderId) =>
      throw UnimplementedError();
  @override
  Stream<List<Note>> watchRecent({int limit = 5}) => throw UnimplementedError();
}

class _FakeSettingsRepository implements SettingsRepository {
  var _settings = AppSettings.defaults();

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<AppSettings> save(AppSettings settings) async {
    _settings = settings;
    return settings;
  }
}

class _FakeTimelineTaskRepository implements TimelineTaskRepository {
  @override
  Future<TimelineTask> create(TimelineTaskDraft draft) =>
      throw UnimplementedError();

  @override
  Future<void> delete(String id) => throw UnimplementedError();

  @override
  Future<TimelineTask?> findById(String id) async {
    if (id != 'task-1') return null;
    final now = DateTime.now();
    return TimelineTask(
      id: id,
      title: '准备设计评审',
      description: '',
      taskDate: now,
      startAt: now.add(const Duration(hours: 2)),
      endAt: null,
      importance: TimelineImportance.medium,
      colorArgb: TimelineTaskDefaults.mediumColorArgb,
      isCompleted: false,
      isStarred: false,
      isDeleted: false,
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<TimelineTask>> listRange({
    required DateTime startDate,
    required DateTime endDate,
  }) => throw UnimplementedError();

  @override
  Future<List<TimelineTask>> search(String query) => throw UnimplementedError();

  @override
  Future<TimelineTask> update(TimelineTask task) => throw UnimplementedError();

  @override
  Stream<List<TimelineTask>> watchByDate(DateTime date) =>
      throw UnimplementedError();

  @override
  Stream<List<TimelineTask>> watchRange({
    required DateTime startDate,
    required DateTime endDate,
  }) => throw UnimplementedError();
}

class _FakeStartupPermissionService implements StartupPermissionService {
  _FakeStartupPermissionService({
    this.status = const StartupPermissionStatus(
      notificationsGranted: true,
      exactAlarmsGranted: true,
      microphoneGranted: true,
    ),
  });

  final StartupPermissionStatus status;

  @override
  Future<StartupPermissionStatus> checkStatus() async => status;

  @override
  Future<StartupPermissionStatus> requestAll() async => status;

  @override
  Future<StartupPermissionStatus?> requestAtFirstLaunch() async => status;
}
