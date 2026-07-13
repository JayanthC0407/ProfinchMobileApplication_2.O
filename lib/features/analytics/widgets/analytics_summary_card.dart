import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:intl/intl.dart';

class AnalyticsSummaryCard extends StatelessWidget {
  final double totalAmount;
  final double totalIncome;
  final double totalExpense;
  final String period;

  const AnalyticsSummaryCard({
    super.key,
    required this.totalAmount,
    required this.totalIncome,
    required this.totalExpense,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat('#,##,##0.00', 'en_IN');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TOTAL SPENDING · $period'.toUpperCase(),
            style: AppTextStyles.whiteCaption(context),
          ),
          const SizedBox(height: 8),
          Text(
            '₹ ${currencyFormat.format(totalAmount)}',
            style: TextStyle(
              color: AppColors.light,
              fontSize: AppFontSize.xxl(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatTile(
                context,
                'Income',
                '₹ ${currencyFormat.format(totalIncome)}',
                Icons.arrow_downward_rounded,
              ),
              _buildStatTile(
                context,
                'Expenses',
                '₹ ${currencyFormat.format(totalExpense)}',
                Icons.arrow_upward_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      width: 145,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.light.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.light, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.whiteCaption(context)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppTextStyles.whiteBody(
                    context,
                    color: AppColors.light,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}