import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/features/rewards/provider/reward_provider.dart';

class VoucherCard extends StatelessWidget {
  final VoucherModel voucher;
  final int availablePoints;
  final VoidCallback onRedeem;

  const VoucherCard({
    super.key,
    required this.voucher,
    required this.availablePoints,
    required this.onRedeem,
  });

  @override
  Widget build(BuildContext context) {
    final canRedeem = availablePoints >= voucher.pointsRequired;
    final expiryStr =
        DateFormat('dd MMM yyyy').format(voucher.expiryDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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

          // ── Brand color strip ──────────────────────────────
          Container(
            width: 70,
            height: 90,
            decoration: BoxDecoration(
              color: voucher.color.withValues(alpha: 0.12),
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(16)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(voucher.icon, color: voucher.color, size: 26),
                const SizedBox(height: 4),
                Text(
                  voucher.brand,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: voucher.color,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Dashed divider ─────────────────────────────────
          CustomPaint(
            size: const Size(1, 90),
            painter: _DashedLinePainter(),
          ),

          // ── Content ────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          voucher.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1A1A2E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: voucher.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          voucher.value,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: voucher.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    voucher.description,
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Valid till $expiryStr',
                        style: TextStyle(
                            fontSize: 10, color: Colors.grey.shade400),
                      ),
                      GestureDetector(
                        onTap: canRedeem ? onRedeem : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: canRedeem
                                ? const Color(0xFF7C3AED)
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            canRedeem
                                ? '${voucher.pointsRequired} pts'
                                : 'Need ${voucher.pointsRequired} pts',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: canRedeem
                                  ? Colors.white
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 1;
    double y = 0;
    while (y < size.height) {
      canvas.drawLine(Offset(0, y), Offset(0, y + 4), paint);
      y += 8;
    }
  }

  @override
  bool shouldRepaint(_) => false;
}