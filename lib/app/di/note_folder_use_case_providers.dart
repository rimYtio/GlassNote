import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/folders/build_folder_path_use_case.dart';
import '../../application/folders/delete_folder_use_case.dart';
import '../../application/notes/create_note_use_case.dart';
import '../../application/notes/list_notes_use_case.dart';
import '../../infrastructure/providers/infrastructure_providers.dart';

final buildFolderPathUseCaseProvider = Provider<BuildFolderPathUseCase>((ref) {
  return const BuildFolderPathUseCase();
});

final createNoteUseCaseProvider = Provider<CreateNoteUseCase>((ref) {
  return CreateNoteUseCase(
    ref.watch(noteRepositoryProvider),
    ref.watch(folderRepositoryProvider),
  );
});

final listNotesUseCaseProvider = Provider<ListNotesUseCase>((ref) {
  return ListNotesUseCase(ref.watch(noteRepositoryProvider));
});

final deleteFolderUseCaseProvider = Provider<DeleteFolderUseCase>((ref) {
  return DeleteFolderUseCase(
    ref.watch(folderRepositoryProvider),
    ref.watch(noteRepositoryProvider),
  );
});
