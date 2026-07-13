class TransferModel {

  final String id;

  final String userId;

  final String fromAccountId;

  final String beneficiaryId;

  final String beneficiaryName;

  final String beneficiaryType;

  final double amount;

  final String remarks;

  final String transferMode;

  final String status;

  final DateTime transferDate;

  TransferModel({
    required this.id,
    required this.userId,
    required this.fromAccountId,
    required this.beneficiaryId,
    required this.beneficiaryName,
    required this.beneficiaryType,
    required this.amount,
    required this.remarks,
    required this.transferMode,
    required this.status,
    required this.transferDate,
  });
}