import 'package:flutter/foundation.dart' show kIsWeb;

/// Central place for backend configuration.
///
/// ⚠️ ACTION REQUIRED:
/// Replace [baseUrl] with your actual OBDX gateway URL (the same host you used
/// as `{{base_url}}` in the Postman collection).
///
/// [encryptionServiceUrl] must point to the RSA-encryption microservice used
/// by the "Encryption (external)" request in the Postman collection
/// (it was `http://localhost:3000/encrypt` there). A mobile device/emulator
/// cannot reach your laptop's `localhost`, so this MUST be either:
///   - your machine's LAN IP (e.g. http://192.168.1.20:3000/encrypt) for
///     local testing on a real device, or
///   - `http://10.0.2.2:3000/encrypt` for the Android emulator, or
///   - a properly deployed URL once this helper service is hosted.
class ApiConfig {
  ApiConfig._();

  /// OBDX API gateway base URL.
  ///
  /// ── Web ──────────────────────────────────────────────────────
  /// MUST be empty (relative) when running via `obdx-dev-proxy`. The
  /// browser enforces SameSite=Strict on OBDX's session cookie, so the web
  /// app has to be loaded from the SAME origin the API is served from
  /// (http://localhost:8080, the proxy) — pointing straight at the OBDX
  /// host directly from a different origin will always 401 on /me.
  /// Run: flutter run -d chrome --web-port 5000 --web-hostname 127.0.0.1
  /// then open the app via the proxy at http://localhost:8080, not the
  /// port Flutter prints.
  ///
  /// ── Mobile / desktop ─────────────────────────────────────────
  /// Not subject to SameSite/CORS at all (that's a browser-only concept),
  /// so keep the direct OBDX host here — dio_cookie_manager in
  /// api_client.dart already resends the session cookie automatically.
  ///
  /// Override either at build/run time, e.g.:
  ///   flutter run -d chrome --dart-define=OBDX_BASE_URL=
  ///   flutter run -d emulator-5554 --dart-define=OBDX_BASE_URL=http://10.20.9.17:7778
  static const String baseUrl = String.fromEnvironment(
    'OBDX_BASE_URL',
    defaultValue: kIsWeb ? '' : 'http://10.20.9.17:7778',
  );

  /// Helper microservice that RSA-encrypts the password before login.
  // static const String encryptionServiceUrl = String.fromEnvironment(
  //   'ENCRYPTION_SERVICE_URL',
  //   defaultValue: 'http://localhost:3000/encrypt',
  // );

  /// Standard OBDX headers required on almost every authenticated call.
  static const String targetUnit = 'OBDX_BU';
  static const String locale = 'en';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}