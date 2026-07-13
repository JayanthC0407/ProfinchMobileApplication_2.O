enum PaymentStatus { pending, completed, failed, cancelled }
enum RepeatInterval { once, daily, weekly, monthly }

/// Unified model for adhoc, scheduled, and favourite payments.
class PaymentModel {
  final String id;
  final String userId;
  final String fromAccountId;

  // Recipient — for adhoc these are typed manually, for beneficiary-based
  // transfers beneficiaryId is non-null.
  final String? beneficiaryId;
  final String receiverName;
  final String receiverAccount;
  final String receiverBank;
  final String ifscCode;
  final String transferMode; // PBI / LOCAL / INTERNATIONAL / ADHOC

  final double amount;
  final String remarks;

  // Scheduling
  final DateTime scheduledDate;
  final RepeatInterval repeat;

  // State
  final PaymentStatus status;
  final DateTime createdAt;

  // Favourites & frequency
  final bool isFavourite;
  final int useCount; // auto-incremented on every successful transfer

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.fromAccountId,
    this.beneficiaryId,
    required this.receiverName,
    required this.receiverAccount,
    required this.receiverBank,
    required this.ifscCode,
    required this.transferMode,
    required this.amount,
    required this.remarks,
    required this.scheduledDate,
    this.repeat = RepeatInterval.once,
    this.status = PaymentStatus.pending,
    required this.createdAt,
    this.isFavourite = false,
    this.useCount = 0,
  });

  bool get isDue =>
      scheduledDate.isBefore(DateTime.now()) &&
      status == PaymentStatus.pending;

  PaymentModel copyWith({
    PaymentStatus? status,
    bool? isFavourite,
    int? useCount,
    DateTime? scheduledDate,
    double? amount,
    String? remarks,
    RepeatInterval? repeat,
  }) {
    return PaymentModel(
      id: id,
      userId: userId,
      fromAccountId: fromAccountId,
      beneficiaryId: beneficiaryId,
      receiverName: receiverName,
      receiverAccount: receiverAccount,
      receiverBank: receiverBank,
      ifscCode: ifscCode,
      transferMode: transferMode,
      amount: amount ?? this.amount,
      remarks: remarks ?? this.remarks,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      repeat: repeat ?? this.repeat,
      status: status ?? this.status,
      createdAt: createdAt,
      isFavourite: isFavourite ?? this.isFavourite,
      useCount: useCount ?? this.useCount,
    );
  }
}