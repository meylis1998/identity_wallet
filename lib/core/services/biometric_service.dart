import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class BiometricAuthResult {
  final bool success;
  final String? errorMessage;
  final BiometricErrorType? errorType;

  const BiometricAuthResult({
    required this.success,
    this.errorMessage,
    this.errorType,
  });

  factory BiometricAuthResult.authenticated() =>
      const BiometricAuthResult(success: true);

  factory BiometricAuthResult.failed(String message, BiometricErrorType type) =>
      BiometricAuthResult(success: false, errorMessage: message, errorType: type);
}

enum BiometricErrorType {
  notAvailable,
  notEnrolled,
  lockedOut,
  cancelled,
  passcodeNotSet,
  unknown,
}

class BiometricService {
  final LocalAuthentication _localAuth;

  BiometricService({LocalAuthentication? localAuth})
      : _localAuth = localAuth ?? LocalAuthentication();

  Future<bool> isAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics ||
          await _localAuth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException {
      return [];
    }
  }

  Future<String> getBiometricTypeName() async {
    final types = await getAvailableBiometrics();
    if (types.isEmpty) return 'Biometrics';

    final first = types.first;
    if (first == BiometricType.face) {
      return 'Face ID';
    } else if (first == BiometricType.fingerprint) {
      return 'Touch ID';
    } else if (first == BiometricType.iris) {
      return 'Iris';
    }
    return 'Biometrics';
  }

  Future<BiometricAuthResult> authenticate({
    required String reason,
    bool biometricOnly = false,
  }) async {
    try {
      final isAvailable = await this.isAvailable();
      if (!isAvailable) {
        return BiometricAuthResult.failed(
          'Biometric authentication is not available on this device',
          BiometricErrorType.notAvailable,
        );
      }

      final authenticated = await _localAuth.authenticate(
        localizedReason: reason,
        biometricOnly: biometricOnly,
        sensitiveTransaction: true,
        persistAcrossBackgrounding: true,
      );

      if (authenticated) {
        return BiometricAuthResult.authenticated();
      } else {
        return BiometricAuthResult.failed(
          'Authentication failed',
          BiometricErrorType.unknown,
        );
      }
    } on PlatformException catch (e) {
      return _handlePlatformException(e);
    }
  }

  Future<BiometricAuthResult> authenticateForCredential() async {
    return authenticate(
      reason: 'Authenticate to access your credentials',
      biometricOnly: false,
    );
  }

  Future<BiometricAuthResult> authenticateForPresentation() async {
    return authenticate(
      reason: 'Authenticate to present your credential',
      biometricOnly: true,
    );
  }

  Future<BiometricAuthResult> authenticateForSensitiveOperation() async {
    return authenticate(
      reason: 'Authenticate to continue with this sensitive operation',
      biometricOnly: true,
    );
  }

  BiometricAuthResult _handlePlatformException(PlatformException e) {
    switch (e.code) {
      case 'NotAvailable':
        return BiometricAuthResult.failed(
          'Biometric authentication is not available',
          BiometricErrorType.notAvailable,
        );
      case 'NotEnrolled':
        return BiometricAuthResult.failed(
          'No biometrics enrolled. Please set up biometrics in your device settings.',
          BiometricErrorType.notEnrolled,
        );
      case 'LockedOut':
        return BiometricAuthResult.failed(
          'Too many failed attempts. Please try again later.',
          BiometricErrorType.lockedOut,
        );
      case 'PermanentlyLockedOut':
        return BiometricAuthResult.failed(
          'Biometrics permanently locked. Please use device passcode.',
          BiometricErrorType.lockedOut,
        );
      case 'PasscodeNotSet':
        return BiometricAuthResult.failed(
          'Please set up a device passcode to use biometrics.',
          BiometricErrorType.passcodeNotSet,
        );
      default:
        return BiometricAuthResult.failed(
          e.message ?? 'An unknown error occurred',
          BiometricErrorType.unknown,
        );
    }
  }

  Future<void> cancelAuthentication() async {
    await _localAuth.stopAuthentication();
  }
}
