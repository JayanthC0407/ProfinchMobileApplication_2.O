import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';

class BeneficiaryTransferTile extends StatelessWidget {
  final String name;
  final String type;
  final String accountNumber;
  final VoidCallback onTap;

  /// When cooling is active this is > 0. The tile renders a lock badge
  /// and the caller blocks navigation. Pass 0 for unrestricted beneficiaries.
  final int coolingSecondsRemaining;

  const BeneficiaryTransferTile({
    super.key,
    required this.name,
    required this.type,
    required this.accountNumber,
    required this.onTap,
    this.coolingSecondsRemaining = 0,
  });

  bool get _isCooling => coolingSecondsRemaining > 0;

  Color get _typeColor {
    switch (type) {
      case 'PBI':           return AppColors.blueButton;
      case 'LOCAL':         return AppColors.success;
      case 'INTERNATIONAL': return AppColors.warningDark;
      default:              return const Color(0xFF4338CA);
    }
  }

  Color get _typeBg {
    switch (type) {
      case 'PBI':           return const Color(0xFFDBEAFE);
      case 'LOCAL':         return const Color(0xFFCCFBF1);
      case 'INTERNATIONAL': return const Color(0xFFFEF3C7);
      default:              return const Color(0xFFE0E7FF);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        // Dimmed background while cooling
        color: _isCooling ? AppColors.surfaceLight : AppColors.light,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _isCooling
              ? AppColors.warning.withValues(alpha: 0.4)
              : AppColors.grey200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _isCooling
                        ? AppColors.warning.withValues(alpha: 0.12)
                        : _typeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isCooling
                        ? Icon(Icons.lock_clock_outlined,
                            size: 20,
                            color: AppColors.warning)
                        : Text(
                            name[0].toUpperCase(),
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: _typeColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 12),

                // Name + account / cooling label
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.bodyBold(context,
                            color: _isCooling
                                ? AppColors.textSecondary
                                : AppColors.textDark),
                      ),
                      const SizedBox(height: 2),
                      _isCooling
                          ? Text(
                              'Available in $coolingSecondsRemaining sec',
                              style: AppTextStyles.small(context,
                                  color: AppColors.warning),
                            )
                          : Text(
                              '••••  ${accountNumber.substring(accountNumber.length - 4)}',
                              style: AppTextStyles.small(context)
                                  .copyWith(letterSpacing: 1),
                            ),
                    ],
                  ),
                ),

                // Type badge or lock badge
                if (_isCooling)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Cooling',
                      style: AppTextStyles.smallBold(context,
                          color: AppColors.warningDark),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _typeBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      type,
                      style: AppTextStyles.smallBold(context,
                          color: _typeColor),
                    ),
                  ),

                const SizedBox(width: 8),
                Icon(
                  _isCooling
                      ? Icons.lock_outline_rounded
                      : Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _isCooling
                      ? AppColors.warning
                      : AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}