import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/services/data_protection_service.dart';

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  const FlutterSecureKeyValueStore([
    this._storage = const FlutterSecureStorage(),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<void> deleteSecret(String key) {
    return _storage.delete(key: key);
  }

  @override
  Future<String?> readSecret(String key) {
    return _storage.read(key: key);
  }

  @override
  Future<void> writeSecret({required String key, required String value}) {
    return _storage.write(key: key, value: value);
  }
}
