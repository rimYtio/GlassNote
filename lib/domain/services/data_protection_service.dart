abstract interface class DataProtectionService {
  String protectText(String plainText);

  String revealText(String protectedText);
}

abstract interface class SecureKeyValueStore {
  Future<bool> writeSecret({required String key, required String value});

  Future<String?> readSecret(String key);

  Future<void> deleteSecret(String key);
}
