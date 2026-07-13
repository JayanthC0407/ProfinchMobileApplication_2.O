import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/term_deposit_provider.dart';

class TermDepositScreen extends StatelessWidget {
  const TermDepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final tdProvider = context.watch<TermDepositProvider>();
    final activeDeposits = tdProvider.getActiveDeposits(user.id);
    final totalInvestment = tdProvider.getTotalInvestment(user.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Term Deposits',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Summary card ───────────────────────────────────
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
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Investment',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${totalInvestment.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _summaryChip(
                          Icons.check_circle_outline,
                          '${activeDeposits.length} Active',
                          Colors.greenAccent),
                      const SizedBox(width: 12),
                      _summaryChip(
                          Icons.history,
                          '${tdProvider.getRedeemedDeposits(user.id).length} Redeemed',
                          Colors.white60),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Manage Deposits',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),

            const SizedBox(height: 14),

            // ── Action tiles ───────────────────────────────────
            _buildActionTile(
              context,
              icon: Icons.account_balance_outlined,
              title: 'My Deposits',
              subtitle: 'View all your active & past deposits',
              color: const Color(0xFF0A3D62),
              route: AppRoutes.myDeposits,
            ),
            _buildActionTile(
              context,
              icon: Icons.add_circle_outline_rounded,
              title: 'Open New Deposit',
              subtitle: 'Start a new fixed deposit from your account',
              color: const Color(0xFF0F6E56),
              route: AppRoutes.openDeposit,
            ),
            _buildActionTile(
              context,
              icon: Icons.currency_exchange_rounded,
              title: 'Redeem Deposit',
              subtitle: 'Withdraw matured or premature deposits',
              color: const Color(0xFFD4600A),
              route: AppRoutes.redeemDeposit,
            ),
            _buildActionTile(
              context,
              icon: Icons.receipt_long_outlined,
              title: 'Statements',
              subtitle: 'View deposit history & interest details',
              color: const Color(0xFF7C3AED),
              route: AppRoutes.depositStatements,
            ),

            const SizedBox(height: 24),

            // ── Interest rate card ─────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Interest Rates',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _rateRow('3 Months', '5.50%'),
                  _rateRow('6 Months', '6.00%'),
                  _rateRow('12 Months', '7.00%'),
                  _rateRow('24 Months', '7.50%'),
                  _rateRow('36+ Months', '8.00%', isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _summaryChip(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _rateRow(String tenure, String rate, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : Border(
                bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(tenure,
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0A3D62).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              rate,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0A3D62),
              ),
            ),
          ),
        ],
      ),
    );
  }
}