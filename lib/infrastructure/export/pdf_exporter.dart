import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfExporter {
  Future<File> export(
    String title,
    String content, {
    List<String>? imagePaths,
    DateTime? createdAt,
  }) async {
    final document = pw.Document();

    final font = await _loadFont();
    final theme = font != null
        ? pw.ThemeData.withFont(base: font)
        : pw.ThemeData.withFont(base: pw.Font.helvetica());

    document.addPage(
      pw.MultiPage(
        theme: theme,
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          final imageWidgets = <pw.Widget>[];
          for (final path in imagePaths ?? const <String>[]) {
            final file = File(path);
            if (!file.existsSync()) continue;
            imageWidgets.add(
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 14),
                child: pw.Image(
                  pw.MemoryImage(file.readAsBytesSync()),
                  fit: pw.BoxFit.contain,
                ),
              ),
            );
          }
          return [
            pw.Header(
              level: 0,
              child: pw.Text(
                title.isNotEmpty ? title : '无标题笔记',
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            if (createdAt != null)
              pw.Paragraph(
                text: '创建日期: ${_formatDate(createdAt)}',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600),
              ),
            pw.SizedBox(height: 16),
            pw.Paragraph(
              text: content.isNotEmpty ? content : '（无内容）',
              style: const pw.TextStyle(fontSize: 12, lineSpacing: 1.5),
            ),
            ...imageWidgets,
          ];
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final safeTitle = _sanitiseFileName(title.isNotEmpty ? title : 'note');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = '${safeTitle}_$timestamp.pdf';
    final file = File('${exportDir.path}/$fileName');

    await file.writeAsBytes(await document.save());
    return file;
  }

  Future<pw.Font?> _loadFont() async {
    try {
      final fontData = await rootBundle.load(
        'assets/fonts/NotoSansSC-Regular.ttf',
      );
      return pw.Font.ttf(fontData);
    } catch (_) {
      return null;
    }
  }

  String _formatDate(DateTime date) {
    final y = date.year.toString();
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $h:$min';
  }

  String _sanitiseFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }
}
