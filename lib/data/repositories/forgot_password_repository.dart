import 'package:dio/dio.dart';
import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/core/network/session_manager.dart';
import 'anonymous_session_mixin.dart';

/// POST /digx-admin/sms/v1/credentials/forgotCredentials
///
/// Same two-call OTP challenge pattern as `/me`: the first call always
/// throws (ApiException.requiresChallenge) carrying the OTP reference
/// number in the X-CHALLENGE response header — that's success, not an
/// error, it means "OTP sent." The second call repeats the exact same
/// request with an `x-challenge_response` header containing the OTP.
///
/// ⚠️ Behavior after OTP verification is NOT confirmed by any saved
/// example response — no example was captured for this endpoint's final
/// (successful) response. The endpoint path itself
/// (`.../sms/v1/credentials/forgotCredentials`) strongly suggests OBDX
/// resets the credential and dispatches a new password via SMS/email
/// server-side, rather than returning something for the app to let the
/// user type a new password with. Treat a successful final call as "done
/// — check your registered mobile/email for your new password" rather
/// than navigating to an in-app "set new password" screen, unless you
/// confirm the response actually contains a settable-password affordance.
class ForgotPasswordRepository with AnonymousSessionMixin {
  /// Step 1 — always throws on success (see class doc): a thrown
  /// ApiException with `requiresChallenge: true` means the OTP was sent.
  /// Any other exception is a real failure (e.g. no account matches
  /// userId + dateOfBirth).
  Future<void> initiate({
    required String userId,
    required String dateOfBirth,
  }) async {
    final token = await getAnonymousToken();
    await ApiClient.instance.post(
      ApiEndpoints.forgotCredentials,
      data: {'userId': userId, 'dateOfBirth': dateOfBirth},
      options: Options(headers: anonymousHeaders(token)),
    );
  }

  /// Step 2 — same request, replayed with the OTP. [userId]/[dateOfBirth]
  /// must match exactly what was sent in [initiate].
  Future<void> confirm({
    required String userId,
    required String dateOfBirth,
    required String otp,
  }) async {
    final token = await getAnonymousToken();
    await ApiClient.instance.post(
      ApiEndpoints.forgotCredentials,
      data: {'userId': userId, 'dateOfBirth': dateOfBirth},
      options: Options(
        headers: {
          ...anonymousHeaders(token),
          'x-challenge_response':
              SessionManager.instance.buildChallengeHeader(otp: otp),
        },
      ),
    );
  }
}