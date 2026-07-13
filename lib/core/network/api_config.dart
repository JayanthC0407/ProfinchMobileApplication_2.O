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

  /// OBDX API gateway base URL, e.g. https://obdxhost:port
  static const String baseUrl = String.fromEnvironment(
    'OBDX_BASE_URL',
    defaultValue: 'http://10.20.9.17:7778',
  );

  /// Helper microservice that RSA-encrypts the password before login.
  static const String encryptionServiceUrl = String.fromEnvironment(
    'ENCRYPTION_SERVICE_URL',
    defaultValue: 'http://localhost:3000/encrypt',
  );

  /// Standard OBDX headers required on almost every authenticated call.
  static const String targetUnit = 'OBDX_BU';
  static const String locale = 'en';

  static const Duration connectTimeout = Duration(seconds: 20);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
