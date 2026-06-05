import 'dart:convert';

import '../../domain/entities/capture_draft_preview.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/timeline_task.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/timeline_task_repository.dart';
import '../timeline/ensure_task_default_reminder_use_case.dart';

class ConfirmCapturePreviewUseCase {
  const ConfirmCapturePreviewUseCase({
    required this.notes,
    required this.folders,
    required this.tasks,
    this.defaultReminder,
  });

  final NoteRepository notes;
  final FolderRepository folders;
  final TimelineTaskRepository tasks;
  final EnsureTaskDefaultReminderUseCase? defaultReminder;

  Future<void> call(List<CaptureDraftPreview> previews) async {
    for (final preview in previews) {
      try {
        await switch (preview.type) {
          CaptureDraftType.note => _createNote(preview),
          CaptureDraftType.task => _createTask(preview),
        };
      } on Object {
        // Continue with remaining items on partial failure.
      }
    }
  }

  Future<Note> _createNote(CaptureDraftPreview preview) async {
    final folderId = await _folderIdFor(preview.folderName);
    return notes.create(
      NoteDraft(
        title: preview.title,
        plainText: preview.content,
        richContentJson: jsonEncode({'type': 'plain', 'text': preview.content}),
        folderId: folderId,
      ),
    );
  }

  Future<TimelineTask> _createTask(CaptureDraftPreview preview) async {
    final taskDate = preview.taskDate;
    if (taskDate == null) {
      throw StateError('任务日期缺失，无法创建');
    }
    final task = await tasks.create(
      TimelineTaskDraft(
        title: preview.title,
        description: preview.content,
        taskDate: taskDate,
        startAt: preview.startTime?.onDate(taskDate),
        endAt: preview.endTime?.onDate(taskDate),
        importance: preview.importance ?? TimelineImportance.medium,
      ),
    );
    try {
      await defaultReminder?.call(task);
    } on Object {
      // A reminder failure must not block creating the captured task.
    }
    return task;
  }

  Future<String> _folderIdFor(String? folderName) async {
    final name = folderName?.trim();
    if (name == null || name.isEmpty) {
      await folders.ensureUncategorized();
      return Folder.uncategorizedId;
    }

    for (final folder in await folders.listAll()) {
      if (!folder.isSystem && folder.name.trim() == name) {
        return folder.id;
      }
    }

    final created = await folders.create(
      FolderDraft(name: name, parentId: null),
    );
    return created.id;
  }
}
