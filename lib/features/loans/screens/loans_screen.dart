import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/utils/currency_formatter.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'package:provider/provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/loan_provider.dart';

class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  String _formatAmount(double amount) {
    if (amount >= 100000) return "${(amount / 100000).toStringAsFixed(1)}L";
    if (amount >= 1000) return "${(amount / 1000).toStringAsFixed(1)}K";
    return amount.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final loanProvider = Provider.of<LoanProvider>(context);
    final user = authProvider.currentUser!;
    final loans = loanProvider.getLoansByUser(user.id);
    final activeLoans = loans.where((l) => l.status == 'ACTIVE').toList();
    final totalOutstanding =
        activeLoans.fold<double>(0, (sum, l) => sum + l.outstandingAmount);
    final nextEmi =
        activeLoans.isNotEmpty ? activeLoans.first.emiAmount : 0.0;

    final loanCurrency =
        activeLoans.isNotEmpty ? activeLoans.first.currencyCode : '';

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      body: Column(
        children: [
          // ── Fixed gradient header ──────────────────────────────────────
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
                  // top bar
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
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              color: AppColors.light),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // title
                   Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Text(
                      "Loans",
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
                      "Manage your borrowings",
                      style: TextStyle(
                        color: AppColors.light.withValues(alpha: 0.65),
                        fontSize: AppFontSize.body(context),
                      ),
                    ),
                  ),
                  // summary cards — sit inside the header, above the curve
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: Row(
                      children: [
                        _SummaryCard(
                          label: "Active Loans",
                          value: "${activeLoans.length}",
                          valueColor: AppColors.blueButton,
                        ),
                        const SizedBox(width: 10),
                        _SummaryCard(
                          label: "Outstanding",
                          value: "${CurrencyFormatter.symbolFor(loanCurrency)}${_formatAmount(totalOutstanding)}",
                          valueColor: Colors.black87,
                          valueFontSize: AppFontSize.body(context),
                        ),
                        const SizedBox(width: 10),
                        _SummaryCard(
                          label: "Next EMI",
                          value: activeLoans.isEmpty
                              ? "—"
                              : "${CurrencyFormatter.symbolFor(loanCurrency)}${nextEmi.toStringAsFixed(0)}",
                          valueColor: Colors.green.shade700,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable body ───────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 20, bottom: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Text(
                      "QUICK ACTIONS",
                      style: TextStyle(
                        fontSize: AppFontSize.small(context),
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        _MenuCard(
                          icon: Icons.account_balance_outlined,
                          iconBg: AppColors.light,
                          iconColor: AppColors.blueButton,
                          title: "My Loans",
                          subtitle: "View active & closed loans",
                          badge: activeLoans.isNotEmpty
                              ? "${activeLoans.length} Active"
                              : null,
                          badgeGreen: true,
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.myLoans),
                        ),
                        const SizedBox(height: 10),
                        _MenuCard(
                          icon: Icons.add_circle_outline,
                          iconBg: AppColors.light,
                          iconColor: const Color(0xFF4338CA),
                          title: "Apply for Loan",
                          subtitle: "Personal, home, vehicle & more",
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.applyLoan),
                        ),
                        const SizedBox(height: 10),
                        _MenuCard(
                          icon: Icons.calculate_outlined,
                          iconBg: AppColors.light,
                          iconColor: const Color(0xFF0D9488),
                          title: "EMI Calculator",
                          subtitle: "Estimate your monthly payments",
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.emiCalculator),
                        ),
                        const SizedBox(height: 20),
                        _PromoBanner(),
                      ],
                    ),
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

// ── Widgets ────────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final double valueFontSize;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.valueColor,
    this.valueFontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.light,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSize.xs(context),
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: TextStyle(
                fontSize: AppFontSize.medium(context),
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String? badge;
  final bool badgeGreen;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.badge,
    this.badgeGreen = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.light,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppFontSize.medium(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: AppFontSize.small(context),
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeGreen
                        ? Colors.green.shade50
                        : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    badge!,
                    style: TextStyle(
                      fontSize: AppFontSize.xs(context),
                      fontWeight: FontWeight.w600,
                      color: badgeGreen
                          ? Colors.green.shade700
                          : Colors.blue.shade700,
                    ),
                  ),
                ),
              Icon(Icons.chevron_right,
                  color: Colors.grey.shade400, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A5F), Color(0xFF2D5FA6)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.light.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.percent, color: AppColors.light, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Special offer: 8.5% p.a.",
                  style: TextStyle(
                    color: AppColors.light,
                    fontWeight: FontWeight.w600,
                    fontSize: AppFontSize.body(context),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Home loans till June 30",
                  style: TextStyle(
                    color: AppColors.light.withValues(alpha: 0.65),
                    fontSize: AppFontSize.small(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.light.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              "Apply →",
              style: TextStyle(
                color: AppColors.light,
                fontSize: AppFontSize.small(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
