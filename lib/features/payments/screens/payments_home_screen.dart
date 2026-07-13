import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/payment_model.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/payments/provider/payment_provider.dart';
import 'package:provider/provider.dart';

class PaymentsHomeScreen extends StatefulWidget {
  const PaymentsHomeScreen({super.key});

  @override
  State<PaymentsHomeScreen> createState() => _PaymentsHomeScreenState();
}

class _PaymentsHomeScreenState extends State<PaymentsHomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.blueButton],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.light),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Text('Payments',
                        style: AppTextStyles.whiteHeading(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      'Adhoc, Scheduled & Favourites',
                      style: AppTextStyles.whiteBody(context,
                          color: AppColors.light.withValues(alpha: 0.7)),
                    ),
                  ),

                  // Quick action buttons
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.send_rounded,
                            label: 'Adhoc Transfer',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.adhocTransfer),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.schedule_rounded,
                            label: 'Schedule Payment',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.scheduledPayment),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.star_rounded,
                            label: 'Favourites',
                            onTap: () => Navigator.pushNamed(context, AppRoutes.favourites),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab bar
                  TabBar(
                    controller: _tabs,
                    indicatorColor: AppColors.light,
                    labelColor: AppColors.light,
                    unselectedLabelColor:
                        AppColors.light.withValues(alpha: 0.5),
                    labelStyle: AppTextStyles.smallBold(context,
                        color: AppColors.light),
                    tabs: const [
                      Tab(text: 'Scheduled'),
                      Tab(text: 'Favourites'),
                      Tab(text: 'Frequent'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Tab content ───────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: const [
                _ScheduledTab(),
                _FavouritesTab(),
                _FrequentTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Tabs ───────────────────────────────────────────────────────────────────

class _ScheduledTab extends StatelessWidget {
  const _ScheduledTab();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;
    final provider = Provider.of<PaymentProvider>(context);
    final scheduled = provider.scheduled(user.id);
    final dues      = provider.dues(user.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (dues.isNotEmpty) ...[
            _SectionHeader(
              icon: Icons.warning_amber_rounded,
              label: 'Due Now',
              color: AppColors.error,
            ),
            const SizedBox(height: 8),
            ...dues.map((p) => _ScheduledCard(
                  payment: p,
                  isDue: true,
                  onCancel: () => provider.cancelScheduled(p.id),
                )),
            const SizedBox(height: 16),
          ],
          _SectionHeader(
            icon: Icons.schedule_rounded,
            label: 'Upcoming',
            color: AppColors.primary,
          ),
          const SizedBox(height: 8),
          if (scheduled.isEmpty)
            _EmptyCard(
              icon: Icons.schedule_outlined,
              message: 'No scheduled payments.\nTap "Schedule Payment" to set one up.',
            )
          else
            ...scheduled.map((p) => _ScheduledCard(
                  payment: p,
                  onCancel: () => provider.cancelScheduled(p.id),
                )),
        ],
      ),
    );
  }
}

class _FavouritesTab extends StatelessWidget {
  const _FavouritesTab();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;
    final provider = Provider.of<PaymentProvider>(context);
    final favs = provider.favourites(user.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (favs.isEmpty)
            _EmptyCard(
              icon: Icons.star_border_rounded,
              message:
                  'No favourites yet.\nStar a payment to pin it here for quick access.',
            )
          else
            ...favs.map((p) => _FavouriteCard(
                  payment: p,
                  onToggle: () => provider.toggleFavourite(p.id),
                )),
        ],
      ),
    );
  }
}

class _FrequentTab extends StatelessWidget {
  const _FrequentTab();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;
    final frequent = Provider.of<PaymentProvider>(context)
        .frequentlyUsed(user.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (frequent.isEmpty)
            _EmptyCard(
              icon: Icons.bolt_outlined,
              message:
                  'Your frequently used transfers will appear here automatically.',
            )
          else
            ...frequent.map((p) => _FrequentCard(payment: p)),
        ],
      ),
    );
  }
}

// ── Card widgets ───────────────────────────────────────────────────────────

class _ScheduledCard extends StatelessWidget {
  final PaymentModel payment;
  final bool isDue;
  final VoidCallback onCancel;

  const _ScheduledCard({
    required this.payment,
    required this.onCancel,
    this.isDue = false,
  });

  static const _repeatLabels = {
    RepeatInterval.once:    'One-time',
    RepeatInterval.daily:   'Daily',
    RepeatInterval.weekly:  'Weekly',
    RepeatInterval.monthly: 'Monthly',
  };

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDue ? AppColors.errorLight : AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDue
              ? AppColors.error.withValues(alpha: 0.3)
              : AppColors.grey200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isDue
                    ? AppColors.error.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.1),
                child: Icon(
                  isDue
                      ? Icons.priority_high_rounded
                      : Icons.schedule_rounded,
                  color: isDue ? AppColors.error : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.receiverName,
                        style: AppTextStyles.bodyBold(context)),
                    Text(
                      '₹ ${payment.amount.toStringAsFixed(2)}  •  '
                      '${_repeatLabels[payment.repeat]}',
                      style: AppTextStyles.small(context),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(_fmt(payment.scheduledDate),
                      style: AppTextStyles.smallBold(context,
                          color: isDue
                              ? AppColors.error
                              : AppColors.textPrimary)),
                  Text(payment.transferMode,
                      style: AppTextStyles.caption(context)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: EdgeInsets.zero),
                child: Text('Cancel',
                    style: AppTextStyles.small(context,
                        color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FavouriteCard extends StatelessWidget {
  final PaymentModel payment;
  final VoidCallback onToggle;

  const _FavouriteCard({required this.payment, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.warning.withValues(alpha: 0.12),
            child: Text(payment.receiverName[0].toUpperCase(),
                style: AppTextStyles.title(context,
                    color: AppColors.warning)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.receiverName,
                    style: AppTextStyles.bodyBold(context)),
                Text(
                  '${payment.receiverBank}  •  '
                  '₹ ${payment.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.small(context),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onToggle,
            icon: const Icon(Icons.star_rounded,
                color: AppColors.warning, size: 22),
            tooltip: 'Remove from favourites',
          ),
        ],
      ),
    );
  }
}

class _FrequentCard extends StatelessWidget {
  final PaymentModel payment;

  const _FrequentCard({required this.payment});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Text(payment.receiverName[0].toUpperCase(),
                style: AppTextStyles.title(context,
                    color: AppColors.primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.receiverName,
                    style: AppTextStyles.bodyBold(context)),
                Text(
                  '${payment.transferMode}  •  '
                  '₹ ${payment.amount.toStringAsFixed(2)}',
                  style: AppTextStyles.small(context),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('${payment.useCount}×',
                style: AppTextStyles.smallBold(context,
                    color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// ── Shared helpers ─────────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.light.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: AppColors.light.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.light, size: 22),
            const SizedBox(height: 5),
            Text(label,
                textAlign: TextAlign.center,
                style: AppTextStyles.small(context, color: AppColors.light)
                    .copyWith(fontSize: 10),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.title(context, color: color)),
      ],
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyCard({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.grey400),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodySecondary(context)),
        ],
      ),
    );
  }
}