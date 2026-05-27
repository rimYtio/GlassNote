import '../../domain/entities/folder.dart';

class BuildFolderPathUseCase {
  const BuildFolderPathUseCase();

  List<String> call({
    required String? folderId,
    required List<Folder> folders,
  }) {
    final byId = {for (final folder in folders) folder.id: folder};
    final names = <String>['笔记'];
    var current = folderId == null ? null : byId[folderId];

    while (current != null) {
      names.insert(1, current.name);
      final parentId = current.parentId;
      current = parentId == null ? null : byId[parentId];
    }

    return names;
  }
}
