import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';
import 'package:profinch_mobile_application/features/notifications/widgets/notification_widget.dart';
import 'notification_detail_screen.dart';

/// Inbox, restructured to match the reference OBDX layout: three tabs
/// split by *source* rather than by read-status/category —
///   Mails         → real mailbox mails (getMails)
///   Alerts (N)    → real mailbox alerts (getAlerts), N = unread count
///   Notifications → locally-generated in-app notifications (bill pay,
///                   send money, transfer confirmations, offers, etc.)
/// — instead of the previous All/Unread/Transactions/Offers tabs, which
/// mixed server and local items together in every tab.
///
/// Tapping any item now opens NotificationDetailScreen (full message
/// view) instead of just marking read in place.
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load real alerts/mails from the mailbox API as soon as the screen
    // opens — the bell badge on the dashboard only has the lightweight
    // count until now.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().currentUser?.id ?? '';
      if (userId.isNotEmpty) {
        context.read<NotificationProvider>().loadNotifications(userId);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<NotificationModel> _mails(List<NotificationModel> all) =>
      all.where((n) => n.serverSource == 'mail').toList();

  List<NotificationModel> _alerts(List<NotificationModel> all) =>
      all.where((n) => n.serverSource == 'alert').toList();

  // Real mailers (GET .../mailbox/mailers) plus locally-generated in-app
  // notifications (bill pay, transfers, offers) — both are "general
  // notifications" that don't fit the more specific Mail/Alert buckets.
  List<NotificationModel> _notifications(List<NotificationModel> all) => all
      .where((n) => n.serverSource == 'mailer' || n.serverSource == null)
      .toList();

  void _openDetail(NotificationModel n) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationDetailScreen(notification: n)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Inbox',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppFontSize.large(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final list = provider.getByUserId(userId);
              return list.isNotEmpty
                  ? IconButton(
                      icon: const Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.white70,
                      ),
                      tooltip: 'Clear all',
                      onPressed: () =>
                          _confirmClearAll(context, provider, userId),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              final all = provider.getByUserId(userId);
              final unreadAlerts =
                  _alerts(all).where((n) => !n.isRead).length;

              return TabBar(
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
                tabs: [
                  const Tab(text: 'Mails'),
                  Tab(text: unreadAlerts > 0 ? 'Alerts ($unreadAlerts)' : 'Alerts'),
                  const Tab(text: 'Notifications'),
                ],
              );
            },
          ),
        ),
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          final all = provider.getByUserId(userId);

          return TabBarView(
            controller: _tabController,
            children: [
              _tabBody(context, _mails(all), provider, userId, 'Mails'),
              _tabBody(context, _alerts(all), provider, userId, 'Alerts'),
              _tabBody(
                  context, _notifications(all), provider, userId, 'Notifications'),
            ],
          );
        },
      ),
    );
  }

  /// Each tab gets its own explicit "Refresh" link (matching the
  /// reference layout) in addition to pull-to-refresh, since the
  /// reference shows it as a persistent, discoverable action rather than
  /// relying on a swipe gesture alone.
  Widget _tabBody(
    BuildContext context,
    List<NotificationModel> list,
    NotificationProvider provider,
    String userId,
    String tabLabel,
  ) {
    return RefreshIndicator(
      onRefresh: () => provider.loadNotifications(userId),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Align(
              alignment: Alignment.centerRight,
              child: GestureDetector(
                onTap: () => provider.loadNotifications(userId),
                child: Text(
                  'Refresh',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.small(context),
                  ),
                ),
              ),
            ),
          ),
          Expanded(child: _buildList(context, list, provider, tabLabel)),
        ],
      ),
    );
  }

  Widget _buildList(
    BuildContext context,
    List<NotificationModel> list,
    NotificationProvider provider,
    String tabLabel,
  ) {
    if (list.isEmpty) return _buildEmptyState(context, tabLabel);

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
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        if (today.isNotEmpty) ...[
          _sectionHeader(context, 'Today'),
          ...today.map(
            (n) => NotificationTile(
              notification: n,
              onTap: () => _openDetail(n),
              onDismiss: () => provider.deleteNotification(n.id),
            ),
          ),
        ],
        if (yesterday.isNotEmpty) ...[
          _sectionHeader(context, 'Yesterday'),
          ...yesterday.map(
            (n) => NotificationTile(
              notification: n,
              onTap: () => _openDetail(n),
              onDismiss: () => provider.deleteNotification(n.id),
            ),
          ),
        ],
        if (older.isNotEmpty) ...[
          _sectionHeader(context, 'Earlier'),
          ...older.map(
            (n) => NotificationTile(
              notification: n,
              onTap: () => _openDetail(n),
              onDismiss: () => provider.deleteNotification(n.id),
            ),
          ),
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

  Widget _buildEmptyState(BuildContext context, String tabLabel) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ListView(
          // Needed so RefreshIndicator has something to pull against even
          // when there's nothing to show yet.
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'No item in $tabLabel',
                      style: TextStyle(
                        fontSize: AppFontSize.medium(context),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _confirmClearAll(
    BuildContext context,
    NotificationProvider provider,
    String userId,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade600),
            ),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}