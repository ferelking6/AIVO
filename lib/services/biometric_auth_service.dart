import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:aivo/utils/app_logger.dart';

class BiometricAuthService {
  static final BiometricAuthService _instance = BiometricAuthService._internal();

  factory BiometricAuthService() {
    return _instance;
  }

  static BiometricAuthService get instance => _instance;

  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final _secureStorage = const FlutterSecureStorage();

  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _emailKey = 'stored_email';
  static const String _pinHashKey = 'pin_hash';
  static const String _pinEnabledKey = 'pin_enabled';
  static const String _authMethodKey = 'auth_method'; // 'biometric', 'pin', or 'both'

  // ==================== Biometric Methods ====================

  /// Check if device supports biometrics
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      AppLogger.error('Biometric check failed: $e', tag: 'BiometricAuth');
      return false;
    }
  }

  /// Get list of available biometrics
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      AppLogger.error('Getting available biometrics failed: $e', tag: 'BiometricAuth');
      return [];
    }
  }

  /// Check if device has facial recognition
  Future<bool> hasFaceID() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.face);
  }

  /// Check if device has fingerprint unlock
  Future<bool> hasFingerprint() async {
    final biometrics = await getAvailableBiometrics();
    return biometrics.contains(BiometricType.fingerprint);
  }

  /// Authenticate with biometrics
  Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = false,
  }) async {
    try {
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          stickyAuth: stickyAuth,
          biometricOnly: true,
          useErrorDialogs: useErrorDialogs,
        ),
      );
      return isAuthenticated;
    } catch (e) {
      AppLogger.error('Authentication failed: $e', tag: 'BiometricAuth');
      return false;
    }
  }

  // ==================== PIN Methods ====================

  /// Hash PIN using SHA256
  String _hashPin(String pin) {
    return sha256.convert(utf8.encode(pin)).toString();
  }

  /// Setup PIN for device
  Future<bool> setupPin(String pin) async {
    try {
      if (pin.length < 4 || pin.length > 6) {
        throw Exception('PIN must be between 4 and 6 digits');
      }

      final pinHash = _hashPin(pin);
      await _secureStorage.write(key: _pinHashKey, value: pinHash);
      await _secureStorage.write(key: _pinEnabledKey, value: 'true');
      AppLogger.log('PIN setup successfully', tag: 'BiometricAuth');
      return true;
    } catch (e) {
      AppLogger.error('Failed to setup PIN: $e', tag: 'BiometricAuth');
      return false;
    }
  }

  /// Verify PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final storedHash =
          await _secureStorage.read(key: _pinHashKey);
      if (storedHash == null) return false;

      final pinHash = _hashPin(pin);
      return pinHash == storedHash;
    } catch (e) {
      AppLogger.error('PIN verification failed: $e', tag: 'BiometricAuth');
      return false;
    }
  }

  /// Check if PIN is enabled
  Future<bool> isPinEnabled() async {
    try {
      final value = await _secureStorage.read(key: _pinEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Update PIN
  Future<bool> updatePin(String oldPin, String newPin) async {
    try {
      final isValid = await verifyPin(oldPin);
      if (!isValid) {
        throw Exception('Current PIN is incorrect');
      }

      return await setupPin(newPin);
    } catch (e) {
      AppLogger.error('Failed to update PIN: $e', tag: 'BiometricAuth');
      return false;
    }
  }

  /// Disable PIN
  Future<void> disablePin() async {
    try {
      await _secureStorage.delete(key: _pinHashKey);
      await _secureStorage.delete(key: _pinEnabledKey);
      AppLogger.log('PIN disabled', tag: 'BiometricAuth');
    } catch (e) {
      AppLogger.error('Failed to disable PIN: $e', tag: 'BiometricAuth');
    }
  }

  // ==================== Combined Auth Methods ====================

  /// Enable biometric login
  Future<void> enableBiometricLogin(String email) async {
    try {
      await _secureStorage.write(key: _biometricEnabledKey, value: 'true');
      await _secureStorage.write(key: _emailKey, value: email);
      AppLogger.log('Biometric login enabled for: $email', tag: 'BiometricAuth');
    } catch (e) {
      AppLogger.error('Failed to enable biometric login: $e', tag: 'BiometricAuth');
    }
  }

  /// Disable biometric login
  Future<void> disableBiometricLogin() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      AppLogger.log('Biometric login disabled', tag: 'BiometricAuth');
    } catch (e) {
      AppLogger.error('Failed to disable biometric login: $e', tag: 'BiometricAuth');
    }
  }

  /// Check if biometric login is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final value = await _secureStorage.read(key: _biometricEnabledKey);
      return value == 'true';
    } catch (e) {
      return false;
    }
  }

  /// Get stored email
  Future<String?> getStoredEmail() async {
    try {
      return await _secureStorage.read(key: _emailKey);
    } catch (e) {
      return null;
    }
  }

  /// Perform biometric login
  Future<String?> biometricLogin() async {
    try {
      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) return null;

      final canAuth = await canCheckBiometrics();
      if (!canAuth) return null;

      final isAuthenticated = await authenticate(
        reason: 'Authenticate to login with biometric',
      );

      if (isAuthenticated) {
        return await getStoredEmail();
      }

      return null;
    } catch (e) {
      AppLogger.error('Biometric login failed: $e', tag: 'BiometricAuth');
      return null;
    }
  }

  /// Perform PIN login
  Future<String?> pinLogin(String pin) async {
    try {
      final isPinValid = await verifyPin(pin);
      if (!isPinValid) {
        return null;
      }

      final email = await getStoredEmail();
      return email;
    } catch (e) {
      AppLogger.error('PIN login failed: $e', tag: 'BiometricAuth');
      return null;
    }
  }

  /// Get available login methods
  Future<List<String>> getAvailableLoginMethods() async {
    final methods = <String>[];

    final canBio = await canCheckBiometrics();
    if (canBio) {
      methods.add('biometric');
    }

    final pinEnabled = await isPinEnabled();
    if (pinEnabled) {
      methods.add('pin');
    }

    return methods;
  }

  /// Get biometric type name
  String getBiometricName(BiometricType type) {
    switch (type) {
      case BiometricType.face:
        return 'Face ID';
      case BiometricType.fingerprint:
        return 'Fingerprint';
      case BiometricType.iris:
        return 'Iris';
      case BiometricType.strong:
        return 'Biometric';
      case BiometricType.weak:
        return 'Weak Biometric';
    }
  }

  /// Clear all auth data
  Future<void> clearAllAuthData() async {
    try {
      await _secureStorage.delete(key: _biometricEnabledKey);
      await _secureStorage.delete(key: _emailKey);
      await _secureStorage.delete(key: _pinHashKey);
      await _secureStorage.delete(key: _pinEnabledKey);
      await _secureStorage.delete(key: _authMethodKey);
      AppLogger.log('All auth data cleared', tag: 'BiometricAuth');
    } catch (e) {
      AppLogger.error('Error clearing auth data: $e', tag: 'BiometricAuth');
    }
  }
}
