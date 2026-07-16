import 'dart:convert';
import 'package:flutter/foundation.dart' show VoidCallback;

/// Holds everything the [ApiClient] needs to attach to outgoing requests:
/// the JWT session token plus whatever OTP "challenge" context OBDX is
/// waiting on.
///
/// Confirmed live behaviour: when an endpoint (e.g. `/me`) needs OTP
/// verification, the server responds with:
///   - HTTP body: { "status": { "result": "EXPECTATION_FAILED", ... } }
///   - Response HEADER "X-CHALLENGE":
///       {"authType":"OTP","referenceNo":"21500","attemptsLeft":4,
///        "scope":"USERTASK","resendsLeft":3}
///
/// The referenceNo needed to retry the call lives in that header — NOT in
/// the body's `status.referenceNumber`, which is an unrelated context id.
/// This is a simple in-memory singleton; for production, also persist
/// [jwtToken] via flutter_secure_storage so the session can survive app
/// restarts — plug that in inside [setToken]/[clear].
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  String? jwtToken;
  String? username;

  /// From the login response's `interactionId` field — stored in case a
  /// future endpoint needs it echoed back. Not currently auto-attached to
  /// requests.
  String? interactionId;

  /// OTP challenge context parsed from the most recent `X-CHALLENGE`
  /// response header.
  String? pendingReferenceNo;
  String? pendingAuthType;
  int? attemptsLeft;
  int? resendsLeft;

  bool get isLoggedIn => jwtToken != null && jwtToken!.isNotEmpty;
  bool get hasPendingChallenge => pendingReferenceNo != null;

  /// Set once by [AuthProvider] at app start. Called when a request comes
  /// back 401/403 while a session was active — i.e. the token expired or
  /// was invalidated server-side mid-use, as opposed to a login attempt
  /// simply failing (that never reaches here; login/OTP failures are
  /// surfaced as regular ApiExceptions, not through this path).
  VoidCallback? onSessionExpired;

  /// Guards against every in-flight request that gets a 401 at the same
  /// moment (e.g. dashboard firing several calls at once) all separately
  /// triggering navigation/snackbars. Reset on the next successful login.
  bool _expiryHandled = false;

  void setToken(String token) {
    jwtToken = token;
    _expiryHandled = false;
    // TODO: persist via flutter_secure_storage for session restore.
  }

  /// Called by [ApiClient] whenever a request returns 401/403. Clears the
  /// session and — only if there actually was one — fires
  /// [onSessionExpired] exactly once, so the UI can redirect to login.
  void notifySessionExpired() {
    final wasLoggedIn = isLoggedIn;
    clear();
    if (wasLoggedIn && !_expiryHandled) {
      _expiryHandled = true;
      onSessionExpired?.call();
    }
  }

  /// Parses the raw `X-CHALLENGE` header value, e.g.:
  /// {"authType":"OTP","referenceNo":"21500","attemptsLeft":4,"scope":"USERTASK","resendsLeft":3}
  void setPendingChallengeFromHeader(String rawHeaderValue) {
    try {
      final parsed = jsonDecode(rawHeaderValue) as Map<String, dynamic>;
      pendingReferenceNo = parsed['referenceNo']?.toString();
      pendingAuthType = parsed['authType']?.toString();
      attemptsLeft = int.tryParse(parsed['attemptsLeft']?.toString() ?? '');
      resendsLeft = int.tryParse(parsed['resendsLeft']?.toString() ?? '');
    } catch (_) {
      // Header wasn't valid JSON — ignore, caller still gets a generic
      // "verification required" error without a referenceNo to retry with.
    }
  }

  /// Builds the `x-challenge_response` header to send back on retry,
  /// mirroring the shape OBDX sent us plus the user-entered OTP.
  String buildChallengeHeader({required String otp}) {
    return jsonEncode({
      'authType': pendingAuthType ?? 'OTP',
      'referenceNo': pendingReferenceNo,
      'otp': otp,
    });
  }

  void clearChallenge() {
    pendingReferenceNo = null;
    pendingAuthType = null;
    attemptsLeft = null;
    resendsLeft = null;
  }

  void clear() {
    jwtToken = null;
    username = null;
    interactionId = null;
    clearChallenge();
  }
}