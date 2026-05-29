import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class AttachmentFileStore {
  const AttachmentFileStore();

  Future<String> _attachmentsDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(appDir.path, 'attachments'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir.path;
  }

  Future<String> saveImage(Uint8List bytes, String fileName) async {
    final dir = await _attachmentsDirectory();
    final filePath = p.join(dir, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  Future<String> saveAudio(String tempPath) async {
    final dir = await _attachmentsDirectory();
    final ext = p.extension(tempPath).isEmpty ? '.m4a' : p.extension(tempPath);
    final fileName = '${const Uuid().v4()}$ext';
    final targetPath = p.join(dir, fileName);
    await File(tempPath).copy(targetPath);
    return targetPath;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
