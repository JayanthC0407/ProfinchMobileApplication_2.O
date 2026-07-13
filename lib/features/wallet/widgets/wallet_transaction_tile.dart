import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/features/wallet/provider/wallet_provider.dart';

class WalletTransactionTile extends StatelessWidget {
  final WalletTransaction transaction;

  const WalletTransactionTile({super.key, required this.transaction});

  IconData get _icon {
    switch (transaction.type) {
      case WalletTransactionType.topup:    return Icons.add_circle_outline;
      case WalletTransactionType.transfer: return Icons.swap_horiz_rounded;
      case WalletTransactionType.payment:  return Icons.shopping_bag_outlined;
    }
  }

  Color get _iconBg {
    switch (transaction.type) {
      case WalletTransactionType.topup:    return const Color(0xFFE8F5E9);
      case WalletTransactionType.transfer: return const Color(0xFFE3F2FD);
      case WalletTransactionType.payment:  return const Color(0xFFFCE4EC);
    }
  }

  Color get _iconColor {
    switch (transaction.type) {
      case WalletTransactionType.topup:    return Colors.green.shade600;
      case WalletTransactionType.transfer: return Colors.blue.shade600;
      case WalletTransactionType.payment:  return Colors.red.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    final dateStr = DateFormat('dd MMM, hh:mm a').format(transaction.date);
    final isCredit = transaction.isCredit;

    return Container(
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
              color: _iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _iconColor, size: 20),
          ),

          const SizedBox(width: 12),

          // ── Title + date ──────────────────────────────────────
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
                Text(
                  dateStr,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          // ── Amount ────────────────────────────────────────────
          Text(
            '${isCredit ? '+ ' : '- '}₹${formatter.format(transaction.amount)}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isCredit
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}