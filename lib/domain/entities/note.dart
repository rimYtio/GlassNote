import 'folder.dart';

class Note {
  const Note({
    required this.id,
    required this.title,
    required this.plainText,
    required this.richContentJson,
    required this.folderId,
    required this.isStarred,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String plainText;
  final String richContentJson;
  final String folderId;
  final bool isStarred;
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  Note copyWith({
    String? id,
    String? title,
    String? plainText,
    String? richContentJson,
    String? folderId,
    bool? isStarred,
    bool? isDeleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      plainText: plainText ?? this.plainText,
      richContentJson: richContentJson ?? this.richContentJson,
      folderId: folderId ?? this.folderId,
      isStarred: isStarred ?? this.isStarred,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class NoteDraft {
  NoteDraft({
    required this.title,
    required this.plainText,
    required this.richContentJson,
    String? folderId,
  }) : folderId = folderId ?? Folder.uncategorizedId;

  final String title;
  final String plainText;
  final String richContentJson;
  final String folderId;
}

class NoteSort {
  const NoteSort._();

  static List<Note> sortedForList(Iterable<Note> notes) {
    final sorted = notes.toList();
    sorted.sort((a, b) {
      if (a.isStarred != b.isStarred) {
        return b.isStarred ? 1 : -1;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }
}
