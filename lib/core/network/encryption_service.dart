import 'package:dio/dio.dart';

import 'api_client.dart';
import 'api_config.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';

/// Reproduces the 3-step encryption flow seen in the Postman collection's
/// "Login" folder, in this exact order:
///   1. GET  /digx-admin/security/v1/publicKey  → RSA public key
///   2. POST /digx-admin/security/v1/salt       → salt
///   3. POST {encryptionServiceUrl}              → encrypted password
///
/// Step 3 hits the small external helper service you already built
/// (`http://localhost:3000/encrypt` in Postman) rather than doing RSA
/// padding in Dart directly, since that service already exists and is
/// proven to match what your OBDX backend expects to decrypt.
class EncryptionService {
  EncryptionService._();
  static final EncryptionService instance = EncryptionService._();

  final Dio _plainDio = Dio(); // separate client — no OBDX headers/base URL

  Future<String> fetchPublicKey() async {
    final result = await ApiClient.instance.get(ApiEndpoints.rsaPublicKey);
    // Real OBDX shape confirmed from a live response:
    // { "status": {...}, "publicKeyDTO": { "publicKey": "...", "modulus": "...", "publicExponent": "..." } }
    final publicKeyDTO = result['publicKeyDTO'];
    final key = (publicKeyDTO is Map ? publicKeyDTO['publicKey'] : null) ??
        result['publicKey'] ??
        result['key'] ??
        result['data'];
    if (key == null) {
      throw ApiException('RSA public key missing from server response.');
    }
    return key.toString();
  }

  Future<String> fetchSalt() async {
    final result = await ApiClient.instance.post(ApiEndpoints.salt, data: {});
    // Confirmed live shape:
    // { "status": {...}, "saltDTO": { "id": "...", "version": 1, ... } }
    final saltDTO = result['saltDTO'];
    final salt = (saltDTO is Map ? (saltDTO['id'] ?? saltDTO['salt']) : null) ??
        result['salt'] ??
        result['data'];
    if (salt == null) {
      throw ApiException('Salt missing from server response.');
    }
    return salt.toString();
  }

  Future<String> encryptPassword({
    required String password,
    required String salt,
    required String publicKey,
  }) async {
    try {
      final response = await _plainDio.post(
        ApiConfig.encryptionServiceUrl,
        data: {
          'password': password,
          'salt': salt,
          'publicKey': publicKey,
        },
        options: Options(contentType: 'application/json'),
      );
      final data = response.data;
      final encrypted = data is Map
          ? (data['encryptedPassword'] ?? data['password'] ?? data['data'])
          : data;
      if (encrypted == null) {
        throw ApiException('Encryption service returned no ciphertext.');
      }
      return encrypted.toString();
    } on DioException catch (e) {
      throw ApiException(
        'Could not reach the encryption service at '
        '${ApiConfig.encryptionServiceUrl}. Is it running and reachable '
        'from this device? (${e.message})',
      );
    }
  }

  /// Convenience wrapper running all 3 steps.
  Future<String> encryptLoginPassword(String password) async {
    final publicKey = await fetchPublicKey();
    final salt = await fetchSalt();
    return encryptPassword(password: password, salt: salt, publicKey: publicKey);
  }
}