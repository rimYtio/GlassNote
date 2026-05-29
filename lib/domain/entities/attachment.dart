enum AttachmentType {
  image,
  audio,
  file,
}

class Attachment {
  const Attachment({
    required this.id,
    required this.noteId,
    required this.type,
    required this.fileName,
    required this.localPath,
    required this.mimeType,
    required this.sizeBytes,
    this.width,
    this.height,
    this.durationMs,
    required this.createdAt,
  });

  final String id;
  final String noteId;
  final AttachmentType type;
  final String fileName;
  final String localPath;
  final String mimeType;
  final int sizeBytes;
  final int? width;
  final int? height;
  final int? durationMs;
  final DateTime createdAt;
}
