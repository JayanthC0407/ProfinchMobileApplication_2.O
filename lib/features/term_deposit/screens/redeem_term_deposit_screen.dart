import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:provider/provider.dart';

import '../../accounts/provider/account_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/term_deposit_provider.dart';
import '../../Transactions/provider/transaction_provider.dart';

class RedeemTermDepositScreen extends StatelessWidget {
  const RedeemTermDepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final tdProvider = context.watch<TermDepositProvider>();
    final accountProvider = context.read<AccountProvider>();
    final deposits = tdProvider.getActiveDeposits(user.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Redeem Deposit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: deposits.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.currency_exchange,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No active deposits to redeem',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: deposits.length,
              itemBuilder: (context, index) {
                final deposit = deposits[index];
                final interestEarned =
                    deposit.maturityAmount - deposit.principalAmount;
                final daysLeft = deposit.maturityDate
                    .difference(DateTime.now())
                    .inDays;
                final isPremature = daysLeft > 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
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
                  child: Column(
                    children: [
                      // ── Header ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isPremature
                                ? [
                                    Colors.orange.shade700,
                                    Colors.orange.shade400,
                                  ]
                                : [
                                    const Color(0xFF0F6E56),
                                    Colors.green.shade500,
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '₹${deposit.principalAmount.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Principal Amount',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  isPremature
                                      ? '$daysLeft days left'
                                      : 'Matured',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${deposit.tenureMonths} months',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Details ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _detailRow(
                              'Interest Rate',
                              '${deposit.interestRate}%',
                            ),
                            const SizedBox(height: 8),
                            _detailRow(
                              'Interest Earned',
                              '₹${interestEarned.toStringAsFixed(2)}',
                              valueColor: const Color(0xFF0F6E56),
                            ),
                            const SizedBox(height: 8),
                            _detailRow(
                              'Maturity Amount',
                              '₹${deposit.maturityAmount.toStringAsFixed(2)}',
                              valueColor: Colors.green.shade700,
                            ),
                            const SizedBox(height: 8),
                            _detailRow(
                              'Maturity Date',
                              deposit.maturityDate.toString().split(' ').first,
                            ),
                            if (isPremature) ...[
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.orange.shade200,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.warning_amber_rounded,
                                      color: Colors.orange.shade600,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Premature redemption may attract penalty charges.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.orange.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: ElevatedButton(
                                onPressed: () => _confirmRedeem(
                                  context,
                                  deposit,
                                  accountProvider,
                                  tdProvider,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text(
                                  'Redeem Now',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _confirmRedeem(
    BuildContext context,
    deposit,
    AccountProvider accountProvider,
    TermDepositProvider tdProvider,
  ) {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirm Redemption',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            _detailRow(
              'Principal',
              '₹${deposit.principalAmount.toStringAsFixed(2)}',
            ),
            const SizedBox(height: 8),
            _detailRow('Interest', '${deposit.interestRate}%'),
            const SizedBox(height: 8),
            _detailRow('Tenure', '${deposit.tenureMonths} Months'),
            const Divider(height: 24),
            _detailRow(
              'You will receive',
              '₹${deposit.maturityAmount.toStringAsFixed(2)}',
              valueColor: Colors.green.shade700,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      accountProvider.creditAccount(
                        deposit.sourceAccountId,
                        deposit.maturityAmount,
                      );

                      tdProvider.redeemDeposit(deposit.id);

                      TransactionProvider.instance.recordTermDepositRedemption(
                        accountId: deposit.sourceAccountId,
                        amount: deposit.maturityAmount,
                        depositId: deposit.id,
                        balanceAfter: accountProvider
                            .getAccountById(deposit.sourceAccountId)
                            .availableBalance,
                      );

                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Confirm',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}