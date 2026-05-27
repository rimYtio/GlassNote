class Folder {
  const Folder({
    required this.id,
    required this.name,
    required this.parentId,
    required this.sortOrder,
    required this.isSystem,
    required this.createdAt,
    required this.updatedAt,
  });

  static const uncategorizedId = 'uncategorized';

  final String id;
  final String name;
  final String? parentId;
  final int sortOrder;
  final bool isSystem;
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isSystem: isSystem ?? this.isSystem,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class FolderDraft {
  const FolderDraft({required this.name, required this.parentId});

  final String name;
  final String? parentId;
}
