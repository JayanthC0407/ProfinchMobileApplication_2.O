enum CardType { debit, credit }

class CardModel {
  final String id;
  final String userId;
  final String cardNumber;      // last 4 digits only
  final String cardHolderName;
  final String expiryDate;
  final CardType cardType;
  final String network;          // Visa / Mastercard / RuPay
  final double creditLimit;      // 0 for debit
  final double usedAmount;       // 0 for debit
  final bool isActive;
  final bool isFrozen;
  final bool isInternationalEnabled;
  final bool isOnlinePaymentEnabled;
  final double atmLimit;
  final int rewardPoints;

  CardModel({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cardType,
    required this.network,
    required this.creditLimit,
    required this.usedAmount,
    required this.isActive,
    required this.isFrozen,
    required this.isInternationalEnabled,
    required this.isOnlinePaymentEnabled,
    required this.atmLimit,
    required this.rewardPoints,
  });

  double get availableLimit => creditLimit - usedAmount;
}
