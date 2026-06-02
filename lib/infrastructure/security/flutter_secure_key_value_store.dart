import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/services/data_protection_service.dart';

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  const FlutterSecureKeyValueStore([
    this._storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        resetOnError: true,
      ),
    ),
  ]);

  final FlutterSecureStorage _storage;

  @override
  Future<void> deleteSecret(String key) async {
    try {
      await _storage.delete(key: key).timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('[SecureStorage] delete failed key=$key error=$e');
    }
  }

  @override
  Future<String?> readSecret(String key) async {
    try {
      final value = await _storage.read(key: key).timeout(const Duration(seconds: 3));
      return value;
    } catch (e) {
      debugPrint('[SecureStorage] read failed key=$key error=$e');
      return null;
    }
  }

  @override
  Future<bool> writeSecret({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value).timeout(const Duration(seconds: 5));
      return true;
    } catch (e) {
      debugPrint('[SecureStorage] write failed key=$key len=${value.length} error=$e');
      return false;
    }
  }
}
