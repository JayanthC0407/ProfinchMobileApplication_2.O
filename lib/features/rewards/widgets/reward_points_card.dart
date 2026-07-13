import 'package:flutter/material.dart';

class RewardsPointsCard extends StatelessWidget {
  final int totalPoints;
  final int redeemedPoints;

  const RewardsPointsCard({
    super.key,
    required this.totalPoints,
    required this.redeemedPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF7C3AED), Color(0xFF0F3460)],
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
                'ProFinch Rewards',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        color: Colors.amber, size: 14),
                    SizedBox(width: 4),
                    Text('Gold Member',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── Points ────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$totalPoints',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 8),
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  'pts',
                  style: TextStyle(
                      color: Colors.white60,
                      fontSize: 16,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          Text(
            'Available Reward Points',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 20),

          // ── Stats row ─────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: _statItem(
                  '≈ ₹${totalPoints ~/ 10}',
                  'Cash Value',
                  Icons.currency_rupee_rounded,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white24,
              ),
              Expanded(
                child: _statItem(
                  '$redeemedPoints pts',
                  'Redeemed',
                  Icons.check_circle_outline,
                ),
              ),
              Container(
                width: 1,
                height: 36,
                color: Colors.white24,
              ),
              Expanded(
                child: _statItem(
                  '180 days',
                  'Expiry',
                  Icons.timer_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white60, size: 16),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700)),
        Text(label,
            style:
                const TextStyle(color: Colors.white54, fontSize: 10)),
      ],
    );
  }
}