import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

class UpiPaymentStatusWidget extends StatelessWidget {
  final bool isSuccess;
  final double amount;
  final String receiverName;
  final String transactionId;
  final VoidCallback onDone;
  final VoidCallback onRetry;

  const UpiPaymentStatusWidget({
    super.key,
    required this.isSuccess,
    required this.amount,
    required this.receiverName,
    required this.transactionId,
    required this.onDone,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');

    return Container(
      padding: EdgeInsets.fromLTRB(28, 28, 28, MediaQuery.of(context).viewInsets.bottom + 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // ── Status icon ───────────────────────────────────────
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: isSuccess
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSuccess
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              color: isSuccess
                  ? Colors.green.shade600
                  : Colors.red.shade600,
              size: 44,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            isSuccess ? 'Payment Successful!' : 'Payment Failed',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: isSuccess
                  ? Colors.green.shade700
                  : Colors.red.shade700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            '₹${formatter.format(amount)}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            isSuccess
                ? 'Paid to $receiverName'
                : 'Could not send to $receiverName',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          if (isSuccess && transactionId.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_outlined,
                      size: 16, color: Colors.grey.shade500),
                  const SizedBox(width: 8),
                  Text(
                    'Txn ID: $transactionId',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 28),

          // ── Action buttons ────────────────────────────────────
          if (isSuccess)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDone,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onRetry,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Retry'),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}