import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/data/models/transaction_model.dart';

class TransactionTileWidget extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTileWidget({
    super.key,
    required this.transaction,
    this.onTap,
  });

  // ── Category icon ──────────────────────────────────────────────
  IconData get _icon {
    switch (transaction.category) {
      case TransactionCategory.salary:      return Icons.account_balance_outlined;
      case TransactionCategory.food:        return Icons.restaurant_outlined;
      case TransactionCategory.shopping:    return Icons.shopping_bag_outlined;
      case TransactionCategory.upi:         return Icons.phone_android_outlined;
      case TransactionCategory.billPayment: return Icons.receipt_outlined;
      case TransactionCategory.recharge:    return Icons.sim_card_outlined;
      case TransactionCategory.emi:         return Icons.home_outlined;
      case TransactionCategory.atm:         return Icons.atm_outlined;
      case TransactionCategory.transfer:    return Icons.swap_horiz_outlined;
      case TransactionCategory.refund:      return Icons.replay_outlined;
      case TransactionCategory.loan:        return Icons.payments_outlined;
      case TransactionCategory.termDeposit: return Icons.savings_outlined;
      case TransactionCategory.wallet:      return Icons.account_balance_wallet_outlined; 
      case TransactionCategory.insurance:   return Icons.health_and_safety_outlined;// ← NEW
    }
  }

  // ── Icon background color ──────────────────────────────────────
  Color get _iconBgColor {
    switch (transaction.category) {
      case TransactionCategory.salary:      return const Color(0xFFE8F5E9);
      case TransactionCategory.food:        return const Color(0xFFFFF3E0);
      case TransactionCategory.shopping:    return const Color(0xFFE3F2FD);
      case TransactionCategory.upi:         return const Color(0xFFF3E5F5);
      case TransactionCategory.billPayment: return const Color(0xFFFCE4EC);
      case TransactionCategory.recharge:    return const Color(0xFFE0F7FA);
      case TransactionCategory.emi:         return const Color(0xFFFFF8E1);
      case TransactionCategory.atm:         return const Color(0xFFEEEEEE);
      case TransactionCategory.transfer:    return const Color(0xFFE8EAF6);
      case TransactionCategory.refund:      return const Color(0xFFE8F5E9);
      case TransactionCategory.loan:        return const Color(0xFFFBE9E7);
      case TransactionCategory.termDeposit: return const Color(0xFFE0F2F1);
      case TransactionCategory.wallet:      return const Color(0xFFEDE7F6); 
       case TransactionCategory.insurance:   return const Color(0xFFE8F4FD);// ← NEW
    }
  }

  // ── Icon foreground color ──────────────────────────────────────
  Color get _iconColor {
    switch (transaction.category) {
      case TransactionCategory.salary:      return Colors.green.shade700;
      case TransactionCategory.food:        return Colors.orange.shade700;
      case TransactionCategory.shopping:    return Colors.blue.shade700;
      case TransactionCategory.upi:         return Colors.purple.shade700;
      case TransactionCategory.billPayment: return Colors.red.shade700;
      case TransactionCategory.recharge:    return Colors.cyan.shade700;
      case TransactionCategory.emi:         return Colors.amber.shade700;
      case TransactionCategory.atm:         return Colors.grey.shade700;
      case TransactionCategory.transfer:    return Colors.indigo.shade700;
      case TransactionCategory.refund:      return Colors.green.shade700;
      case TransactionCategory.loan:        return Colors.deepOrange.shade700;
      case TransactionCategory.termDeposit: return Colors.teal.shade700;
      case TransactionCategory.wallet:      return Colors.deepPurple.shade700;
      case TransactionCategory.insurance:   return Colors.lightBlue.shade700; // ← NEW
    }
  }

  // ── Category label ─────────────────────────────────────────────
  String get _categoryLabel {
    switch (transaction.category) {
      case TransactionCategory.salary:      return 'Salary';
      case TransactionCategory.food:        return 'Food';
      case TransactionCategory.shopping:    return 'Shopping';
      case TransactionCategory.upi:         return 'UPI';
      case TransactionCategory.billPayment: return 'Bill';
      case TransactionCategory.recharge:    return 'Recharge';
      case TransactionCategory.emi:         return 'EMI';
      case TransactionCategory.atm:         return 'ATM';
      case TransactionCategory.transfer:    return 'Transfer';
      case TransactionCategory.refund:      return 'Refund';
      case TransactionCategory.loan:        return 'Loan';
      case TransactionCategory.termDeposit: return 'Term Deposit';
      case TransactionCategory.wallet:      return 'Wallet';
      case TransactionCategory.insurance:   return 'Insurance';  // ← NEW
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;
    final amountColor = isCredit ? Colors.green.shade700 : Colors.red.shade700;
    final amountPrefix = isCredit ? '+ ₹' : '- ₹';
    final formattedAmount =
        NumberFormat('#,##,##0.00', 'en_IN').format(transaction.amount);
    final formattedDate =
        DateFormat('dd MMM, hh:mm a').format(transaction.date);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [

            // ── Icon ─────────────────────────────────────────────
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: _iconColor, size: 20),
            ),

            const SizedBox(width: 12),

            // ── Title + subtitle ──────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _iconBgColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _categoryLabel,
                          style: TextStyle(
                            fontSize: 10,
                            color: _iconColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Amount ────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$amountPrefix$formattedAmount',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isCredit ? 'Credit' : 'Debit',
                  style: TextStyle(
                    fontSize: 11,
                    color: amountColor.withValues(alpha: 0.7),
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