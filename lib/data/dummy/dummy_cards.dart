import 'package:profinch_mobile_application/data/models/card_model.dart';

class DummyCards {
  DummyCards._();

  static final CardModel debitCard = CardModel(
    id: 'CRD001',
    userId: 'USR001',
    cardNumber: '3210',
    cardHolderName: 'Arjun Sharma',
    expiryDate: '08/28',
    cardType: CardType.debit,
    network: 'RuPay',
    creditLimit: 0,
    usedAmount: 0,
    isActive: true,
    isFrozen: false,
    isInternationalEnabled: false,
    isOnlinePaymentEnabled: true,
    atmLimit: 25000,
    rewardPoints: 0,
  );

  static final CardModel creditCard = CardModel(
    id: 'CRD002',
    userId: 'USR001',
    cardNumber: '7890',
    cardHolderName: 'Arjun Sharma',
    expiryDate: '11/27',
    cardType: CardType.credit,
    network: 'Visa',
    creditLimit: 150000,
    usedAmount: 42350,
    isActive: true,
    isFrozen: false,
    isInternationalEnabled: true,
    isOnlinePaymentEnabled: true,
    atmLimit: 50000,
    rewardPoints: 3420,
  );

  static final List<CardModel> allCards = [debitCard, creditCard];
}
