import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../provider/term_deposit_provider.dart';

class TermDepositStatementScreen extends StatelessWidget {
  const TermDepositStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final tdProvider = context.watch<TermDepositProvider>();
    final deposits = tdProvider.getDepositsByUserId(user.id);

    final totalInvested = deposits.fold(
        0.0, (sum, d) => sum + d.principalAmount);
    final totalMaturity = deposits.fold(
        0.0, (sum, d) => sum + d.maturityAmount);
    final totalInterest = totalMaturity - totalInvested;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Deposit Statements',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: deposits.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No statements available',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade500)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Summary card ─────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0A3D62), Color(0xFF1A5FA5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                            child: _summaryItem(
                                'Total Invested',
                                '₹${totalInvested.toStringAsFixed(0)}')),
                        Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24),
                        Expanded(
                            child: _summaryItem(
                                'Total Interest',
                                '₹${totalInterest.toStringAsFixed(0)}',
                                color: Colors.greenAccent)),
                        Container(
                            width: 1,
                            height: 40,
                            color: Colors.white24),
                        Expanded(
                            child: _summaryItem(
                                'Total Deposits',
                                '${deposits.length}')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text('All Deposits',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),

                  const SizedBox(height: 12),

                  ...deposits.map((deposit) {
                    final interestEarned =
                        deposit.maturityAmount - deposit.principalAmount;
                    final isActive = deposit.status == 'ACTIVE';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'FD ${deposit.id.substring(deposit.id.length > 6 ? deposit.id.length - 6 : 0)}',
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A1A2E)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? Colors.green.shade50
                                      : Colors.grey.shade100,
                                  borderRadius:
                                      BorderRadius.circular(20),
                                ),
                                child: Text(
                                  deposit.status,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isActive
                                        ? Colors.green.shade700
                                        : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                  child: _statItem(
                                      'Principal',
                                      '₹${deposit.principalAmount.toStringAsFixed(0)}')),
                              Expanded(
                                  child: _statItem(
                                      'Rate',
                                      '${deposit.interestRate}%')),
                              Expanded(
                                  child: _statItem(
                                      'Interest',
                                      '₹${interestEarned.toStringAsFixed(0)}',
                                      color:
                                          Colors.green.shade700)),
                              Expanded(
                                  child: _statItem(
                                      'Tenure',
                                      '${deposit.tenureMonths}M')),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Start: ${deposit.startDate.toString().split(' ').first}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400),
                              ),
                              Text(
                                'Maturity: ${deposit.maturityDate.toString().split(' ').first}',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _summaryItem(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color ?? Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 3),
        Text(label,
            style:
                const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }

  Widget _statItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 10, color: Colors.grey.shade400)),
        Text(value,
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color ?? const Color(0xFF1A1A2E))),
      ],
    );
  }
}