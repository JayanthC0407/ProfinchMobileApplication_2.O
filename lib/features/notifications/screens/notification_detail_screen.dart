import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';

/// Full message view — mirrors the reference OBDX web layout: timestamp
/// top-right, message body below, refresh/delete in the app bar, and a
/// "Back" link at the bottom in addition to the normal back arrow (kept
/// for parity with the reference even though the app bar already has one).
class NotificationDetailScreen extends StatefulWidget {
  final NotificationModel notification;

  const NotificationDetailScreen({super.key, required this.notification});

  @override
  State<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationProvider>().markAsRead(widget.notification.id);
    });
  }

  Future<void> _handleRefresh() async {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    if (userId.isEmpty) return;

    setState(() => _isRefreshing = true);
    await context.read<NotificationProvider>().loadNotifications(userId);
    if (!mounted) return;
    setState(() => _isRefreshing = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inbox refreshed'), duration: Duration(seconds: 1)),
    );
  }

  void _handleDelete() {
    context.read<NotificationProvider>().deleteNotification(widget.notification.id);
    Navigator.pop(context);
  }

  String _formatTimestamp(DateTime dt) {
    final local = dt.toLocal();
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final ampm = local.hour >= 12 ? 'PM' : 'AM';
    return '${local.month}/${local.day}/${local.year % 100}, $hour:$minute $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.notification;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.black87,
        titleSpacing: 0,
        title: Text(
          n.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: AppFontSize.body(context),
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: _isRefreshing ? null : _handleRefresh,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            tooltip: 'Delete',
            onPressed: _handleDelete,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Timestamp, right-aligned (matches reference) ──────
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  _formatTimestamp(n.createdAt),
                  style: TextStyle(
                    fontSize: AppFontSize.small(context),
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ── Message body ──────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    n.body,
                    style: TextStyle(
                      fontSize: AppFontSize.body(context),
                      color: const Color(0xFF1A1A2E),
                      height: 1.6,
                    ),
                  ),
                ),
              ),

              // ── Back link (in addition to the app bar's own back
              // arrow — kept to match the reference layout) ─────────
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  'Back',
                  style: TextStyle(
                    fontSize: AppFontSize.body(context),
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}