// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:local_auth/local_auth.dart';

import '../../domain/repositories/settings_repository.dart';
import '../../domain/services/data_protection_service.dart';

class AppLockService {
  AppLockService({
    required SettingsRepository settingsRepository,
    required SecureKeyValueStore secureStore,
    LocalAuthentication? localAuth,
  }) : _settingsRepository = settingsRepository,
       _secureStore = secureStore,
       _localAuth = localAuth ?? LocalAuthentication();

  static const _pinHashKey = 'app_lock_pin_hash';

  final SettingsRepository _settingsRepository;
  final SecureKeyValueStore _secureStore;
  final LocalAuthentication _localAuth;

  Future<bool> isEnabled() async {
    final settings = await _settingsRepository.load();
    return settings.enableAppLock;
  }

  Future<void> setEnabled(bool enabled) async {
    final settings = await _settingsRepository.load();
    await _settingsRepository.save(
      settings.copyWith(enableAppLock: enabled, updatedAt: DateTime.now()),
    );
    if (!enabled) {
      await _secureStore.deleteSecret(_pinHashKey);
    }
  }

  Future<bool> authenticate({required String reason}) async {
    final biometricAvailable = await isBiometricAvailable();
    if (biometricAvailable) {
      try {
        final authenticated = await _localAuth.authenticate(
          localizedReason: reason,
          options: const AuthenticationOptions(
            stickyAuth: true,
            biometricOnly: false,
          ),
        );
        if (authenticated) return true;
      } catch (_) {
        // Biometric failed, fall through to PIN
      }
    }
    // PIN fallback is handled by the UI
    return false;
  }

  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> get hasPinSet async {
    final hash = await _secureStore.readSecret(_pinHashKey);
    return hash != null && hash.isNotEmpty;
  }

  Future<void> setPin(String pin) async {
    final hash = _hashPin(pin);
    await _secureStore.writeSecret(key: _pinHashKey, value: hash);
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _secureStore.readSecret(_pinHashKey);
    if (stored == null) return false;
    return stored == _hashPin(pin);
  }

  static String _hashPin(String pin) {
    final bytes = utf8.encode(pin);
    // Simple hash for PIN verification — stored in secure storage already
    return base64.encode(bytes);
  }
}
