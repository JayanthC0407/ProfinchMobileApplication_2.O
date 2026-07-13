import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  final List<PaymentModel> _payments = [];

  // ── Getters ────────────────────────────────────────────────────

  List<PaymentModel> getByUserId(String userId) =>
      _payments.where((p) => p.userId == userId).toList();

  List<PaymentModel> scheduled(String userId) => getByUserId(userId)
      .where((p) =>
          p.status == PaymentStatus.pending &&
          p.scheduledDate.isAfter(DateTime.now()))
      .toList()
    ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

  List<PaymentModel> favourites(String userId) => getByUserId(userId)
      .where((p) => p.isFavourite)
      .toList()
    ..sort((a, b) => b.useCount.compareTo(a.useCount));

  /// Top transfers by use count — deduplicated by receiverAccount.
  List<PaymentModel> frequentlyUsed(String userId, {int limit = 6}) {
    final seen = <String>{};
    final result = <PaymentModel>[];
    final sorted = getByUserId(userId)
      ..sort((a, b) => b.useCount.compareTo(a.useCount));
    for (final p in sorted) {
      if (p.useCount > 0 && seen.add(p.receiverAccount)) {
        result.add(p);
        if (result.length >= limit) break;
      }
    }
    return result;
  }

  List<PaymentModel> dues(String userId) => getByUserId(userId)
      .where((p) => p.isDue)
      .toList()
    ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

  // ── Mutations ──────────────────────────────────────────────────

  void addPayment(PaymentModel payment) {
    _payments.add(payment);
    notifyListeners();
  }

  /// Called after every successful transfer to keep use-count up to date.
  /// Also handles rescheduling for repeating payments.
  void markCompleted(String id) {
    final i = _payments.indexWhere((p) => p.id == id);
    if (i == -1) return;
    final p = _payments[i];

    _payments[i] = p.copyWith(
      status: PaymentStatus.completed,
      useCount: p.useCount + 1,
    );

    // If repeating, clone a new pending entry for the next due date
    if (p.repeat != RepeatInterval.once) {
      final next = _nextDate(p.scheduledDate, p.repeat);
      _payments.add(p.copyWith(
        status: PaymentStatus.pending,
        scheduledDate: next,
        useCount: p.useCount + 1,
      ));
    }
    notifyListeners();
  }

  /// Increment use-count without marking completed (used for adhoc transfers
  /// that share a receiver with an existing payment entry).
  void incrementUsage(String userId, String receiverAccount) {
    for (int i = 0; i < _payments.length; i++) {
      if (_payments[i].userId == userId &&
          _payments[i].receiverAccount == receiverAccount) {
        _payments[i] =
            _payments[i].copyWith(useCount: _payments[i].useCount + 1);
      }
    }
    notifyListeners();
  }

  void toggleFavourite(String id) {
    final i = _payments.indexWhere((p) => p.id == id);
    if (i == -1) return;
    _payments[i] =
        _payments[i].copyWith(isFavourite: !_payments[i].isFavourite);
    notifyListeners();
  }

  void cancelScheduled(String id) {
    final i = _payments.indexWhere((p) => p.id == id);
    if (i == -1) return;
    _payments[i] = _payments[i].copyWith(status: PaymentStatus.cancelled);
    notifyListeners();
  }

  void deletePayment(String id) {
    _payments.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  // ── Helpers ────────────────────────────────────────────────────

  DateTime _nextDate(DateTime from, RepeatInterval repeat) {
    switch (repeat) {
      case RepeatInterval.daily:   return from.add(const Duration(days: 1));
      case RepeatInterval.weekly:  return from.add(const Duration(days: 7));
      case RepeatInterval.monthly: return DateTime(from.year, from.month + 1, from.day);
      case RepeatInterval.once:    return from;
    }
  }
}