import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';
import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';

class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends State<NotificationDetailScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context
          .read<NotificationProvider>()
          .markAsRead(widget.notification.id);
    });
  }

  void _handleDelete() {
    context
        .read<NotificationProvider>()
        .deleteNotification(widget.notification.id);
    Navigator.pop(context);
  }

  // ── Style helpers — mirrors NotificationTile ──────────────────
  static _NotifStyle _style(NotificationType type) {
    switch (type) {
      case NotificationType.transaction:
        return _NotifStyle(
            icon: Icons.swap_horiz_rounded,
            color: const Color(0xFF1565C0),
            bg: const Color(0xFFE3F0FF),
            label: 'Transaction');
      case NotificationType.loan:
        return _NotifStyle(
            icon: Icons.account_balance_rounded,
            color: const Color(0xFF6A1B9A),
            bg: const Color(0xFFF3E5F5),
            label: 'Loan');
      case NotificationType.termDeposit:
        return _NotifStyle(
            icon: Icons.savings_rounded,
            color: const Color(0xFF00695C),
            bg: const Color(0xFFE0F2F1),
            label: 'Term Deposit');
      case NotificationType.card:
        return _NotifStyle(
            icon: Icons.credit_card_rounded,
            color: const Color(0xFFC62828),
            bg: const Color(0xFFFFEBEE),
            label: 'Card');
      case NotificationType.upi:
        return _NotifStyle(
            icon: Icons.phone_android_rounded,
            color: const Color(0xFF2E7D32),
            bg: const Color(0xFFDDF7E3),
            label: 'UPI');
      case NotificationType.wallet:
        return _NotifStyle(
            icon: Icons.account_balance_wallet_rounded,
            color: const Color(0xFFE65100),
            bg: const Color(0xFFFFF3E0),
            label: 'Wallet');
      case NotificationType.offer:
        return _NotifStyle(
            icon: Icons.local_offer_rounded,
            color: const Color(0xFFF57F17),
            bg: const Color(0xFFFFFDE7),
            label: 'Offer');
      case NotificationType.security:
        return _NotifStyle(
            icon: Icons.security_rounded,
            color: const Color(0xFFB71C1C),
            bg: const Color(0xFFFFEBEE),
            label: 'Security');
      case NotificationType.system:
        return _NotifStyle(
            icon: Icons.info_outline_rounded,
            color: const Color(0xFF37474F),
            bg: const Color(0xFFECEFF1),
            label: 'System');
    }
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;
    final s = _style(n.type);
    final fmt = DateFormat('dd MMM yyyy  •  hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.light),
        title: Text(
          'Notification',
          style: TextStyle(
            color: AppColors.light,
            fontSize: AppFontSize.large(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded,
                color: AppColors.light),
            tooltip: 'Delete',
            onPressed: _handleDelete,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Type + timestamp header card ──────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: s.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: s.color.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: s.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(s.icon, color: s.color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: s.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              s.label,
                              style: TextStyle(
                                color: s.color,
                                fontSize: AppFontSize.xs(context),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            fmt.format(n.createdAt.toLocal()),
                            style: AppTextStyles.caption(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── Message card ──────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      n.title,
                      style: AppTextStyles.title(context),
                    ),
                    const SizedBox(height: 12),
                    const Divider(
                        height: 1, color: AppColors.surfaceLight),
                    const SizedBox(height: 16),
                    // Body
                    Text(
                      n.body,
                      style: AppTextStyles.bodySecondary(context)
                          .copyWith(height: 1.7),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Delete button ─────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: _handleDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: BorderSide(
                        color: AppColors.error.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('Delete notification'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotifStyle {
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;

  const _NotifStyle({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
  });
}