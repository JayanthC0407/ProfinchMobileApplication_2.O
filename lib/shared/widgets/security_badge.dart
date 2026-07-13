import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

class SecurityBadge extends StatelessWidget {
  const SecurityBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            size: 14,
            color: AppColors.light,
          ),
          const SizedBox(width: 5),
          Text(
            '256-bit SSL encrypted  ·  Bank-grade security',
            style: TextStyle(
              fontSize: AppFontSize.xs(context),
              color: AppColors.light.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}