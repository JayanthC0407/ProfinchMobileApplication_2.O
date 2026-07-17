import 'package:dio/dio.dart';
import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/core/network/session_manager.dart';
import 'anonymous_session_mixin.dart';

/// POST /digx-admin/sms/v1/credentials/forgotUserId
///
/// Identical shape to [ForgotPasswordRepository] — same OTP challenge
/// pattern — but keyed on `emailId` + `dateOfBirth` instead of
/// `userId` + `dateOfBirth`, since you don't know your username yet.
///
/// ⚠️ Same caveat as forgotCredentials: no saved example response for the
/// successful final call. Likely OBDX emails/SMSes the username back
/// rather than returning it directly in the response — treat success as
/// "check your registered email/mobile for your username" rather than
/// assuming the response body hands you the username to display in-app.
class ForgotUsernameRepository with AnonymousSessionMixin {
  Future<void> initiate({
    required String emailId,
    required String dateOfBirth,
  }) async {
    final token = await getAnonymousToken();
    await ApiClient.instance.post(
      ApiEndpoints.forgotUserId,
      data: {'emailId': emailId, 'dateOfBirth': dateOfBirth},
      options: Options(headers: anonymousHeaders(token)),
    );
  }

  Future<void> confirm({
    required String emailId,
    required String dateOfBirth,
    required String otp,
  }) async {
    final token = await getAnonymousToken();
    await ApiClient.instance.post(
      ApiEndpoints.forgotUserId,
      data: {'emailId': emailId, 'dateOfBirth': dateOfBirth},
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