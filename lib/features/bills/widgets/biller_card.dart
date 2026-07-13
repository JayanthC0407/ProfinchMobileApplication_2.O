import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/features/bills/provider/bills_provider.dart';

class BillerCard extends StatelessWidget {
  final BillerModel biller;
  final VoidCallback onPayNow;
  final VoidCallback onTap;

  const BillerCard({
    super.key,
    required this.biller,
    required this.onPayNow,
    required this.onTap,
  });

  Color get _statusColor {
    switch (biller.status) {
      case BillerStatus.paid:    return Colors.green.shade600;
      case BillerStatus.unpaid:  return Colors.orange.shade600;
      case BillerStatus.overdue: return Colors.red.shade600;
    }
  }

  String get _statusLabel {
    switch (biller.status) {
      case BillerStatus.paid:    return 'Paid';
      case BillerStatus.unpaid:  return 'Due';
      case BillerStatus.overdue: return 'Overdue';
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');
    final dueDateStr = DateFormat('dd MMM').format(biller.dueDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [

            // ── Icon ─────────────────────────────────────────
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: biller.category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(biller.category.icon,
                  color: biller.category.color, size: 22),
            ),

            const SizedBox(width: 12),

            // ── Details ─────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    biller.nickname,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${biller.providerName} • ${biller.consumerNumber}',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _statusColor,
                          ),
                        ),
                      ),
                      if (biller.status != BillerStatus.paid) ...[
                        const SizedBox(width: 6),
                        Text(
                          'Due $dueDateStr',
                          style: TextStyle(
                              fontSize: 10, color: Colors.grey.shade400),
                        ),
                      ],
                      if (biller.autopayEnabled) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.autorenew_rounded,
                            size: 12, color: Colors.blue.shade400),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // ── Amount + Pay button ──────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  biller.status == BillerStatus.paid
                      ? 'Paid'
                      : '₹${formatter.format(biller.dueAmount)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: biller.status == BillerStatus.paid
                        ? Colors.green.shade600
                        : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 6),
                if (biller.status != BillerStatus.paid)
                  GestureDetector(
                    onTap: onPayNow,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: biller.category.color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Pay Now',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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