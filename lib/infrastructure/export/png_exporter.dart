import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class PngExporter {
  Future<File> exportFromWidget(GlobalKey repaintKey, String fileName) async {
    final boundary =
        repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      throw StateError('RepaintBoundary not found in widget tree');
    }

    final image = await boundary.toImage(pixelRatio: 2.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    if (byteData == null) {
      throw StateError('Failed to convert image to PNG bytes');
    }

    final directory = await getApplicationDocumentsDirectory();
    final exportDir = Directory('${directory.path}/exports');
    if (!await exportDir.exists()) {
      await exportDir.create(recursive: true);
    }

    final safeName = _sanitiseFileName(fileName);
    final file = File('${exportDir.path}/$safeName.png');
    await file.writeAsBytes(byteData.buffer.asUint8List());
    return file;
  }

  String _sanitiseFileName(String name) {
    return name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_').trim();
  }
}
