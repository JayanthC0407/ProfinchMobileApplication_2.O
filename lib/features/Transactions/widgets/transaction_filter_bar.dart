import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/features/Transactions/provider/transaction_provider.dart';

class TransactionFilterBar extends StatelessWidget {
  final TransactionFilter selected;
  final ValueChanged<TransactionFilter> onChanged;

  const TransactionFilterBar({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(context, 'All', TransactionFilter.all),
        const SizedBox(width: 8),
        _chip(context, 'Credit', TransactionFilter.credit),
        const SizedBox(width: 8),
        _chip(context, 'Debit', TransactionFilter.debit),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, TransactionFilter filter) {
    final isSelected = selected == filter;
    Color chipColor;
    if (isSelected) {
      if (filter == TransactionFilter.credit) {
        chipColor = Colors.green.shade600;
      } else if (filter == TransactionFilter.debit) {
        chipColor = Colors.red.shade600;
      } else {
        chipColor = AppColors.primaryDark;
      }
    } else {
      chipColor = Colors.grey.shade200;
    }

    return GestureDetector(
      onTap: () => onChanged(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: chipColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.body(context),
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
