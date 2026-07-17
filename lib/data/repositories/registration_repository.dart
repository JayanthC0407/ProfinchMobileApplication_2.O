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
/// One entry from the accountTypes enum — [code] is what actually gets
/// sent as `accountType` in the registration POST (e.g. "CSA"), [label]
/// is what the dropdown should display (e.g. "Current and Saving").
class AccountTypeOption {
  final String code;
  final String label;

  AccountTypeOption({required this.code, required this.label});
}

class RegistrationRepository with AnonymousSessionMixin {
  /// GET accountTypes
  ///
  /// Confirmed real response shape (this was previously a guess that
  /// missed — the list sits nested two levels deep, which is why the
  /// dropdown was coming back empty despite the call succeeding):
  /// ```json
  /// {
  ///   "enumRepresentations": [
  ///     { "data": [
  ///       { "code": "CSA", "value": "CSA", "description": "Current and Saving", "ordinal": 0 },
  ///       { "code": "LON", "value": "LON", "description": "Loan", "ordinal": 1 },
  ///       ...
  ///     ] }
  ///   ]
  /// }
  /// ```
  /// `code` is the value to submit back in the registration POST;
  /// `description` is what the dropdown shows. Sorted by `ordinal` in
  /// case a future response doesn't already arrive pre-sorted.
  Future<List<AccountTypeOption>> getAccountTypes() async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.accountTypesEnum,
    );

    final groups = response['enumRepresentations'];
    if (groups is! List) return [];

    final options = <MapEntry<int, AccountTypeOption>>[];
    for (final group in groups) {
      final data = (group is Map) ? group['data'] : null;
      if (data is! List) continue;
      for (final entry in data) {
        if (entry is! Map) continue;
        final code = entry['code']?.toString();
        if (code == null || code.isEmpty) continue;
        final label =
            (entry['description'] ?? entry['value'] ?? code).toString();
        final ordinal = int.tryParse(entry['ordinal']?.toString() ?? '') ??
            options.length;
        options.add(
          MapEntry(ordinal, AccountTypeOption(code: code, label: label)),
        );
      }
    }

    options.sort((a, b) => a.key.compareTo(b.key));
    return options.map((e) => e.value).toList();
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
  /// [debitCardNumber] — despite the reference UI marking this required,
  /// confirmed via a live call that OBDX accepts registration without it;
  /// sent as null when not provided rather than forced as a required
  /// field client-side.
  Future<String> submit({
    required String firstName,
    required String lastName,
    required String emailId,
    required String partyId, // shown as "Customer ID" in the UI
    required String dateOfBirth, // 'yyyy-MM-dd'
    required String accountType, // e.g. 'CSA'
    required String accountNumber,
    String? debitCardNumber,
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
        'debitCardNumber':
            (debitCardNumber == null || debitCardNumber.isEmpty)
                ? null
                : debitCardNumber,
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