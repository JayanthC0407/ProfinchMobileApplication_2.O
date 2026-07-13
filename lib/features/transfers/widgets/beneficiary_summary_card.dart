import 'package:flutter/material.dart';

class BeneficiarySummaryCard extends StatelessWidget {
  final String name;
  final String type;
  final String accountNumber;

  const BeneficiarySummaryCard({
    super.key,
    required this.name,
    required this.type,
    required this.accountNumber,
  });

  Color get _typeColor {
    switch (type) {
      case 'PBI': return const Color(0xFF2563B0);
      case 'LOCAL': return const Color(0xFF0D9488);
      case 'INTERNATIONAL': return const Color(0xFFB45309);
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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _typeBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 20,
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
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "••••  ••••  ••••  ${accountNumber.substring(accountNumber.length - 4)}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _typeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              type,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _typeColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}