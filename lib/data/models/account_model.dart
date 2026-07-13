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
  });

  /// Builds an [AccountModel] from a single entry in the OBDX
  /// `GET /digx-common/dda/v1/demandDeposit` response array.
  ///
  /// ⚠️ No example response was saved in the Postman collection, so field
  /// names below are best-guess OBDX conventions. Verify against a real
  /// response and adjust field names as needed — in particular
  /// `accountType`/`branchCode`/facility flags are the ones most likely to
  /// differ from what's assumed here.
  factory AccountModel.fromJson(Map<String, dynamic> json, {String userId = ''}) {
    double toDouble(dynamic v) => v == null ? 0.0 : double.tryParse(v.toString()) ?? 0.0;
    bool toBool(dynamic v) => v == true || v?.toString().toUpperCase() == 'Y';

    return AccountModel(
      id: (json['id'] ?? json['accountId'] ?? json['accountNumber'] ?? '').toString(),
      userId: userId,
      accountNumber: (json['accountNumber'] ?? '').toString(),
      iban: (json['iban'] ?? '').toString(),
      ifscCode: (json['ifscCode'] ?? json['branchIdentifierCode'] ?? '').toString(),
      branchCode: (json['branchCode'] ?? '').toString(),
      branchName: (json['branchName'] ?? '').toString(),
      accountType: (json['accountType'] ?? json['productName'] ?? '').toString(),
      currencyCode: (json['currency'] ?? json['currencyCode'] ?? '').toString(),
      balance: toDouble(json['bookBalance'] ?? json['balance']),
      availableBalance: toDouble(json['availableBalance']),
      currentBalance: toDouble(json['currentBalance'] ?? json['bookBalance']),
      holdAmount: toDouble(json['holdAmount']),
      isActive: (json['status']?.toString().toUpperCase() ?? 'ACTIVE') == 'ACTIVE',
      partyName: (json['partyName'] ?? json['accountName'] ?? '').toString(),
      openingDate: DateTime.tryParse(json['openingDate']?.toString() ?? '') ?? DateTime.now(),
      hasChequeBook: toBool(json['chequeBookFacility']),
      hasATMFacility: toBool(json['atmFacility']),
      hasOverDraftFacility: toBool(json['overDraftFacility']),
      overDraftLimit: toDouble(json['overDraftLimit']),
      nomineeRegistered: toBool(json['nomineeRegistered']),
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
      availableBalance:
          availableBalance ?? this.availableBalance,
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
    );
  }
}