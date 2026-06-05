import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../application/folders/build_folder_path_use_case.dart';
import '../../application/folders/delete_folder_use_case.dart';
import '../../application/notes/create_note_use_case.dart';
import '../../application/notes/delete_attachment_use_case.dart';
import '../../application/notes/export_note_use_case.dart';
import '../../application/notes/list_notes_use_case.dart';
import '../../application/notes/save_note_audio_attachment_use_case.dart';
import '../../application/notes/save_note_image_attachment_use_case.dart';
import '../../infrastructure/export/pdf_exporter.dart';
import '../../infrastructure/export/png_exporter.dart';
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

final pdfExporterProvider = Provider<PdfExporter>((ref) {
  return PdfExporter();
});

final pngExporterProvider = Provider<PngExporter>((ref) {
  return PngExporter();
});

final exportNoteUseCaseProvider = Provider<ExportNoteUseCase>((ref) {
  return ExportNoteUseCase(ref.watch(pdfExporterProvider));
});

final saveNoteImageAttachmentUseCaseProvider =
    Provider<SaveNoteImageAttachmentUseCase>((ref) {
      return SaveNoteImageAttachmentUseCase(
        attachmentRepository: ref.watch(attachmentRepositoryProvider),
        fileStore: ref.watch(attachmentFileStoreProvider),
      );
    });

final saveNoteAudioAttachmentUseCaseProvider =
    Provider<SaveNoteAudioAttachmentUseCase>((ref) {
      return SaveNoteAudioAttachmentUseCase(
        attachmentRepository: ref.watch(attachmentRepositoryProvider),
        fileStore: ref.watch(attachmentFileStoreProvider),
      );
    });

final deleteAttachmentUseCaseProvider = Provider<DeleteAttachmentUseCase>((
  ref,
) {
  return DeleteAttachmentUseCase(
    attachmentRepository: ref.watch(attachmentRepositoryProvider),
    fileStore: ref.watch(attachmentFileStoreProvider),
  );
});
