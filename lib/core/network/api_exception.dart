/// Uniform error type surfaced by [ApiClient] so providers/UI never have to
/// deal with Dio-specific exception types.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// True when the server responded but with a "challenge" (OTP/MFA) that
  /// the caller must complete before retrying — mirrors OBDX's
  /// `x-challenge_response` flow seen throughout the Postman collection.
  final bool requiresChallenge;

  /// Raw decoded error body from the server, if any — useful for surfacing
  /// OBDX-specific error codes to the UI.
  final Map<String, dynamic>? data;

  ApiException(
    this.message, {
    this.statusCode,
    this.requiresChallenge = false,
    this.data,
  });

  factory ApiException.network() =>
      ApiException('Unable to reach the server. Please check your connection.');

  factory ApiException.timeout() =>
      ApiException('The request timed out. Please try again.');

  factory ApiException.unauthorized() =>
      ApiException('Session expired. Please log in again.', statusCode: 401);

  @override
  String toString() => message;
}
