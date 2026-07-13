import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import '../../../data/models/loan_model.dart';

class LoanCard extends StatelessWidget {
  final LoanModel loan;
  final VoidCallback onTap;

  const LoanCard({super.key, required this.loan, required this.onTap});

  Color get _statusColor {
    switch (loan.status) {
      case 'ACTIVE':
        return Colors.green;
      case 'CLOSED':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData get _loanIcon {
    switch (loan.loanType) {
      case 'Home Loan':
        return Icons.home_outlined;
      case 'Vehicle Loan':
        return Icons.directions_car_outlined;
      case 'Education Loan':
        return Icons.school_outlined;
      case 'Business Loan':
        return Icons.business_center_outlined;
      default:
        return Icons.person_outline;
    }
  }

  Color get _iconBg {
    switch (loan.loanType) {
      case 'Home Loan':
        return const Color(0xFFDCFCE7);
      case 'Vehicle Loan':
        return const Color(0xFFDEEBFF);
      case 'Education Loan':
        return const Color(0xFFFFF7CD);
      case 'Business Loan':
        return const Color(0xFFFCE7F3);
      default:
        return const Color(0xFFE0E7FF);
    }
  }

  Color get _iconColor {
    switch (loan.loanType) {
      case 'Home Loan':
        return const Color(0xFF16A34A);
      case 'Vehicle Loan':
        return const Color(0xFF2563B0);
      case 'Education Loan':
        return const Color(0xFFB45309);
      case 'Business Loan':
        return const Color(0xFFBE185D);
      default:
        return const Color(0xFF4338CA);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = loan.principalAmount > 0
        ? (loan.principalAmount - loan.outstandingAmount) / loan.principalAmount
        : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_loanIcon, color: _iconColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loan.loanType,
                        style:  TextStyle(
                          fontSize: AppFontSize.medium(context),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        loan.displayId.isNotEmpty
                            ? "ID: ${loan.displayId}"
                            : "ID: ${loan.id.substring(loan.id.length > 8 ? loan.id.length - 8 : 0)}",
                        style: TextStyle(
                          fontSize: AppFontSize.small(context),
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    loan.status,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: AppFontSize.small(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _InfoChip(
                    label: "Outstanding",
                    value:
                        "₹${loan.outstandingAmount.toStringAsFixed(0)}",
                    valueColor: Colors.red.shade600,
                  ),
                ),
                Expanded(
                  child: _InfoChip(
                    label: "EMI / Month",
                    value:
                        "${loan.emiIsEstimated ? '~' : ''}₹${loan.emiAmount.toStringAsFixed(0)}",
                    valueColor: Colors.blue.shade700,
                  ),
                ),
                Expanded(
                  child: _InfoChip(
                    label: "Rate",
                    value: "${loan.interestRate}%",
                    valueColor: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey.shade100,
                      color: Colors.green.shade400,
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  "${(progress * 100).toStringAsFixed(0)}% paid",
                  style: TextStyle(
                    fontSize: AppFontSize.small(context),
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;

  const _InfoChip({
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: AppFontSize.xs(context), color: Colors.grey.shade400),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSize.body(context),
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}