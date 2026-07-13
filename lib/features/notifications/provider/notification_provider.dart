import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/dummy/dummy_notifications.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final List<NotificationModel> _notifications =
      List.from(DummyNotifications.notifications);

  //preferences
  bool pushEnabled = true;
  bool smsEnabled = true;
  bool emailEnabled = false;
  bool transactionAlertsEnabled = true;
  bool promoAlertsEnabled = false;

  void updatePreferences({
    bool? push,
    bool? sms,
    bool? email,
    bool? transactionAlerts,
    bool? promoAlerts,
  }) {
    if (push != null) pushEnabled = push;
    if (sms != null) smsEnabled = sms;
    if (email != null) emailEnabled = email;
    if (transactionAlerts != null) transactionAlertsEnabled = transactionAlerts;
    if (promoAlerts != null) promoAlertsEnabled = promoAlerts;
    notifyListeners();
  }

  List<NotificationModel> getByUserId(String userId) {
    final list = _notifications
        .where((n) => n.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  int unreadCount(String userId) =>
      _notifications.where((n) => n.userId == userId && !n.isRead).length;

  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _notifications[index].isRead = true;
    notifyListeners();
  }

  void markAllAsRead(String userId) {
    for (final n in _notifications) {
      if (n.userId == userId) n.isRead = true;
    }
    notifyListeners();
  }

  void deleteNotification(String id) {
    _notifications.removeWhere((n) => n.id == id);
    notifyListeners();
  }

  void clearAll(String userId) {
    _notifications.removeWhere((n) => n.userId == userId);
    notifyListeners();
  }

  void addNotification(NotificationModel notification) {
    if (!pushEnabled) return;

    const transactionTypes = {
      NotificationType.transaction,
      NotificationType.upi,
      NotificationType.wallet,
    };

    const promoTypes = {
      NotificationType.offer,
    };

    if (!transactionAlertsEnabled && transactionTypes.contains(notification.type)) return;
    if (!promoAlertsEnabled && promoTypes.contains(notification.type)) return;

    _notifications.insert(0, notification);
    notifyListeners();
  }
}