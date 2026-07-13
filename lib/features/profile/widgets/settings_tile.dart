import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

class SettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBgColor;
  final VoidCallback onTap;
  final Widget? badge;
  final bool showArrow;
  final bool isDestructive;

  const SettingsTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
    this.iconColor,
    this.iconBgColor,
    this.badge,
    this.showArrow = true,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedIconColor = isDestructive
        ? const Color(0xFFE53935)
        : (iconColor ?? const Color(0xFF4A90D9));
    final resolvedIconBg = isDestructive
        ? const Color(0xFFE53935).withOpacity(0.12)
        : (iconBgColor ?? const Color(0xFF4A90D9).withOpacity(0.12));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDestructive
                ? const Color(0xFFE53935).withOpacity(0.2)
                : Colors.white,
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

            // ── Title + subtitle ───────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isDestructive
                          ? const Color(0xFFE53935)
                          : Colors.black,
                      fontSize: AppFontSize.body(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: AppFontSize.xs(context),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // ── Badge or arrow ─────────────────────────────────────
            if (badge != null)
              badge!
            else if (showArrow)
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: Colors.black,
              ),
          ],
        ),
      ),
    );
  }
}