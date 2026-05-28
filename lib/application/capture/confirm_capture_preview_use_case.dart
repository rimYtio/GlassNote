import 'dart:convert';

import '../../domain/entities/capture_draft_preview.dart';
import '../../domain/entities/folder.dart';
import '../../domain/entities/note.dart';
import '../../domain/entities/timeline_task.dart';
import '../../domain/repositories/folder_repository.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/timeline_task_repository.dart';

class ConfirmCapturePreviewUseCase {
  const ConfirmCapturePreviewUseCase({
    required this.notes,
    required this.folders,
    required this.tasks,
  });

  final NoteRepository notes;
  final FolderRepository folders;
  final TimelineTaskRepository tasks;

  Future<Object> call(CaptureDraftPreview preview) {
    return switch (preview.type) {
      CaptureDraftType.note => _createNote(preview),
      CaptureDraftType.task => _createTask(preview),
    };
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

  Future<TimelineTask> _createTask(CaptureDraftPreview preview) {
    final taskDate = preview.taskDate!;
    return tasks.create(
      TimelineTaskDraft(
        title: preview.title,
        description: preview.content,
        taskDate: taskDate,
        startAt: preview.startTime?.onDate(taskDate),
        endAt: preview.endTime?.onDate(taskDate),
        importance: preview.importance ?? TimelineImportance.medium,
      ),
    );
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
