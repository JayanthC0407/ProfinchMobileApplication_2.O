import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

class TransactionSummaryCard extends StatelessWidget {
  final double totalCredit;
  final double totalDebit;

  const TransactionSummaryCard({
    super.key,
    required this.totalCredit,
    required this.totalDebit,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [

          // ── Total Credit ──────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_downward_rounded,
                      color: Colors.green.shade600, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Income',
                      style: TextStyle(
                        fontSize: AppFontSize.small(context),
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '₹${formatter.format(totalCredit)}',
                      style: TextStyle(
                        fontSize: AppFontSize.body(context),
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Divider ───────────────────────────────────────────
          Container(
            width: 1,
            height: 36,
            color: Colors.grey.shade200,
          ),

          const SizedBox(width: 16),

          // ── Total Debit ───────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.arrow_upward_rounded,
                      color: Colors.red.shade600, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Expenses',
                      style: TextStyle(
                        fontSize: AppFontSize.small(context),
                        color: Colors.grey.shade500,
                      ),
                    ),
                    Text(
                      '₹${formatter.format(totalDebit)}',
                      style: TextStyle(
                        fontSize: AppFontSize.body(context),
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}