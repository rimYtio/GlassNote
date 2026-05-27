import '../entities/folder.dart';

abstract interface class FolderRepository {
  Future<Folder> ensureUncategorized();

  Future<Folder> create(FolderDraft draft);

  Future<void> delete(String id);

  Future<Folder?> findById(String id);

  Future<List<Folder>> listAll();

  Stream<List<Folder>> watchRootFolders();
}
