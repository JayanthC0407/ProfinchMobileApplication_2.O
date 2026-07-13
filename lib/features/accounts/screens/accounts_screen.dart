import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'package:provider/provider.dart';

import '../../auth/provider/auth_provider.dart';
import '../provider/account_provider.dart';
import '../widgets/account_card.dart';
import 'account_details_screen.dart';

class AccountsScreen extends StatelessWidget {
  const AccountsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final accountProvider = Provider.of<AccountProvider>(context);
    final user = authProvider.currentUser!;
    final accounts = accountProvider.getAccountsByUserId(user.id);
    final totalBalance = accountProvider.getTotalBalance(user.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Gradient header ───────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.blueButton],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.light),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Text(
                      'My Accounts',
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: RT.fs(context, 26),
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      '${accounts.length} account${accounts.length == 1 ? '' : 's'}',
                      style: AppTextStyles.whiteBody(context,
                          color: AppColors.light.withValues(alpha: 0.65)),
                    ),
                  ),
                  // Total balance summary card
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.light.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppColors.light.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Balance',
                                style: AppTextStyles.whiteCaption(context),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '₹ ${totalBalance.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: AppColors.light,
                                  fontSize: RT.fs(context, 22),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.light.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: AppColors.light,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Account list ──────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              itemCount: accounts.length,
              itemBuilder: (_, index) {
                final account = accounts[index];
                return AccountCard(
                  account: account,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AccountDetailsScreen(account: account),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}