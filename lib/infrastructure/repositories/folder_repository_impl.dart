import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/folder.dart';
import '../../domain/repositories/folder_repository.dart';
import '../database/app_database.dart';

class FolderRepositoryImpl implements FolderRepository {
  const FolderRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<Folder> ensureUncategorized() {
    return _database.foldersDao.ensureUncategorized();
  }

  @override
  Future<Folder> create(FolderDraft draft) {
    final now = DateTime.now();
    return _database.foldersDao.createFolder(
      FolderRowsCompanion.insert(
        id: const Uuid().v4(),
        name: draft.name.trim(),
        parentId: Value(draft.parentId),
        sortOrder: now.microsecondsSinceEpoch,
        isSystem: false,
        isStarred: const Value(false),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<Folder> update(Folder folder) {
    return _database.foldersDao.updateFolder(
      folder.copyWith(updatedAt: DateTime.now()),
    );
  }

  @override
  Future<void> delete(String id) {
    return _database.foldersDao.deleteFolder(id);
  }

  @override
  Future<Folder?> findById(String id) {
    return _database.foldersDao.findById(id);
  }

  @override
  Future<List<Folder>> listAll() {
    return _database.foldersDao.listAll();
  }

  @override
  Stream<List<Folder>> watchRootFolders() {
    return _database.foldersDao.watchRootFolders();
  }
}
