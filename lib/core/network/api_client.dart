import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'api_config.dart';
import 'api_exception.dart';
import 'session_manager.dart';

/// Thin wrapper around Dio that:
///   - attaches the standard OBDX headers seen on every request in the
///     Postman collection (X-Requested-With, X-Target-Unit, x-token-type)
///   - attaches the JWT bearer token once logged in
///   - automatically carries the session cookie OBDX sets after login on
///     every subsequent request (see note in constructor — handled
///     differently per platform since browsers hide Set-Cookie from JS)
///   - detects the `X-CHALLENGE` response header (OTP/MFA gate) on both
///     success and error responses and surfaces it via
///     ApiException.requiresChallenge
///   - maps every failure into an [ApiException] so callers never touch Dio
///
/// Add to pubspec.yaml:
///   dependencies:
///     dio: ^5.4.0
///     dio_cookie_manager: ^3.1.1
///     cookie_jar: ^4.0.8
class ApiClient {
  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        queryParameters: {'locale': ApiConfig.locale},
        // Web only: tells the browser to include/store cookies for
        // cross-origin requests automatically. This is the ONLY way
        // cookies work on Flutter Web — browsers hide the Set-Cookie
        // response header from JS entirely, so manually reading and
        // re-attaching it is not possible on this platform. Requires the
        // OBDX server to respond with a specific (non-wildcard)
        // Access-Control-Allow-Origin matching this app's exact origin,
        // plus Access-Control-Allow-Credentials: true — flag this to your
        // backend/infra team if cookies still don't seem to persist.
        extra: {'withCredentials': true},

        // We do our own status-code interpretation (OBDX can return
        // 4xx/417 for business-level "needs OTP" responses that still
        // carry a useful JSON body), so don't let Dio throw before we've
        // had a chance to inspect it.
        validateStatus: (_) => true,
      ),
    );

    // Mobile/desktop only: Dio doesn't persist cookies across requests by
    // default. This captures Set-Cookie from every response and
    // automatically attaches it as a Cookie header on subsequent requests
    // to the same host — the equivalent of what withCredentials does for
    // web above. Skipped on web since the browser already owns cookie
    // handling there (and JS can't touch Set-Cookie/Cookie headers anyway).
    //
    // Kept as a field (rather than an inline `CookieManager(CookieJar())`)
    // so logout can actually clear it — otherwise the old session cookie
    // just sits in the jar until the next login's Set-Cookie overwrites it.

    if (!kIsWeb) {
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(CookieJar()));
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['X-Requested-With'] = 'XMLHttpRequest';
          options.headers['X-Target-Unit'] = ApiConfig.targetUnit;
          options.headers['Content-Type'] = 'application/json';

          final token = SessionManager.instance.jwtToken;
          if (token != null) {
            options.headers['x-token-type'] = 'JWT';
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );

    // Verbose request/response logging — remove or gate behind kDebugMode
    // before shipping to production.
    _dio.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true),
    );
  }

  static final ApiClient instance = ApiClient._internal();
  late final Dio _dio;

  CookieJar? _cookieJar; // null on web — browser owns cookies there instead

  /// Clears the locally-held session cookie (e.g. OBDX's `secretKey`) on
  /// logout. No-op on web, where there's no local CookieJar to clear —
  /// the browser manages cookies there, and OBDX's own logout response
  /// clearing/expiring the cookie server-side is what matters instead.
  Future<void> clearCookies() async {
    await _cookieJar?.deleteAll();
  }

  /// Exposes the raw Dio instance for one-off needs (e.g. downloading a PDF
  /// statement with responseType: bytes) while everything else goes through
  /// the typed helpers below.
  Dio get raw => _dio;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  /// Needed for the primary-account save flow (`PUT
  /// /digx-admin/sms/v1/userPreferences`) — nothing else has needed a PUT
  /// until now, only GET/POST.
  Future<Map<String, dynamic>> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _processResponse(response);
    } on DioException catch (e) {
      throw _mapDioError(e);
    }
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data == null) return {};
    if (data is Map<String, dynamic>) return data;
    return {'data': data};
  }

  /// Since [BaseOptions.validateStatus] always returns true, every
  /// response — 2xx or not — comes through here rather than throwing.
  /// This is where we decide success vs. failure vs. "OTP challenge".
  Map<String, dynamic> _processResponse(Response response) {
    final body = _asMap(response.data);
    final challengeHeader =
        response.headers.value('X-CHALLENGE') ??
        response.headers.value('x-challenge');

    if (challengeHeader != null) {
      SessionManager.instance.setPendingChallengeFromHeader(challengeHeader);
      String? code;
      final statusMap = body['status'];
      if (statusMap is Map) {
        final message = statusMap['message'];
        if (message is Map) {
          code = message['code']?.toString();
        }
      }
      throw ApiException(
        'Verification required.' + (code != null ? ' ($code)' : ''),
        statusCode: response.statusCode,
        requiresChallenge: true,
        data: body,
      );
    }

    final status = response.statusCode ?? 0;
    if (status == 401 || status == 403) {
      SessionManager.instance.clear();
      throw ApiException.unauthorized();
    }

    // OBDX status envelope: { "status": { "result": "SUCCESSFUL" | other } }
    final statusEnvelope = body['status'];
    if (statusEnvelope is Map) {
      final result = statusEnvelope['result']?.toString().toUpperCase();
      final isSuccess = result == 'SUCCESSFUL' || result == 'SUCCESS';
      if (!isSuccess && result != null) {
        final message = statusEnvelope['message'];
        final msgText = message is Map
            ? (message['code']?.toString() ?? message['type']?.toString())
            : message?.toString();
        throw ApiException(
          msgText ?? 'Request failed: $result',
          statusCode: status,
          data: body,
        );
      }
    } else if (status >= 400) {
      // No status envelope but still an HTTP error.
      throw ApiException(
        body['message']?.toString() ?? 'Request failed with status $status.',
        statusCode: status,
        data: body,
      );
    }

    return body;
  }

  ApiException _mapDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return ApiException.timeout();
    }
    if (e.type == DioExceptionType.connectionError) {
      return ApiException.network();
    }
    return ApiException(e.message ?? 'Something went wrong. Please try again.');
  }
}
