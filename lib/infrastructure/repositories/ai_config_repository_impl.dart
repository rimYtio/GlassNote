import '../../domain/entities/ai_config.dart';
import '../../domain/repositories/ai_config_repository.dart';
import '../database/app_database.dart';

class AiConfigRepositoryImpl implements AiConfigRepository {
  const AiConfigRepositoryImpl(this._database);

  final AppDatabase _database;

  @override
  Future<AiConfig> load() {
    return _database.aiConfigDao.loadConfig();
  }

  @override
  Future<AiConfig> save(AiConfig config) {
    return _database.aiConfigDao.saveConfig(config);
  }
}
