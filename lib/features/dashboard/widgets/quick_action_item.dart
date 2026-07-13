import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';

class QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const QuickActionItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [

          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.iconBackground,
            child: Icon(
              icon,
              color: AppColors.accent,
            ),
          ),

          const SizedBox(height: 10),

          Text(title, style: AppTextStyles.small(context)),
        ],
      ),
    );
  }
}