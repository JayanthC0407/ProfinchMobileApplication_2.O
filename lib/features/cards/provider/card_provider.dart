import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/card_model.dart';
import 'package:profinch_mobile_application/data/dummy/dummy_cards.dart';

class CardProvider extends ChangeNotifier {
  final List<CardModel> _cards = List.from(DummyCards.allCards);

  List<CardModel> get cards => _cards;

  CardModel get debitCard =>
      _cards.firstWhere((c) => c.cardType == CardType.debit);

  CardModel get creditCard =>
      _cards.firstWhere((c) => c.cardType == CardType.credit);

  // ── Freeze / Unfreeze ──────────────────────────────────────────
  void toggleFreeze(String cardId) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;
    final card = _cards[index];
    _cards[index] = CardModel(
      id: card.id,
      userId: card.userId,
      cardNumber: card.cardNumber,
      cardHolderName: card.cardHolderName,
      expiryDate: card.expiryDate,
      cardType: card.cardType,
      network: card.network,
      creditLimit: card.creditLimit,
      usedAmount: card.usedAmount,
      isActive: card.isActive,
      isFrozen: !card.isFrozen,
      isInternationalEnabled: card.isInternationalEnabled,
      isOnlinePaymentEnabled: card.isOnlinePaymentEnabled,
      atmLimit: card.atmLimit,
      rewardPoints: card.rewardPoints,
    );
    notifyListeners();
  }

  // ── Toggle International ───────────────────────────────────────
  void toggleInternational(String cardId) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;
    final card = _cards[index];
    _cards[index] = CardModel(
      id: card.id,
      userId: card.userId,
      cardNumber: card.cardNumber,
      cardHolderName: card.cardHolderName,
      expiryDate: card.expiryDate,
      cardType: card.cardType,
      network: card.network,
      creditLimit: card.creditLimit,
      usedAmount: card.usedAmount,
      isActive: card.isActive,
      isFrozen: card.isFrozen,
      isInternationalEnabled: !card.isInternationalEnabled,
      isOnlinePaymentEnabled: card.isOnlinePaymentEnabled,
      atmLimit: card.atmLimit,
      rewardPoints: card.rewardPoints,
    );
    notifyListeners();
  }

  // ── Toggle Online Payment ──────────────────────────────────────
  void toggleOnlinePayment(String cardId) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;
    final card = _cards[index];
    _cards[index] = CardModel(
      id: card.id,
      userId: card.userId,
      cardNumber: card.cardNumber,
      cardHolderName: card.cardHolderName,
      expiryDate: card.expiryDate,
      cardType: card.cardType,
      network: card.network,
      creditLimit: card.creditLimit,
      usedAmount: card.usedAmount,
      isActive: card.isActive,
      isFrozen: card.isFrozen,
      isInternationalEnabled: card.isInternationalEnabled,
      isOnlinePaymentEnabled: !card.isOnlinePaymentEnabled,
      atmLimit: card.atmLimit,
      rewardPoints: card.rewardPoints,
    );
    notifyListeners();
  }

  // ── Update ATM Limit ───────────────────────────────────────────
  void updateAtmLimit(String cardId, double newLimit) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;
    final card = _cards[index];
    _cards[index] = CardModel(
      id: card.id,
      userId: card.userId,
      cardNumber: card.cardNumber,
      cardHolderName: card.cardHolderName,
      expiryDate: card.expiryDate,
      cardType: card.cardType,
      network: card.network,
      creditLimit: card.creditLimit,
      usedAmount: card.usedAmount,
      isActive: card.isActive,
      isFrozen: card.isFrozen,
      isInternationalEnabled: card.isInternationalEnabled,
      isOnlinePaymentEnabled: card.isOnlinePaymentEnabled,
      atmLimit: newLimit,
      rewardPoints: card.rewardPoints,
    );
    notifyListeners();
  }

   // ── Redeem Points ──────────────────────────────────────────────
  void redeemPoints(String cardId, int pointsToRedeem) {
    final index = _cards.indexWhere((c) => c.id == cardId);
    if (index == -1) return;
    final card = _cards[index];
    if (pointsToRedeem > card.rewardPoints) return;
    _cards[index] = CardModel(
      id: card.id,
      userId: card.userId,
      cardNumber: card.cardNumber,
      cardHolderName: card.cardHolderName,
      expiryDate: card.expiryDate,
      cardType: card.cardType,
      network: card.network,
      creditLimit: card.creditLimit,
      usedAmount: card.usedAmount,
      isActive: card.isActive,
      isFrozen: card.isFrozen,
      isInternationalEnabled: card.isInternationalEnabled,
      isOnlinePaymentEnabled: card.isOnlinePaymentEnabled,
      atmLimit: card.atmLimit,
      rewardPoints: card.rewardPoints - pointsToRedeem,
    );
    notifyListeners();
  }
}