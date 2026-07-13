import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../../accounts/provider/account_provider.dart';
import '../provider/term_deposit_provider.dart';
import 'term_deposit_details_screen.dart';

class MyTermDepositsScreen extends StatefulWidget {
  const MyTermDepositsScreen({super.key});

  @override
  State<MyTermDepositsScreen> createState() => _MyTermDepositsScreenState();
}

class _MyTermDepositsScreenState extends State<MyTermDepositsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final tdProvider = context.watch<TermDepositProvider>();
    final accountProvider = context.read<AccountProvider>();

    final activeDeposits = tdProvider.getActiveDeposits(user.id);
    final redeemedDeposits = tdProvider.getRedeemedDeposits(user.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('My Deposits',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Redeemed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDepositList(context, activeDeposits, accountProvider, true),
          _buildDepositList(context, redeemedDeposits, accountProvider, false),
        ],
      ),
    );
  }

  Widget _buildDepositList(BuildContext context, List deposits,
      AccountProvider accountProvider, bool isActive) {
    if (deposits.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              isActive ? 'No active deposits' : 'No redeemed deposits',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: deposits.length,
      itemBuilder: (context, index) {
        final deposit = deposits[index];
        final account =
            accountProvider.getAccountById(deposit.sourceAccountId);
        final interestEarned =
            deposit.maturityAmount - deposit.principalAmount;
        final daysLeft = deposit.maturityDate
            .difference(DateTime.now())
            .inDays;

        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TermDepositDetailsScreen(
                  deposit: deposit, account: account),
            ),
          ),
          child: Container(
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

                // ── Top colored bar ───────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              const Color(0xFF0A3D62),
                              const Color(0xFF1A5FA5)
                            ]
                          : [Colors.grey.shade600, Colors.grey.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${deposit.principalAmount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          deposit.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Details ───────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _detailRow('Maturity Amount',
                          '₹${deposit.maturityAmount.toStringAsFixed(2)}',
                          valueColor: Colors.green.shade700),
                      const SizedBox(height: 8),
                      _detailRow('Interest Rate',
                          '${deposit.interestRate}%'),
                      const SizedBox(height: 8),
                      _detailRow(
                          'Tenure', '${deposit.tenureMonths} Months'),
                      const SizedBox(height: 8),
                      _detailRow('Interest Earned',
                          '₹${interestEarned.toStringAsFixed(2)}',
                          valueColor: const Color(0xFF0F6E56)),
                      if (isActive && daysLeft > 0) ...[
                        const SizedBox(height: 8),
                        _detailRow('Days to Maturity', '$daysLeft days',
                            valueColor: daysLeft < 30
                                ? Colors.orange
                                : Colors.grey.shade700),
                      ],
                      const SizedBox(height: 8),
                      _detailRow('Maturity Date',
                          deposit.maturityDate.toString().split(' ').first),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style:
                TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        Text(value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF1A1A2E),
            )),
      ],
    );
  }
}