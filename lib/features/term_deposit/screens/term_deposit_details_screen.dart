import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

import '../../../data/models/term_deposit_model.dart';
import '../../../data/models/account_model.dart';

class TermDepositDetailsScreen extends StatelessWidget {
  final TermDepositModel deposit;
  final AccountModel account;

  const TermDepositDetailsScreen({
    super.key,
    required this.deposit,
    required this.account,
  });

  @override
  Widget build(BuildContext context) {
    final interestEarned =
        deposit.maturityAmount - deposit.principalAmount;
    final daysLeft =
        deposit.maturityDate.difference(DateTime.now()).inDays;
    final totalDays = deposit.maturityDate
        .difference(deposit.startDate)
        .inDays;
    final progressPercent = totalDays > 0
        ? ((totalDays - daysLeft) / totalDays).clamp(0.0, 1.0)
        : 1.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Deposit Details',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Hero card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A3D62), Color(0xFF1A5FA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Maturity Amount',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: deposit.status == 'ACTIVE'
                              ? Colors.green.shade400
                              : Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(deposit.status,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${deposit.maturityAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Progress bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        deposit.startDate.toString().split(' ').first,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11),
                      ),
                      Text(
                        deposit.maturityDate
                            .toString()
                            .split(' ')
                            .first,
                        style: const TextStyle(
                            color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      minHeight: 6,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.greenAccent),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    daysLeft > 0
                        ? '$daysLeft days remaining'
                        : 'Matured',
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── Deposit info ───────────────────────────────────
            _sectionCard('Deposit Information', [
              _detailRow('Deposit ID', deposit.id),
              _detailRow('Principal Amount',
                  '₹${deposit.principalAmount.toStringAsFixed(2)}'),
              _detailRow('Interest Rate', '${deposit.interestRate}%'),
              _detailRow('Tenure', '${deposit.tenureMonths} Months'),
            ]),

            const SizedBox(height: 14),

            // ── Timeline ───────────────────────────────────────
            _sectionCard('Timeline', [
              _detailRow('Opening Date',
                  deposit.startDate.toString().split(' ').first),
              _detailRow('Maturity Date',
                  deposit.maturityDate.toString().split(' ').first),
            ]),

            const SizedBox(height: 14),

            // ── Funding account ────────────────────────────────
            _sectionCard('Funding Account', [
              _detailRow('Account Type', account.accountType),
              _detailRow('Account Number', account.accountNumber),
              _detailRow('IFSC Code', account.ifscCode),
            ]),

            const SizedBox(height: 14),

            // ── Interest earned highlight ──────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.trending_up_rounded,
                        color: Colors.green.shade700, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Interest Earned',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade600)),
                      Text(
                        '₹${interestEarned.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard(String title, List<Widget> rows) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          ...rows,
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade500)),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? const Color(0xFF1A1A2E))),
          ),
        ],
      ),
    );
  }
}