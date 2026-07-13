import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

class ProfileInfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final Widget? trailing;

  const ProfileInfoTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.iconColor,
    this.iconBgColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = iconColor ?? const Color(0xFF4A90D9);
    final resolvedIconBg = iconBgColor ?? const Color(0xFF4A90D9).withOpacity(0.12);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.light,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ── Icon ──────────────────────────────────────────────
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: resolvedIconBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: resolvedIconColor.withOpacity(0.25),
                width: 1,
              ),
            ),
            child: Icon(icon, color: resolvedIconColor, size: 20),
          ),

          const SizedBox(width: 14),

          // ── Label + value ──────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: AppFontSize.xs(context),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: AppFontSize.body(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}