enum TransactionType { credit, debit }

enum TransactionCategory {
  transfer,
  billPayment,
  upi,
  atm,
  shopping,
  food,
  recharge,
  emi,
  salary,
  refund,
  loan,
  termDeposit,
  wallet,
  insurance,   // ← NEW: covers wallet top-up, wallet-to-bank, wallet payments
}

class TransactionModel {
  final String id;
  final String accountId;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final TransactionCategory category;
  final DateTime date;
  final String referenceNumber;
  final double balanceAfter;
  final String? receiverName;
  final String? receiverAccount;

  TransactionModel({
    required this.id,
    required this.accountId,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.referenceNumber,
    required this.balanceAfter,
    this.receiverName,
    this.receiverAccount,
  });
}