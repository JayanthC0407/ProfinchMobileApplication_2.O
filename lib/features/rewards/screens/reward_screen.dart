import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../provider/reward_provider.dart';
import '../widgets/reward_points_card.dart';
import '../widgets/offer_card.dart';
import '../widgets/reward_history_tile.dart';
import '../widgets/voucher_card.dart';

class RewardsScreen extends StatefulWidget {
  final int initialTab;
  const RewardsScreen({super.key, this.initialTab = 0,});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab,);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmRedeem(
      BuildContext context, voucher, RewardsProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: voucher.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(voucher.icon, color: voucher.color, size: 28),
            ),
            const SizedBox(height: 14),
            Text(voucher.title,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(voucher.description,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500),
                textAlign: TextAlign.center),
            const SizedBox(height: 20),
            // Cost row
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Points required',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  Text('${voucher.pointsRequired} pts',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF7C3AED))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('You get',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                  Text(voucher.value,
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: voucher.color)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final success =
                          provider.redeemVoucher(voucher.id);
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success
                              ? '🎉 ${voucher.title} redeemed!'
                              : 'Insufficient points'),
                          backgroundColor: success
                              ? Colors.green.shade600
                              : Colors.red.shade600,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Redeem Now',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RewardsProvider(),
      child: Builder(builder: (context) {
        final provider = context.watch<RewardsProvider>();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Rewards',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14),
              tabs: const [
                Tab(text: 'Overview'),
                Tab(text: 'Vouchers'),
                Tab(text: 'Offers'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [

              // ── Tab 1: Overview ──────────────────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RewardsPointsCard(
                      totalPoints: provider.totalPoints,
                      redeemedPoints: provider.redeemedPoints,
                    ),
                    const SizedBox(height: 20),

                    // Quick redeem
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Quick Redeem',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E))),
                        TextButton(
                          onPressed: () =>
                              _tabController.animateTo(1),
                          child: const Text('See All'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...provider.availableVouchers.take(3).map(
                          (v) => VoucherCard(
                            voucher: v,
                            availablePoints: provider.totalPoints,
                            onRedeem: () =>
                                _confirmRedeem(context, v, provider),
                          ),
                        ),

                    const SizedBox(height: 20),

                    // Points history
                    const Text('Points History',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    ...provider.rewards.map(
                        (r) => RewardHistoryTile(reward: r)),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // ── Tab 2: Vouchers ──────────────────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Points banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF7C3AED)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFF7C3AED)
                                .withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.stars_rounded,
                              color: Color(0xFF7C3AED), size: 20),
                          const SizedBox(width: 10),
                          Text(
                            'You have ${provider.totalPoints} pts available to redeem',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Available vouchers
                    const Text('Available Vouchers',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    ...provider.availableVouchers.map(
                      (v) => VoucherCard(
                        voucher: v,
                        availablePoints: provider.totalPoints,
                        onRedeem: () =>
                            _confirmRedeem(context, v, provider),
                      ),
                    ),

                    // Redeemed vouchers
                    if (provider.redeemedVouchers.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      const Text('Redeemed',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 12),
                      ...provider.redeemedVouchers.map(
                        (v) => Opacity(
                          opacity: 0.5,
                          child: VoucherCard(
                            voucher: v,
                            availablePoints: 0,
                            onRedeem: () {},
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // ── Tab 3: Offers ────────────────────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Active Offers',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 14),

                    // Horizontal scrolling offer cards
                    SizedBox(
                      height: 160,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: provider.offers.length,
                        itemBuilder: (_, i) =>
                            OfferCard(offer: provider.offers[i]),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // All offers as list
                    const Text('All Offers',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 12),
                    ...provider.offers.map((offer) {
                      final daysLeft = offer.validTill
                          .difference(DateTime.now())
                          .inDays;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                color: offer.color
                                    .withValues(alpha: 0.1),
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Icon(offer.icon,
                                  color: offer.color, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(offer.title,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1A1A2E))),
                                  const SizedBox(height: 3),
                                  Text(offer.description,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade500),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: offer.color
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: Text(offer.tag,
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: offer.color)),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$daysLeft days left',
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}