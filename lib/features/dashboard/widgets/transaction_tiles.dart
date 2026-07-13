import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';

class TransactionTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String amount;
  final Color amountColor;
  final IconData icon;
  final Color iconBg;

  const TransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.amountColor,
    required this.icon,
    required this.iconBg,
  });

  // One-off muted grey used only for transaction subtitles
  static const _subtitleColor = Color.fromARGB(255, 90, 87, 87);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.light,
      ),
      child: Row(
        children: [

          CircleAvatar(
            radius: 24,
            backgroundColor: iconBg,
            child: Icon(
              icon,
              color: Colors.black87,   // Flutter semantic constant — intentional
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  style: AppTextStyles.title(context),
                ),

                const SizedBox(height: 5),

                Text(
                  subtitle,
                  style: AppTextStyles.bodySecondary(context,
                      color: _subtitleColor),
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: AppTextStyles.labelBold(context, color: amountColor),
          ),
        ],
      ),
    );
  }
}