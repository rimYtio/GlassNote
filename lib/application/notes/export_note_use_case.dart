import 'dart:io';

import '../../domain/entities/note.dart';
import '../../infrastructure/export/pdf_exporter.dart';

enum ExportFormat { pdf, png }

class ExportNoteUseCase {
  const ExportNoteUseCase(this._pdfExporter);

  final PdfExporter _pdfExporter;

  Future<File> exportPdf(Note note) async {
    return _pdfExporter.export(
      note.title,
      note.plainText,
      createdAt: note.createdAt,
    );
  }
}
