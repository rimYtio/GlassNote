import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/folder.dart';
import '../../../domain/entities/note.dart';
import '../../../domain/entities/timeline_task.dart';
import '../../../infrastructure/providers/infrastructure_providers.dart';

final todayTasksProvider = StreamProvider<List<TimelineTask>>((ref) {
  final repo = ref.watch(timelineTaskRepositoryProvider);
  return repo.watchByDate(DateTime.now());
});

final recentNotesProvider = StreamProvider<List<Note>>((ref) {
  final repo = ref.watch(noteRepositoryProvider);
  return repo.watchRecent(limit: 5);
});

class FolderWithCount {
  const FolderWithCount(this.folder, this.noteCount);

  final Folder folder;
  final int noteCount;
}

final topFoldersProvider = StreamProvider<List<FolderWithCount>>((ref) {
  final folderRepo = ref.watch(folderRepositoryProvider);
  final noteRepo = ref.watch(noteRepositoryProvider);

  final controller = StreamController<List<FolderWithCount>>();

  StreamSubscription<List<Folder>>? foldersSub;
  StreamSubscription<List<Note>>? notesSub;

  List<Folder> latestFolders = [];
  List<Note> latestNotes = [];

  void emitCombined() {
    final noteCounts = <String, int>{};
    for (final note in latestNotes) {
      noteCounts[note.folderId] =
          (noteCounts[note.folderId] ?? 0) + 1;
    }

    final result = latestFolders
        .map((f) => FolderWithCount(f, noteCounts[f.id] ?? 0))
        .toList()
      ..sort((a, b) => b.noteCount.compareTo(a.noteCount));

    controller.add(result);
  }

  foldersSub = folderRepo.watchRootFolders().listen((folders) {
    latestFolders = folders;
    emitCombined();
  });

  notesSub = noteRepo.watchAll().listen((notes) {
    latestNotes = notes;
    emitCombined();
  });

  ref.onDispose(() {
    foldersSub?.cancel();
    notesSub?.cancel();
    controller.close();
  });

  return controller.stream;
});
