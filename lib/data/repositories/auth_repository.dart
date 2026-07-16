import 'package:dio/dio.dart';
import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/core/network/api_exception.dart';
import 'package:profinch_mobile_application/core/network/encryption_service.dart';
import 'package:profinch_mobile_application/core/network/session_manager.dart';
import 'package:profinch_mobile_application/data/dummy/dummy_users.dart';
import 'package:profinch_mobile_application/data/models/user_model.dart';

class AuthRepository {
  // ── LOGIN (tracker item #2 — ready) ─────────────────────────
  //
  // Real flow, confirmed against live responses:
  //   1. fetch RSA public key + salt
  //   2. encrypt password via the external encryption microservice
  //   3. POST /login with { userName, password: encryptedPassword } → JWT
  //   4. GET /me → this step is OTP-gated: first call returns
  //      EXPECTATION_FAILED with the OTP reference number in the
  //      `X-CHALLENGE` response header. The caller must show an OTP
  //      screen, then call [verifyLoginOtp].
  //
  // Because step 4 can pause mid-flow for OTP entry, [login] only does
  // steps 1-3 and returns once the JWT is stored. Fetching the profile is
  // a separate step ([fetchCurrentUser] / [verifyLoginOtp]) so the caller
  // (AuthProvider) can react to the OTP requirement in between.
  Future<void> login({
    required String username,
    required String password,
  }) async {
    final encryptedPassword = await EncryptionService.instance.encryptLoginPassword(password);

    final loginResponse = await ApiClient.instance.post(
      ApiEndpoints.login,
      data: {
        'userName': username,
        'password': encryptedPassword,
      },
      // Confirmed required header from the Postman collection — missing
      // this causes OBDX's generic "System cannot process the request
      // currently" error (DIGX_PROD_DEF_0000) rather than a real auth
      // failure, since the server doesn't know which auth handler to use.
      options: Options(headers: {'x-authentication-type': 'CRED'}),
    );

    // Confirmed live shape: { "status": {...}, "token": "...", "user": "...", "role": "...", "interactionId": "..." }
    final token = loginResponse['token'];
    if (token == null) {
      throw ApiException('Login succeeded but no session token was returned.');
    }
    SessionManager.instance
      ..setToken(token.toString())
      ..username = (loginResponse['user'] ?? username).toString()
      ..interactionId = loginResponse['interactionId']?.toString();
  }

  /// GET /digx-common/user/v1/me
  ///
  /// First call after login typically throws an [ApiException] with
  /// `requiresChallenge = true` — catch that, show an OTP screen, then call
  /// [verifyLoginOtp] rather than retrying this directly.
  Future<UserModel> fetchCurrentUser() async {
    final meResponse = await ApiClient.instance.get(ApiEndpoints.me);
    return UserModel.fromMeResponse(meResponse);
  }

  /// Retries `GET /me` with the OTP the user entered, attached via the
  /// `x-challenge_response` header using the referenceNo captured from the
  /// earlier `X-CHALLENGE` response header (see [SessionManager]).
  Future<UserModel> verifyLoginOtp(String otp) async {
    if (!SessionManager.instance.hasPendingChallenge) {
      throw ApiException('No pending verification found. Please log in again.');
    }
    final meResponse = await ApiClient.instance.get(
      ApiEndpoints.me,
      options: _challengeOptions(otp),
    );
    SessionManager.instance.clearChallenge();
    return UserModel.fromMeResponse(meResponse);
  }

  /// Re-triggers the OTP by calling `/me` again without a challenge header
  /// — OBDX responds with a fresh `X-CHALLENGE` (new referenceNo, and
  /// presumably a newly-sent OTP). There's no dedicated "resend" endpoint
  /// in the collection, so this is the pragmatic equivalent.
  Future<void> resendLoginOtp() async {
    try {
      await ApiClient.instance.get(ApiEndpoints.me);
    } on ApiException catch (e) {
      if (!e.requiresChallenge) rethrow;
      // Expected — a fresh challenge is now stored in SessionManager.
    }
  }

  /// POST /digx-infra/login/v1//logout
  Future<void> logout() async {
    try {
      await ApiClient.instance.post(ApiEndpoints.logout);
    } finally {
      SessionManager.instance.clear();
      // Also drop the locally-held session cookie (mobile/desktop only —
      // see ApiClient.clearCookies doc). Runs regardless of whether the
      // server call above succeeded, same as SessionManager.clear() above.
      await ApiClient.instance.clearCookies();
    }
  }

  // ── FORGOT USERNAME (tracker item #3 — ready) ───────────────
  //
  // UI NOTE: the current forgot_password_screen.dart flow collects an
  // email address only. The real OBDX endpoint needs { emailId, dateOfBirth }
  // and — following the same pattern confirmed for /me — likely responds
  // with an X-CHALLENGE header requiring OTP too. The screens will need a
  // Date-of-Birth field added — happy to do that next.
  Future<void> requestForgotUsername({
    required String email,
    required String dateOfBirth,
  }) async {
    await ApiClient.instance.post(
      ApiEndpoints.forgotUserId,
      data: {'emailId': email, 'dateOfBirth': dateOfBirth},
    );
  }

  Future<Map<String, dynamic>> verifyForgotUserIdOtp(String otp) async {
    final result = await ApiClient.instance.post(
      ApiEndpoints.forgotUserId,
      data: {},
      options: _challengeOptions(otp),
    );
    SessionManager.instance.clearChallenge();
    return result;
  }

  // ── FORGOT PASSWORD (tracker item #4 — ready) ───────────────
  Future<void> requestForgotPassword({
    required String userId,
    required String dateOfBirth,
  }) async {
    await ApiClient.instance.post(
      ApiEndpoints.forgotCredentials,
      data: {'userId': userId, 'dateOfBirth': dateOfBirth},
    );
  }

  Future<Map<String, dynamic>> verifyForgotPasswordOtp(String otp) async {
    final result = await ApiClient.instance.post(
      ApiEndpoints.forgotCredentials,
      data: {},
      options: _challengeOptions(otp),
    );
    SessionManager.instance.clearChallenge();
    return result;
  }

  Options _challengeOptions(String otp) {
    final header = SessionManager.instance.buildChallengeHeader(otp: otp);
    return Options(headers: {'x-challenge_response': header});
  }

  // ── BIOMETRIC (tracker items #5/#6 — partial) ───────────────
  Future<Map<String, dynamic>> registerMobileDevice({
    required String os,
    required String osVersion,
    required String manufacturer,
    required String model,
    required String secureDeviceId,
  }) {
    return ApiClient.instance.post(
      ApiEndpoints.mobileClientRegistration,
      data: {
        'os': os,
        'osVersion': osVersion,
        'manufacturer': manufacturer,
        'model': model,
        'secureDeviceId': secureDeviceId,
      },
    );
  }

  // ── LOCAL-ONLY HELPERS (registration API not available — item #1) ──
  bool emailExists(String email) => DummyUsers.allUsers.any((u) => u.email == email);

  bool usernameExists(String username) => DummyUsers.allUsers.any(
        (u) => u.username.toLowerCase() == username.trim().toLowerCase(),
      );

  bool passwordMatches({required String email, required String password}) =>
      DummyUsers.allUsers.any((u) => u.email == email && u.password == password);

  UserModel? getUserByEmail(String email) {
    try {
      return DummyUsers.allUsers.firstWhere((u) => u.email == email);
    } catch (_) {
      return null;
    }
  }
}