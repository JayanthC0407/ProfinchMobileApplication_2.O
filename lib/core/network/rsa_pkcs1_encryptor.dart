import 'dart:convert';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:pointycastle/export.dart';

/// Pure-Dart replacement for the old `encrypt.js` / node-forge microservice.
///
/// Mirrors it exactly:
///   1. Parse the SPKI/X.509 public key (the base64 blob OBDX returns from
///      /publicKey, wrapped as a PEM) with `basic_utils`.
///   2. RSA-encrypt with PKCS#1 v1.5 padding — this is what node-forge's
///      `"RSAES-PKCS1-V1_5"` option means. NOTE: don't use
///      `CryptoUtils.rsaEncrypt` from basic_utils for this — that helper
///      calls the raw `RSAEngine` with NO padding, which is a different
///      (and incompatible) operation. Wrap `RSAEngine` in `PKCS1Encoding`
///      yourself, as done below.
///   3. Base64-encode the ciphertext.
class RsaPkcs1Encryptor {
  RsaPkcs1Encryptor._();

  /// [plainText] should already be the combined `"$password $salt"` string
  /// (space-separated, matching encrypt.js's template literal exactly).
  /// [base64SpkiPublicKey] is the raw `publicKeyDTO.publicKey` value from
  /// OBDX's /publicKey response (no PEM header/footer — those are added
  /// here).
  static String encrypt(String plainText, String base64SpkiPublicKey) {
    final pem =
        '-----BEGIN PUBLIC KEY-----\n$base64SpkiPublicKey\n-----END PUBLIC KEY-----';
    final publicKey = CryptoUtils.rsaPublicKeyFromPem(pem);

    final cipher = PKCS1Encoding(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));

    final input = Uint8List.fromList(utf8.encode(plainText));
    final output = _processInBlocks(cipher, input);
    return base64Encode(output);
  }

  /// RSA is a block cipher under the hood; PKCS1Encoding caps how many
  /// plaintext bytes fit per block (modulus size minus 11 bytes of padding
  /// overhead). password+salt is short enough to always fit in one block
  /// for a 2048-bit key, but this loops properly in case of a smaller key
  /// or a longer salt/password down the line.
  static Uint8List _processInBlocks(
    AsymmetricBlockCipher engine,
    Uint8List input,
  ) {
    final numBlocks = (input.length / engine.inputBlockSize).ceil().clamp(
          1,
          1 << 30,
        );
    final output = Uint8List(numBlocks * engine.outputBlockSize);

    var inputOffset = 0;
    var outputOffset = 0;
    while (inputOffset < input.length) {
      final chunkSize = (inputOffset + engine.inputBlockSize <= input.length)
          ? engine.inputBlockSize
          : input.length - inputOffset;
      outputOffset += engine.processBlock(
        input,
        inputOffset,
        chunkSize,
        output,
        outputOffset,
      );
      inputOffset += chunkSize;
    }
    return output.sublist(0, outputOffset);
  }
}