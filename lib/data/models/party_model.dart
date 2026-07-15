/// A single phone/fax number as OBDX returns it — always masked
/// (`"9856****78"`) rather than the real number, and sometimes an empty
/// object (`{}`) when nothing's on file for that contact type.
class PartyPhone {
  final String areaCode;
  final String number;

  PartyPhone({required this.areaCode, required this.number});

  factory PartyPhone.fromJson(Map<String, dynamic> json) {
    return PartyPhone(
      areaCode: (json['areaCode'] ?? '').toString(),
      number: (json['number'] ?? '').toString(),
    );
  }

  bool get isEmpty => areaCode.isEmpty && number.isEmpty;

  /// e.g. "+91 9856****78" — omits the area code if it's blank.
  String get display => isEmpty
      ? ''
      : (areaCode.isNotEmpty ? '+$areaCode $number' : number);
}

/// One entry from `party.contacts[]`. `contactType` is a fixed OBDX code:
/// `WEM` (work email), `WPH` (work phone), `WMO` (mobile), `HPH` (home
/// phone), `FAX`. Only `email`/`phone`/`fax` — whichever matches the
/// type — is populated; the others come back absent.
class PartyContact {
  final String contactType;
  final String contactId;
  final String? email;
  final PartyPhone? phone;

  PartyContact({
    required this.contactType,
    required this.contactId,
    this.email,
    this.phone,
  });

  factory PartyContact.fromJson(Map<String, dynamic> json) {
    final phoneJson = json['phone'];
    final faxJson = json['fax'];
    // FAX entries use a "fax" key instead of "phone" but the same
    // {areaCode, number} shape, so treat it the same way.
    final rawPhone = phoneJson is Map<String, dynamic>
        ? phoneJson
        : (faxJson is Map<String, dynamic> ? faxJson : null);

    return PartyContact(
      contactType: (json['contactType'] ?? '').toString(),
      contactId: (json['contactId'] ?? '').toString(),
      email: json['email']?.toString(),
      phone: rawPhone != null ? PartyPhone.fromJson(rawPhone) : null,
    );
  }
}

/// One entry from `party.addresses[]`. `type` is a fixed OBDX code: `PST`
/// (postal), `RES` (residential), `WRK` (work). `postalAddress` can be
/// entirely absent (see the `WRK` entry in the sample response) when
/// nothing's on file for that address type.
class PartyAddress {
  final String addressId;
  final String type;
  final String line1;
  final String line2;
  final String line3;

  /// ISO 3166-1 alpha-2 country code (e.g. `IN`) — resolve to a display
  /// name via `ProfileProvider.countryName(countryCode)` rather than
  /// showing the raw code in the UI.
  final String countryCode;

  PartyAddress({
    required this.addressId,
    required this.type,
    required this.line1,
    required this.line2,
    required this.line3,
    required this.countryCode,
  });

  factory PartyAddress.fromJson(Map<String, dynamic> json) {
    final postal = json['postalAddress'];
    final addr = postal is Map<String, dynamic> ? postal : <String, dynamic>{};
    return PartyAddress(
      addressId: (json['addressId'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      line1: (addr['line1'] ?? '').toString(),
      line2: (addr['line2'] ?? '').toString(),
      line3: (addr['line3'] ?? '').toString(),
      countryCode: (addr['country'] ?? '').toString(),
    );
  }

  bool get isEmpty => line1.isEmpty && line2.isEmpty && line3.isEmpty;

  /// e.g. "ADDRESS1, ADDRESS2, ADDRESS3" — country isn't included since
  /// it's just a code here; resolve and append it separately.
  String get displayLines =>
      [line1, line2, line3].where((l) => l.isNotEmpty).join(', ');
}

/// Builds from the OBDX `GET /digx-common/user/v1/me/party` response,
/// confirmed live shape:
/// ```json
/// {
///   "status": {...},
///   "party": {
///     "id": {"displayValue": "***03448", "value": "F1B1..."},
///     "personalDetails": {
///       "salutation", "firstName", "lastName", "birthDate",
///       "noOfDependants", "email", "fullName", "partyType"
///     },
///     "contacts": [ {contactType, contactId, email|phone|fax}, ... ],
///     "identifications": [],
///     "addresses": [ {addressId, type, postalAddress?}, ... ],
///     "fatcaCheckRequired": false
///   }
/// }
/// ```
/// Like the accounts/loans APIs, `email` here is masked
/// (`"anu****profinch.com"`) — there's no way to get the real value
/// client-side, so use this masked form for display everywhere.
class PartyModel {
  final String id;
  final String maskedPartyId;
  final String salutation;
  final String firstName;
  final String lastName;
  final String fullName;
  final DateTime? birthDate;
  final int noOfDependants;
  final String maskedEmail;
  final String partyType;
  final List<PartyContact> contacts;
  final List<PartyAddress> addresses;
  final bool fatcaCheckRequired;

  PartyModel({
    required this.id,
    required this.maskedPartyId,
    required this.salutation,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.birthDate,
    required this.noOfDependants,
    required this.maskedEmail,
    required this.partyType,
    required this.contacts,
    required this.addresses,
    required this.fatcaCheckRequired,
  });

  factory PartyModel.fromJson(Map<String, dynamic> json) {
    final party = (json['party'] as Map<String, dynamic>?) ?? json;
    final idObj = (party['id'] as Map<String, dynamic>?) ?? {};
    final personal =
        (party['personalDetails'] as Map<String, dynamic>?) ?? {};
    final contactsList = party['contacts'];
    final addressesList = party['addresses'];

    return PartyModel(
      id: (idObj['value'] ?? '').toString(),
      maskedPartyId: (idObj['displayValue'] ?? '').toString(),
      salutation: (personal['salutation'] ?? '').toString(),
      firstName: (personal['firstName'] ?? '').toString(),
      lastName: (personal['lastName'] ?? '').toString(),
      fullName: (personal['fullName'] ?? '').toString(),
      birthDate: DateTime.tryParse(personal['birthDate']?.toString() ?? ''),
      noOfDependants:
          int.tryParse(personal['noOfDependants']?.toString() ?? '') ?? 0,
      maskedEmail: (personal['email'] ?? '').toString(),
      partyType: (personal['partyType'] ?? '').toString(),
      contacts: contactsList is List
          ? contactsList
              .whereType<Map<String, dynamic>>()
              .map(PartyContact.fromJson)
              .toList()
          : [],
      addresses: addressesList is List
          ? addressesList
              .whereType<Map<String, dynamic>>()
              .map(PartyAddress.fromJson)
              .toList()
          : [],
      fatcaCheckRequired: party['fatcaCheckRequired'] == true,
    );
  }

  PartyContact? _contactOfType(String type) {
    try {
      return contacts.firstWhere((c) => c.contactType == type);
    } catch (_) {
      return null;
    }
  }

  /// Masked mobile number (`contactType: "WMO"`), e.g. `+91 9856****78`.
  /// Empty string if not on file.
  String get maskedMobile {
    final phone = _contactOfType('WMO')?.phone;
    return (phone != null && !phone.isEmpty) ? phone.display : '';
  }

  /// Masked home phone (`contactType: "HPH"`). Empty string if not on file.
  String get maskedHomePhone {
    final phone = _contactOfType('HPH')?.phone;
    return (phone != null && !phone.isEmpty) ? phone.display : '';
  }

  PartyAddress? _addressOfType(String type) {
    try {
      return addresses.firstWhere((a) => a.type == type && !a.isEmpty);
    } catch (_) {
      return null;
    }
  }

  /// Residential address if one is on file, otherwise falls back to the
  /// postal address, otherwise null (e.g. the `WRK` entry in the sample
  /// response, which has no `postalAddress` at all).
  PartyAddress? get preferredAddress =>
      _addressOfType('RES') ?? _addressOfType('PST');
}
