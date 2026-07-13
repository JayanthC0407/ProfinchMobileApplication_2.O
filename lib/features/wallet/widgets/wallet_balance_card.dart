import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WalletBalanceCard extends StatelessWidget {
  final double walletBalance;
  final double dailyLimit;
  final double remainingDailyLimit;

  const WalletBalanceCard({
    super.key,
    required this.walletBalance,
    required this.dailyLimit,
    required this.remainingDailyLimit,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    final usedPercent = ((dailyLimit - remainingDailyLimit) / dailyLimit).clamp(
      0.0,
      1.0,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 6, 29, 141),
            Color.fromARGB(255, 10, 187, 128),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row ───────────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'ProFinch Wallet',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 13,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Balance ───────────────────────────────────────────
          Text(
            '₹${formatter.format(walletBalance)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'Available Balance',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),

          const SizedBox(height: 20),

          // ── Daily limit bar ───────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Limit Used',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              Text(
                '₹${formatter.format(dailyLimit - remainingDailyLimit)} / ₹${formatter.format(dailyLimit)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: usedPercent,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                usedPercent > 0.8 ? Colors.orangeAccent : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
