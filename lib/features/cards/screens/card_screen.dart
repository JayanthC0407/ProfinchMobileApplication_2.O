// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/data/models/card_model.dart';
import '../provider/card_provider.dart';
import '../widgets/card_widget.dart';
import '../widgets/card_limit_widget.dart';
import '../widgets/card_settings_tile.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key});

  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.light),
        title: Text(
          'My Cards',
          style: AppTextStyles.whiteTitle(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.light),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.applyCard);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.light,
          indicatorWeight: 3,
          labelColor: AppColors.light,
          unselectedLabelColor: AppColors.light.withValues(alpha: 0.54),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppFontSize.body(context),
          ),
          tabs: const [
            Tab(text: 'Debit Card'),
            Tab(text: 'Credit Card'),
          ],
        ),
      ),
      body: Consumer<CardProvider>(
        builder: (context, provider, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildCardTab(context, provider.debitCard, provider),
              _buildCardTab(context, provider.creditCard, provider),
            ],
          );
        },
      ),
    );
  }

  // ── Card Tab ───────────────────────────────────────────────────
  Widget _buildCardTab(
    BuildContext context,
    CardModel card,
    CardProvider provider,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Card visual ────────────────────────────────────────
          CardWidget(card: card),

          const SizedBox(height: 20),

          // ── Quick actions ──────────────────────────────────────
          Row(
            children: [
              _buildQuickAction(
                icon: card.isFrozen
                    ? Icons.ac_unit_rounded
                    : Icons.ac_unit_outlined,
                label: card.isFrozen ? 'Unfreeze' : 'Freeze',
                color: card.isFrozen ? Colors.lightBlue : AppColors.primary,
                onTap: () => provider.toggleFreeze(card.id),
              ),
              const SizedBox(width: 12),
              _buildQuickAction(
                icon: Icons.pin_outlined,
                label: 'Change PIN',
                color: AppColors.primary,
                onTap: () => _showChangePinDialog(context),
              ),
              const SizedBox(width: 12),
              _buildQuickAction(
                icon: Icons.block_outlined,
                label: 'Block Card',
                color: AppColors.error,
                onTap: () => _showBlockCardDialog(context, card),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Credit limit bar (credit card only) ────────────────
          if (card.cardType == CardType.credit) ...[
            CardLimitWidget(card: card),
            const SizedBox(height: 20),
          ],

          // ── Reward points (credit card only) ──────────────────
          if (card.cardType == CardType.credit) ...[
            _buildRewardPoints(context, card),
            const SizedBox(height: 20),
          ],

          // ── ATM limit ──────────────────────────────────────────
          _buildAtmLimitCard(context, card, provider),

          const SizedBox(height: 20),

          // ── Card settings ──────────────────────────────────────
          Text(
            'Card Settings',
            style: TextStyle(
              fontSize: AppFontSize.medium(context),
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          CardSettingsTile(
            icon: Icons.language_rounded,
            title: 'International Transactions',
            subtitle: 'Enable payments outside India',
            value: card.isInternationalEnabled,
            onChanged: (_) => provider.toggleInternational(card.id),
          ),

          CardSettingsTile(
            icon: Icons.shopping_cart_outlined,
            title: 'Online Payments',
            subtitle: 'Enable e-commerce & app payments',
            value: card.isOnlinePaymentEnabled,
            onChanged: (_) => provider.toggleOnlinePayment(card.id),
          ),

          CardSettingsTile(
            icon: Icons.contactless_outlined,
            title: 'Contactless Payments',
            subtitle: 'Enable tap & pay (NFC)',
            value: true,
            onChanged: (_) {},
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  // ── Quick action button ────────────────────────────────────────
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.light,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: AppFontSize.small(context),
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── ATM Limit card ─────────────────────────────────────────────
  Widget _buildAtmLimitCard(
    BuildContext context,
    CardModel card,
    CardProvider provider,
  ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily ATM Limit',
                style: TextStyle(
                  fontSize: AppFontSize.body(context),
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '₹${card.atmLimit.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: AppFontSize.large(context), 
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          TextButton.icon(
            onPressed: () => _showAtmLimitDialog(context, card, provider),
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('Change'),
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  // ── Reward points card ─────────────────────────────────────────
  Widget _buildRewardPoints(BuildContext context, CardModel card) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.textPrimary, Color(0xFF7C3AED), Color(0xFF0F3460)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reward Points',
                    style: TextStyle(fontSize: AppFontSize.body(context), color: AppColors.light.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${card.rewardPoints} pts',
                    style: TextStyle(
                      fontSize: AppFontSize.xl(context),
                      fontWeight: FontWeight.w700,
                      color: AppColors.light,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '≈ ₹${(card.rewardPoints / 10).toStringAsFixed(0)} cashback value',
                    style: TextStyle(fontSize: AppFontSize.small(context), color: AppColors.light.withValues(alpha: 0.54)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.light.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  color: Colors.amber,
                  size: 22,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ✅ Redeem button now navigates to RewardsScreen
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.rewards,
                ); // ← connects here
              },
              icon: const Icon(Icons.card_giftcard_outlined, size: 18),
              label: const Text('Redeem Points'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.light,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dialogs ────────────────────────────────────────────────────
  void _showChangePinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change PIN'),
        content: const Text(
          'A PIN change request will be sent to your registered mobile number.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement PIN change
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.light,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _showBlockCardDialog(BuildContext context, CardModel card) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Block Card'),
        content: Text(
          'Are you sure you want to permanently block card ending in ${card.cardNumber}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement card block
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.light,
            ),
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _showAtmLimitDialog(
    BuildContext context,
    CardModel card,
    CardProvider provider,
  ) {
    double selectedLimit = card.atmLimit;
    final limits = [10000.0, 25000.0, 50000.0, 100000.0];

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Set ATM Limit',
                style: TextStyle(fontSize: AppFontSize.large(context), fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              ...limits.map(
                (limit) => RadioListTile<double>(
                  value: limit,
                  groupValue: selectedLimit,
                  title: Text('₹${limit.toStringAsFixed(0)}'),
                  activeColor: AppColors.primary,
                  onChanged: (val) => setModalState(() => selectedLimit = val!),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    provider.updateAtmLimit(card.id, selectedLimit);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: AppColors.light,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save Limit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
