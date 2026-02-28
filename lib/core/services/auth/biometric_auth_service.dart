import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService(LocalAuthentication());
});

class BiometricAuthService {
  final LocalAuthentication _localAuthentication;

  BiometricAuthService(this._localAuthentication);

  Future<bool> canUseBiometrics() async {
    try {
      final canCheck = await _localAuthentication.canCheckBiometrics;
      final available = await _localAuthentication.getAvailableBiometrics();
      return canCheck && available.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  Future<bool> authenticate() async {
    try {
      return await _localAuthentication.authenticate(
        localizedReason: 'Authenticate to sign in quickly',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          sensitiveTransaction: false,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}
