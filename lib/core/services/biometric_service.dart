import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

// local_auth is not supported on web — guard all calls with kIsWeb
import 'package:local_auth/local_auth.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  /// Returns true only on mobile (Android/iOS) with enrolled biometrics.
  /// Always returns false on web — local_auth has no web implementation.
  Future<bool> isAvailable() async {
    if (kIsWeb) return false;           // ← web guard
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isSupported = await _auth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;
      final enrolled = await _auth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } on PlatformException {
      return false;
    } catch (_) {
      return false;                      // catches MissingPluginException too
    }
  }

  Future<bool> authenticate() async {
    if (kIsWeb) return false;
    try {
      return await _auth.authenticate(
        localizedReason: 'Authenticate to access ProFinch Bank',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('BiometricService: ${e.code} — ${e.message}');
      return false;
    } catch (_) {
      return false;
    }
  }
}