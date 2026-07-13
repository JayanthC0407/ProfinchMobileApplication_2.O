import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';

class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDismiss,
  });

  // ── Icon & color per type ─────────────────────────────────────
  static _NotificationStyle _style(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return _NotificationStyle(
          icon: Icons.swap_horiz_rounded,
          color: const Color(0xFF1565C0),
          bg: const Color(0xFFE3F0FF),
        );
      case NotificationType.loan:
        return _NotificationStyle(
          icon: Icons.account_balance_rounded,
          color: const Color(0xFF6A1B9A),
          bg: const Color(0xFFF3E5F5),
        );
      case NotificationType.termDeposit:
        return _NotificationStyle(
          icon: Icons.savings_rounded,
          color: const Color(0xFF00695C),
          bg: const Color(0xFFE0F2F1),
        );
      case NotificationType.card:
        return _NotificationStyle(
          icon: Icons.credit_card_rounded,
          color: const Color(0xFFC62828),
          bg: const Color(0xFFFFEBEE),
        );
      case NotificationType.upi:
        return _NotificationStyle(
          icon: Icons.phone_android_rounded,
          color: const Color(0xFF2E7D32),
          bg: const Color(0xFFDDF7E3),
        );
      case NotificationType.wallet:
        return _NotificationStyle(
          icon: Icons.account_balance_wallet_rounded,
          color: const Color(0xFFE65100),
          bg: const Color(0xFFFFF3E0),
        );
      case NotificationType.offer:
        return _NotificationStyle(
          icon: Icons.local_offer_rounded,
          color: const Color(0xFFF57F17),
          bg: const Color(0xFFFFFDE7),
        );
      case NotificationType.security:
        return _NotificationStyle(
          icon: Icons.security_rounded,
          color: const Color(0xFFB71C1C),
          bg: const Color(0xFFFFEBEE),
        );
      case NotificationType.system:
        return _NotificationStyle(
          icon: Icons.info_outline_rounded,
          color: const Color(0xFF37474F),
          bg: const Color(0xFFECEFF1),
        );
    }
  }

  // ── Time label ────────────────────────────────────────────────
  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final style = _style(notification.type);
    final unread = !notification.isRead;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: Colors.white, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: unread
                ? AppColors.primaryDark.withValues(alpha: 0.04)
                : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: unread
                  ? AppColors.primaryDark.withValues(alpha: 0.15)
                  : Colors.grey.shade100,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: style.bg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(style.icon, color: style.color, size: 22),
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: AppFontSize.body(context),
                              fontWeight: unread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: const Color(0xFF1A1A2E),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (unread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        fontSize: AppFontSize.small(context),
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(notification.createdAt),
                      style: TextStyle(
                        fontSize: AppFontSize.xs(context),
                        color: Colors.grey.shade400,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationStyle {
  final IconData icon;
  final Color color;
  final Color bg;
  const _NotificationStyle(
      {required this.icon, required this.color, required this.bg});
}