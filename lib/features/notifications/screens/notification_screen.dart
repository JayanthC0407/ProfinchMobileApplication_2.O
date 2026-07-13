import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';
import 'package:profinch_mobile_application/features/notifications/widgets/notification_widget.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['All', 'Unread', 'Transactions', 'Offers'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationModel> _filtered(
      List<NotificationModel> all, int tabIndex) {
    switch (tabIndex) {
      case 1:
        return all.where((n) => !n.isRead).toList();
      case 2:
        return all
            .where((n) =>
                n.type == NotificationType.transaction ||
                n.type == NotificationType.upi ||
                n.type == NotificationType.wallet)
            .toList();
      case 3:
        return all.where((n) => n.type == NotificationType.offer).toList();
      default:
        return all;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userId =
        context.read<AuthProvider>().currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppFontSize.large(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final hasUnread = provider.unreadCount(userId) > 0;
              return hasUnread
                  ? TextButton(
                      onPressed: () => provider.markAllAsRead(userId),
                      child: Text(
                        'Mark all read',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: AppFontSize.small(context),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final list = provider.getByUserId(userId);
              return list.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.delete_sweep_outlined,
                          color: Colors.white70),
                      tooltip: 'Clear all',
                      onPressed: () => _confirmClearAll(context, provider, userId),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle: TextStyle(
            fontSize: AppFontSize.small(context),
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: AppFontSize.small(context),
            fontWeight: FontWeight.w500,
          ),
          tabs: _tabs.map((t) => Tab(text: t)).toList(),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          final all = provider.getByUserId(userId);

          return TabBarView(
            controller: _tabController,
            children: List.generate(_tabs.length, (i) {
              final list = _filtered(all, i);
              return _buildList(context, list, provider, userId);
            }),
          );
        },
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<NotificationModel> list,
    NotificationProvider provider,
    String userId,
  ) {
    if (list.isEmpty) return _buildEmptyState(context);

    // Group by date
    final today = <NotificationModel>[];
    final yesterday = <NotificationModel>[];
    final older = <NotificationModel>[];

    final now = DateTime.now();
    for (final n in list) {
      final diff = now.difference(n.createdAt).inDays;
      if (diff == 0) {
        today.add(n);
      } else if (diff == 1) {
        yesterday.add(n);
      } else {
        older.add(n);
      }
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (today.isNotEmpty) ...[
          _sectionHeader(context, 'Today'),
          ...today.map((n) => NotificationTile(
                notification: n,
                onTap: () => provider.markAsRead(n.id),
                onDismiss: () => provider.deleteNotification(n.id),
              )),
        ],
        if (yesterday.isNotEmpty) ...[
          _sectionHeader(context, 'Yesterday'),
          ...yesterday.map((n) => NotificationTile(
                notification: n,
                onTap: () => provider.markAsRead(n.id),
                onDismiss: () => provider.deleteNotification(n.id),
              )),
        ],
        if (older.isNotEmpty) ...[
          _sectionHeader(context, 'Earlier'),
          ...older.map((n) => NotificationTile(
                notification: n,
                onTap: () => provider.markAsRead(n.id),
                onDismiss: () => provider.deleteNotification(n.id),
              )),
        ],
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _sectionHeader(BuildContext context, String label) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppFontSize.small(context),
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_off_outlined,
              size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: AppFontSize.medium(context),
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              fontSize: AppFontSize.small(context),
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(
      BuildContext context, NotificationProvider provider, String userId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear all notifications?',
          style: TextStyle(
            fontSize: AppFontSize.medium(context),
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'This will permanently remove all notifications.',
          style: TextStyle(
            fontSize: AppFontSize.body(context),
            color: Colors.grey.shade600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade600)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.clearAll(userId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}