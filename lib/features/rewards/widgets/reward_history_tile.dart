import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/data/models/reward_model.dart';

class RewardHistoryTile extends StatelessWidget {
  final RewardModel reward;

  const RewardHistoryTile({super.key, required this.reward});

  IconData get _icon {
    switch (reward.category) {
      case RewardCategory.cashback:   return Icons.currency_rupee_rounded;
      case RewardCategory.voucher:    return Icons.card_giftcard_outlined;
      case RewardCategory.offer:      return Icons.local_offer_outlined;
      case RewardCategory.milestone:  return Icons.emoji_events_outlined;
    }
  }

  Color get _color {
    switch (reward.category) {
      case RewardCategory.cashback:   return Colors.green.shade600;
      case RewardCategory.voucher:    return const Color(0xFF7C3AED);
      case RewardCategory.offer:      return Colors.orange.shade600;
      case RewardCategory.milestone:  return Colors.amber.shade700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, color: _color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reward.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  DateFormat('dd MMM yyyy').format(reward.earnedDate),
                  style: TextStyle(
                      fontSize: 11, color: Colors.grey.shade400),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                reward.isRedeemed
                    ? '- ${reward.points} pts'
                    : '+ ${reward.points} pts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: reward.isRedeemed
                      ? Colors.red.shade600
                      : Colors.green.shade600,
                ),
              ),
              Text(
                reward.isRedeemed ? 'Redeemed' : 'Earned',
                style: TextStyle(
                    fontSize: 10, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }
}