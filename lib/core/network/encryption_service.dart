import 'api_client.dart';
import 'api_endpoints.dart';
import 'api_exception.dart';
import 'rsa_pkcs1_encryptor.dart';

/// Reproduces the 3-step encryption flow seen in the Postman collection's
/// "Login" folder, in this exact order:
///   1. GET  /digx-admin/security/v1/publicKey  → RSA public key
///   2. POST /digx-admin/security/v1/salt       → salt
///   3. RSA/PKCS1-v1.5 encrypt "$password $salt" locally, in Dart
///
/// Step 3 used to call an external Node/node-forge microservice
/// (`http://localhost:3000/encrypt`). That service did exactly this:
/// `publicKey.encrypt(utf8("$password $salt"), "RSAES-PKCS1-V1_5")`,
/// base64-encoded. [RsaPkcs1Encryptor] reproduces that byte-for-byte in
/// pure Dart, so there's no separate process/port to run anymore.
class EncryptionService {
  EncryptionService._();
  static final EncryptionService instance = EncryptionService._();

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
      // Exactly matches encrypt.js: `${password} ${salt}` (space-joined),
      // UTF-8 encoded, RSA/PKCS1-v1.5, base64.
      final plainText = '$password $salt';
      return RsaPkcs1Encryptor.encrypt(plainText, publicKey);
    } catch (e) {
      throw ApiException('Failed to encrypt password locally: $e');
    }
  }

  /// Convenience wrapper running all 3 steps.
  Future<String> encryptLoginPassword(String password) async {
    final publicKey = await fetchPublicKey();
    final salt = await fetchSalt();
    return encryptPassword(password: password, salt: salt, publicKey: publicKey);
  }
}