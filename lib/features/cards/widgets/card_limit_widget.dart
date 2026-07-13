import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/card_model.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

class CardLimitWidget extends StatelessWidget {
  final CardModel card;

  const CardLimitWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final usedPercent = card.creditLimit > 0
        ? (card.usedAmount / card.creditLimit).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          const Text(
            'Credit Limit',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₹${card.usedAmount.toStringAsFixed(0)} used',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
              Text(
                '₹${card.creditLimit.toStringAsFixed(0)} limit',
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: usedPercent,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                usedPercent > 0.8 ? Colors.red : AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '₹${card.availableLimit.toStringAsFixed(0)} available',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}