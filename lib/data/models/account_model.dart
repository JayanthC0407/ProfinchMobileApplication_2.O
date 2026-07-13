class AccountModel {
  final String id;
  final String userId;
  final String accountNumber;
  final String iban;
  final String ifscCode;
  final String branchCode;
  final String branchName;
  final String accountType;
  final String currencyCode;
  final double balance;
  final double availableBalance;
  final double currentBalance;
  final double holdAmount;
  final bool isActive;
  final String partyName;

  final DateTime openingDate;

  final bool hasChequeBook;
  final bool hasATMFacility;
  final bool hasOverDraftFacility;

  final double overDraftLimit;

  final bool nomineeRegistered;

  /// True if this is the user's default/primary account
  /// (`defaultAccount` in the OBDX response).
  final bool isDefault;

  AccountModel({
    required this.id,
    required this.userId,
    required this.accountNumber,
    required this.iban,
    required this.ifscCode,
    required this.branchCode,
    required this.branchName,
    required this.accountType,
    required this.currencyCode,
    required this.balance,
    required this.availableBalance,
    required this.currentBalance,
    required this.holdAmount,
    required this.isActive,
    required this.partyName,
    required this.openingDate,
    required this.hasChequeBook,
    required this.hasATMFacility,
    required this.hasOverDraftFacility,
    required this.overDraftLimit,
    required this.nomineeRegistered,
    this.isDefault = false,
  });

  /// Builds an [AccountModel] from a single entry in the OBDX
  /// `GET /digx-common/dda/v1/demandDeposit` response's `accounts` array.
  ///
  /// Confirmed against a real response (see below) — this replaces the
  /// earlier best-guess version.
  ///
  /// ```json
  /// {
  ///   "id": { "displayValue": "xxxxxxxxxxxx0139", "value": "5E69...BC90B71A3" },
  ///   "displayName": "SAHAM BISWA",
  ///   "status": "ACTIVE",
  ///   "type": "CSA",
  ///   "currencyCode": "GBP",
  ///   "branchCode": "000",
  ///   "productDTO": {
  ///     "description": "Savings Account - Regular",
  ///     "demandDepositProductFacilitiesDTO": {
  ///       "hasChequeBookFacility": true, "hasOverDraftFacility": false,
  ///       "hasPassbookFacility": true, "hasATMFacility": true
  ///     }
  ///   },
  ///   "openingDate": "2022-12-22T00:00:00",
  ///   "partyName": "SAHAM BISWA",
  ///   "defaultAccount": true,
  ///   "ddaAccountType": "SAVING",
  ///   "availableBalance": { "currency": "GBP", "amount": 140000 },
  ///   "currentBalance": { "currency": "GBP", "amount": 1640000 },
  ///   "accountFacilities": { "hasChequeBook": true, "lmEnabled": false },
  ///   "nomineeRegistered": false
  /// }
  /// ```
  ///
  /// ⚠️ Fields NOT present anywhere in this endpoint's response, so they
  /// stay empty/zero here until you either get a `/demandDeposit/{id}`
  /// details endpoint or confirm they're genuinely unavailable: `iban`,
  /// `ifscCode`, `branchName`, `holdAmount`, `overDraftLimit`.
  factory AccountModel.fromJson(Map<String, dynamic> json, {String userId = ''}) {
    double toDouble(dynamic v) => v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    bool toBool(dynamic v) => v == true || v?.toString().toUpperCase() == 'Y';

    final idDTO = json['id'];
    final productDTO = json['productDTO'] as Map<String, dynamic>?;
    final facilitiesDTO =
        productDTO?['demandDepositProductFacilitiesDTO'] as Map<String, dynamic>?;
    final accountFacilities = json['accountFacilities'] as Map<String, dynamic>?;
    final availableBalanceDTO = json['availableBalance'] as Map<String, dynamic>?;
    final currentBalanceDTO = json['currentBalance'] as Map<String, dynamic>?;

    final availableBalance = toDouble(availableBalanceDTO?['amount']);
    final currentBalance = toDouble(currentBalanceDTO?['amount']);

    return AccountModel(
      // The long opaque `value` is what other OBDX calls (e.g. the
      // transactions/statement endpoint) expect as {accountId}.
      id: (idDTO is Map ? idDTO['value'] : null)?.toString() ??
          (json['accountId'] ?? '').toString(),
      userId: userId,
      // The masked `displayValue` (e.g. "xxxxxxxxxxxx0139") is what's safe
      // to show in the UI in place of a raw account number.
      accountNumber:
          (idDTO is Map ? idDTO['displayValue'] : null)?.toString() ?? '',
      iban: (json['iban'] ?? '').toString(),
      ifscCode: (json['ifscCode'] ?? json['branchIdentifierCode'] ?? '').toString(),
      branchCode: (json['branchCode'] ?? '').toString(),
      branchName: (json['branchName'] ?? '').toString(),
      accountType: (productDTO?['description'] ??
              json['ddaAccountType'] ??
              json['type'] ??
              '')
          .toString(),
      currencyCode: (json['currencyCode'] ?? currentBalanceDTO?['currency'] ?? '').toString(),
      balance: currentBalance,
      availableBalance: availableBalance,
      currentBalance: currentBalance,
      holdAmount: toDouble(json['holdAmount']),
      isActive: (json['status']?.toString().toUpperCase() ?? 'ACTIVE') == 'ACTIVE',
      partyName: (json['partyName'] ?? json['displayName'] ?? '').toString(),
      openingDate: DateTime.tryParse(json['openingDate']?.toString() ?? '') ?? DateTime.now(),
      hasChequeBook: toBool(accountFacilities?['hasChequeBook'] ??
          facilitiesDTO?['hasChequeBookFacility']),
      hasATMFacility: toBool(facilitiesDTO?['hasATMFacility']),
      hasOverDraftFacility: toBool(facilitiesDTO?['hasOverDraftFacility']),
      overDraftLimit: toDouble(json['overDraftLimit']),
      nomineeRegistered: toBool(json['nomineeRegistered']),
      isDefault: json['defaultAccount'] == true,
    );
  }

  AccountModel copyWith({
    double? balance,
    double? availableBalance,
  }) {
    return AccountModel(
      id: id,
      userId: userId,
      accountNumber: accountNumber,
      iban: iban,
      ifscCode: ifscCode,
      branchCode: branchCode,
      branchName: branchName,
      accountType: accountType,
      currencyCode: currencyCode,
      balance: balance ?? this.balance,
      availableBalance: availableBalance ?? this.availableBalance,
      currentBalance: currentBalance,
      holdAmount: holdAmount,
      isActive: isActive,
      partyName: partyName,
      openingDate: openingDate,
      hasChequeBook: hasChequeBook,
      hasATMFacility: hasATMFacility,
      hasOverDraftFacility: hasOverDraftFacility,
      overDraftLimit: overDraftLimit,
      nomineeRegistered: nomineeRegistered,
      isDefault: isDefault,
    );
  }
}