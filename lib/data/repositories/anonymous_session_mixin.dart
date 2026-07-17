import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/core/network/api_exception.dart';

/// Several pre-login flows (forgot password, forgot username, new
/// registration) need to call authenticated-shaped OBDX endpoints before
/// the user has any real credentials. OBDX handles this with a temporary
/// "anonymous" identity token:
///
///   POST /digx-infra/login/v1/anonymousToken   (no body)
///
/// Confirmed from the Postman collection's own test script — the token
/// comes back in the **response header** `Authorization`, not the body:
/// ```js
/// const data = pm.response.headers.get("Authorization");
/// pm.environment.set("anonymousToken", data);
/// ```
///
/// Mix this into any repository that needs it rather than duplicating the
/// fetch/cache logic per flow.
mixin AnonymousSessionMixin {
  String? _anonymousToken;

  Future<String> getAnonymousToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _anonymousToken != null) return _anonymousToken!;

    final response = await ApiClient.instance.raw.post(
      ApiEndpoints.anonymousToken,
    );

    final token = response.headers.value('Authorization') ??
        response.headers.value('authorization');

    if (token == null || token.isEmpty) {
      throw ApiException(
        'Could not start a secure session for this request. '
        'No Authorization header came back from anonymousToken.',
      );
    }

    _anonymousToken = token;
    return token;
  }

  /// Headers needed on every call made with the anonymous token.
  ///
  /// Two bugs fixed here that were both causing forgotCredentials (and
  /// forgotUserId/registration) to fail:
  ///
  /// 1. `x-token-type: JWT` — ApiClient's global interceptor only adds
  ///    this when `SessionManager.instance.jwtToken` is set (paired with
  ///    the real Authorization header it attaches at the same time).
  ///    These pre-login flows attach Authorization manually instead, so
  ///    that check never fires and `x-token-type` silently never went
  ///    out. Always build headers via this method rather than setting
  ///    Authorization alone, so the two can't drift apart.
  ///
  /// 2. Missing "Bearer " prefix — confirmed via a live comparison: the
  ///    captured anonymousToken response header value wasn't reliably
  ///    carrying "Bearer " through to the outgoing request (whether that's
  ///    the response itself, or something in how it's read/cached, wasn't
  ///    worth chasing further). Rather than trust the raw captured value's
  ///    formatting, this normalizes it on every use — strips any existing
  ///    "Bearer " first, then adds exactly one — so the outgoing header is
  ///    always correct regardless of what shape the token arrived in.
  Map<String, String> anonymousHeaders(String token) {
    final raw = token.trim();
    final bare =
        raw.toLowerCase().startsWith('bearer ') ? raw.substring(7) : raw;
    return {
      'Authorization': 'Bearer $bare',
      'x-token-type': 'JWT',
    };
  }
}