import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/repositories/folder_repository.dart';
import '../../domain/repositories/note_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../database/app_database.dart';
import '../repositories/folder_repository_impl.dart';
import '../repositories/note_repository_impl.dart';
import '../repositories/settings_repository_impl.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(ref.watch(appDatabaseProvider));
});

final folderRepositoryProvider = Provider<FolderRepository>((ref) {
  return FolderRepositoryImpl(ref.watch(appDatabaseProvider));
});

final noteRepositoryProvider = Provider<NoteRepository>((ref) {
  return NoteRepositoryImpl(ref.watch(appDatabaseProvider));
});
