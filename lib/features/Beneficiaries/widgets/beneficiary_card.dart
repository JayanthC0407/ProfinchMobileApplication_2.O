import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

class BeneficiaryCard extends StatelessWidget {
  final String name;
  final String accountNumber;
  final String type;
  final VoidCallback onTap;

  const BeneficiaryCard({
    super.key,
    required this.name,
    required this.accountNumber,
    required this.type,
    required this.onTap,
  });

  Color get _typeColor {
    switch (type) {
      case 'PBI': return const Color(0xFF2563B0);
      case 'LOCAL': return const Color(0xFF2563B0);
      case 'INTERNATIONAL': return const Color(0xFF2563B0);
      default: return const Color(0xFF4338CA);
    }
  }

  Color get _typeBg {
    switch (type) {
      case 'PBI': return const Color(0xFFDBEAFE);
      case 'LOCAL': return const Color(0xFFCCFBF1);
      case 'INTERNATIONAL': return const Color(0xFFFEF3C7);
      default: return const Color(0xFFE0E7FF);
    }
  }

  IconData get _typeIcon {
    switch (type) {
      case 'PBI': return Icons.account_balance_outlined;
      case 'LOCAL': return Icons.location_city_outlined;
      case 'INTERNATIONAL': return Icons.public_outlined;
      default: return Icons.person_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _typeBg,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Center(
                    child: Text(
                      name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: AppFontSize.large(context),
                        fontWeight: FontWeight.bold,
                        color: _typeColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: AppFontSize.medium(context),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "••••  ••••  ••••  ${accountNumber.substring(accountNumber.length - 4)}",
                        style: TextStyle(
                          fontSize: AppFontSize.small(context),
                          color: const Color(0xFF6B7280),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _typeBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_typeIcon, size: 12, color: _typeColor),
                      const SizedBox(width: 4),
                      Text(
                        type,
                        style: TextStyle(
                          fontSize: AppFontSize.small(context),
                          fontWeight: FontWeight.w600,
                          color: _typeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}