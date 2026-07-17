import 'package:dio/dio.dart';
import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/core/network/api_exception.dart';
import 'anonymous_session_mixin.dart';

/// Three-call registration flow, confirmed from the Postman collection:
///
///   1. GET  /digx-common/party/v1/enumerations/accountTypes
///   2. POST /digx-common/user/v1/registration            -> registrationId
///   3. PUT  /digx-common/user/v1/registration/{id}/authentication
///
/// The collection didn't show its own `anonymousToken` call inside the
/// "Register" folder (unlike Forgot Password/Username, which each have
/// one) — but registration is just as much a pre-login, no-credentials-yet
/// flow, so this assumes it needs the same anonymous token and just
/// wasn't re-fetched in the recorded session because Postman's environment
/// variable carried over from a prior folder run. Worth confirming with a
/// live call; if OBDX 401s on step 2/3 even with the token attached, try
/// dropping the Authorization header entirely for this flow instead.
class RegistrationRepository with AnonymousSessionMixin {
  /// GET accountTypes
  ///
  /// ⚠️ UNCONFIRMED response shape — no saved example in the collection.
  /// This defensively tries a few common enum-response shapes (a plain
  /// list of strings, a list of `{code,value}`-style maps under various
  /// likely keys) and falls back to returning whatever list it can find.
  /// Verify against a live call and tighten this once you see the real
  /// shape — don't trust this blindly for a picker's source of truth yet.
  Future<List<String>> getAccountTypes() async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.accountTypesEnum,
    );

    dynamic rawList = response['accountTypes'] ??
        response['accountTypeList'] ??
        response['enumerationDTOList'] ??
        response['data'];

    if (rawList is! List) {
      // Last resort: maybe the whole body IS the list (some OBDX enum
      // endpoints return a bare JSON array rather than an envelope).
      rawList = response.values.firstWhere(
        (v) => v is List,
        orElse: () => <dynamic>[],
      );
    }

    return rawList
        .map((e) {
          if (e is String) return e;
          if (e is Map) {
            return (e['code'] ?? e['value'] ?? e['id'] ?? e['name'])
                ?.toString();
          }
          return e?.toString();
        })
        .whereType<String>()
        .toList();
  }

  /// POST registration — returns the new `registrationId`, needed for the
  /// confirm step. Body shape matches the Postman sample exactly,
  /// including the null/empty fields OBDX's DTO apparently expects present
  /// (customer, remarks, token, registrationStatus, username, password,
  /// credit card fields, userGroups, targetUnit) — dropping those keys
  /// entirely may or may not be tolerated by the backend; keeping them as
  /// the sample had them is the safer bet until proven otherwise.
  ///
  /// [phone] was dropped as a collected field — the real registration
  /// screen (per the reference UI) doesn't ask for it, and the confirmed
  /// Postman sample always sent it as an all-null object, so it's just
  /// sent that way unconditionally now rather than as a param.
  /// [debitCardNumber] is new — the reference UI shows it as a required
  /// field (the Postman sample happened to leave it null, but that
  /// doesn't mean it's optional; matching the actual product screen here).
  Future<String> submit({
    required String firstName,
    required String lastName,
    required String emailId,
    required String partyId, // shown as "Customer ID" in the UI
    required String dateOfBirth, // 'yyyy-MM-dd'
    required String accountType, // e.g. 'CSA'
    required String accountNumber,
    required String debitCardNumber,
  }) async {
    final token = await getAnonymousToken();

    final response = await ApiClient.instance.post(
      ApiEndpoints.registration,
      data: {
        'registrationId': null,
        'firstName': firstName,
        'lastName': lastName,
        'emailId': emailId,
        'partyId': partyId,
        'dateOfBirth': dateOfBirth,
        'customer': null,
        'accountType': accountType,
        'phone': {
          'areaCode': null,
          'number': null,
          'extension': null,
        },
        'remarks': null,
        'token': null,
        'registrationStatus': null,
        'accountNumber': accountNumber,
        'username': null,
        'password': null,
        'creditCardNumber': null,
        'creditCardNameOnCard': null,
        'creditCardExpiryDate': null,
        'creditCardCVVNumber': null,
        'debitCardNumber': debitCardNumber,
        'debitCardPin': null,
        'userGroups': [],
        'targetUnit': null,
      },
      options: Options(headers: anonymousHeaders(token)),
    );

    // Confirmed shape (Postman test script):
    // pm.environment.set('registrationId', res.registrationDTO.registrationId)
    final registrationId =
        (response['registrationDTO'] as Map?)?['registrationId'];

    if (registrationId == null) {
      throw ApiException(
        'Registration succeeded but no registrationId came back — '
        'cannot proceed to the authentication step.',
      );
    }

    return registrationId.toString();
  }

  /// PUT registration/{id}/authentication — confirms/activates the new
  /// registration. No body; per the Postman collection's pre-request
  /// script, a hardcoded `token_id: 1111` header stands in for what's
  /// presumably a real emailed/SMSed verification code in production
  /// (same sandbox convention as the OTP '1111' used elsewhere) — swap
  /// this for a real user-entered code input once that's available rather
  /// than shipping the hardcoded value.
  Future<void> confirmAuthentication({
    required String registrationId,
    String tokenId = '1111',
  }) async {
    final token = await getAnonymousToken();
    await ApiClient.instance.put(
      ApiEndpoints.registrationAuthentication(registrationId),
      options: Options(
        headers: {
          ...anonymousHeaders(token),
          'token_id': tokenId,
        },
      ),
    );
  }
}