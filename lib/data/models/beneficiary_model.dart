class BeneficiaryModel {
  final String id;
  final String userId;
  final String nickname;
  final String beneficiaryType;
  final String accountNumber;
  final String bankName;
  final String ifscCode;
  final bool isVerified;
  final String? ibanNumber;
  final String? swiftCode;
  final String? country;

  /// When this beneficiary was added — used to enforce cooling period.
  final DateTime addedAt;

  /// Cooling period in seconds before transfers are allowed.
  /// Architecture spec: 30 seconds (demo); production would be 4 hours.
  final int coolingSeconds;

  BeneficiaryModel({
    required this.id,
    required this.userId,
    required this.nickname,
    required this.beneficiaryType,
    required this.accountNumber,
    required this.bankName,
    required this.ifscCode,
    required this.isVerified,
    this.ibanNumber,
    this.swiftCode,
    this.country,
    DateTime? addedAt,
    this.coolingSeconds = 30,
  }) : addedAt = addedAt ?? DateTime.now();

  /// True once the cooling period has elapsed.
  bool get isTransferAllowed =>
      DateTime.now().difference(addedAt).inSeconds >= coolingSeconds;

  /// Seconds remaining in the cooling period (0 if already elapsed).
  int get coolingSecondsRemaining {
    final elapsed = DateTime.now().difference(addedAt).inSeconds;
    final remaining = coolingSeconds - elapsed;
    return remaining < 0 ? 0 : remaining;
  }

  BeneficiaryModel copyWith({
    String? nickname,
    String? accountNumber,
    String? bankName,
    String? ifscCode,
    String? ibanNumber,
    String? swiftCode,
    String? country,
    bool? isVerified,
    DateTime? addedAt,  
  }) {
    return BeneficiaryModel(
      id: id,
      userId: userId,
      nickname: nickname ?? this.nickname,
      beneficiaryType: beneficiaryType,
      accountNumber: accountNumber ?? this.accountNumber,
      bankName: bankName ?? this.bankName,
      ifscCode: ifscCode ?? this.ifscCode,
      isVerified: isVerified ?? this.isVerified,
      ibanNumber: ibanNumber ?? this.ibanNumber,
      swiftCode: swiftCode ?? this.swiftCode,
      country: country ?? this.country,
      addedAt: addedAt ?? this.addedAt,
      coolingSeconds: coolingSeconds,
    );
  }
}