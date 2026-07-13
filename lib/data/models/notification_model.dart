enum NotificationType {
  transaction,
  loan,
  termDeposit,
  card,
  upi,
  wallet,
  offer,
  security,
  system,
}

class NotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final NotificationType type;
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });
}