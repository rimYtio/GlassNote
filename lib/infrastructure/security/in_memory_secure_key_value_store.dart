import '../../domain/services/data_protection_service.dart';

class InMemorySecureKeyValueStore implements SecureKeyValueStore {
  final _values = <String, String>{};

  @override
  Future<void> deleteSecret(String key) async {
    _values.remove(key);
  }

  @override
  Future<String?> readSecret(String key) async {
    return _values[key];
  }

  @override
  Future<void> writeSecret({required String key, required String value}) async {
    _values[key] = value;
  }
}
