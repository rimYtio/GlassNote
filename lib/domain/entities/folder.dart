class Folder {
  const Folder({
    required this.id,
    required this.name,
    required this.parentId,
    required this.sortOrder,
    required this.isSystem,
    required this.isStarred,
    required this.createdAt,
    required this.updatedAt,
  });

  static const uncategorizedId = 'uncategorized';

  final String id;
  final String name;
  final String? parentId;
  final int sortOrder;
  final bool isSystem;
  final bool isStarred;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Folder.uncategorized({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return Folder(
      id: uncategorizedId,
      name: '未分类',
      parentId: null,
      sortOrder: 0,
      isSystem: true,
      isStarred: false,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  Folder copyWith({
    String? id,
    String? name,
    String? parentId,
    int? sortOrder,
    bool? isSystem,
    bool? isStarred,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      isStarred: isStarred ?? this.isStarred,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FolderSort {
  const FolderSort._();

  static List<Folder> sortedForList(Iterable<Folder> folders) {
    final sorted = folders.toList();
    sorted.sort((a, b) {
      if (a.isSystem != b.isSystem) {
        return b.isSystem ? 1 : -1;
      }
      if (!a.isSystem && a.isStarred != b.isStarred) {
        return b.isStarred ? 1 : -1;
      }
      final sortCompare = a.sortOrder.compareTo(b.sortOrder);
      if (sortCompare != 0) {
        return sortCompare;
      }
      return a.createdAt.compareTo(b.createdAt);
    });
    return sorted;
  }
}

class FolderDraft {
  const FolderDraft({required this.name, required this.parentId});

  final String name;
  final String? parentId;
}
