import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/dummy/dummy_notifications.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';
import 'package:profinch_mobile_application/data/repositories/notification_repository.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  final List<NotificationModel> _notifications =
      List.from(DummyNotifications.notifications);

  bool isLoading = false;
  String? loadError;

  /// Fast unread-count-only fetch (GET .../mailbox/count) — call right
  /// after login so the dashboard bell badge reflects real data without
  /// waiting on the full alert/mail bodies to load. Falls back to counting
  /// the in-memory list (below) until this resolves.
  Map<String, int>? _serverUnreadCounts;

  Future<void> loadUnreadCount(String userId) async {
    try {
      _serverUnreadCounts = await _repository.getUnreadCounts();
      notifyListeners();
    } catch (_) {
      // Non-fatal — unreadCount() below falls back to the local list.
    }
  }

  /// Full fetch of alerts + mails (GET .../mailbox/alerts and .../mails),
  /// mapped into [NotificationModel] and merged into the same in-memory
  /// list used for locally-generated mock notifications (bill pay, send
  /// money, transfer confirmations). Re-running this replaces only the
  /// previously-loaded server-sourced items — local mock ones are left
  /// untouched. Call this when the notifications screen opens (and on
  /// pull-to-refresh).
  Future<void> loadNotifications(String userId) async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getAlerts(),
        _repository.getMails(),
      ]);
      final alerts = results[0];
      final mails = results[1];

      final fetched = <NotificationModel>[
        ...alerts.map((j) => NotificationModel.fromAlertJson(j, userId: userId)),
        ...mails.map((j) => NotificationModel.fromMailJson(j, userId: userId)),
      ];

      // Drop this user's previously-loaded server items, then re-insert
      // the fresh set — local (non-server) notifications are untouched.
      _notifications.removeWhere(
        (n) => n.userId == userId && n.isServerSourced,
      );
      _notifications.addAll(fetched);

      // Once we have the real list, prefer counting unread from it over
      // the separate lightweight count endpoint.
      _serverUnreadCounts = null;
    } catch (e) {
      loadError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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

  int unreadCount(String userId) {
    // Prefer the authoritative server count when we have it (right after
    // login, before the full list loads) — falls back to counting the
    // in-memory list once loadNotifications has run or if the count
    // endpoint failed.
    if (_serverUnreadCounts != null) {
      return _serverUnreadCounts!.values.fold(0, (a, b) => a + b);
    }
    return _notifications.where((n) => n.userId == userId && !n.isRead).length;
  }

  /// Marks a notification read locally (optimistic) and, if it's a
  /// server-sourced alert, fires the real PUT request too. Failures are
  /// swallowed rather than reverting the local state — a mark-as-read that
  /// silently fails to persist server-side is a minor annoyance, not worth
  /// flipping the UI back and confusing the user.
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final notification = _notifications[index];
    if (notification.isRead) return;

    notification.isRead = true;
    notifyListeners();

    if (notification.isServerSourced && notification.rawMessageType == 'A') {
      // Only alerts have a confirmed mark-as-read endpoint; mails' shape
      // (and whether the same endpoint applies) wasn't confirmed.
      try {
        await _repository.markAlertAsRead(
          alertId: notification.serverMessageIdValue!,
          displayValue: notification.serverMessageIdDisplayValue ?? '',
        );
      } catch (_) {
        // See method doc — intentionally not reverting local state.
      }
    }
  }

  Future<void> markAllAsRead(String userId) async {
    final toMark = _notifications.where(
      (n) => n.userId == userId && !n.isRead,
    ).toList();

    for (final n in toMark) {
      n.isRead = true;
    }
    notifyListeners();

    final serverAlerts = toMark.where(
      (n) => n.isServerSourced && n.rawMessageType == 'A',
    );
    for (final n in serverAlerts) {
      try {
        await _repository.markAlertAsRead(
          alertId: n.serverMessageIdValue!,
          displayValue: n.serverMessageIdDisplayValue ?? '',
        );
      } catch (_) {
        // Best-effort — one failing shouldn't stop the rest.
      }
    }
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