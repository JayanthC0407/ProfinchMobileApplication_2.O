import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import 'package:profinch_mobile_application/features/analytics/screens/analytics_screen.dart';
import 'package:profinch_mobile_application/features/upi/provider/upi_provider.dart';
import 'package:profinch_mobile_application/features/upi/screens/receive_money_screen.dart';
import 'package:profinch_mobile_application/features/upi/screens/scan_qr_screen.dart';
import 'package:profinch_mobile_application/features/upi/screens/upi_home_screen.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:provider/provider.dart';

import '../provider/dashboard_provider.dart';
import '../widgets/app_menu_drawer.dart';
import '../widgets/balance_card.dart';
import '../widgets/bottom_navbar.dart';
import '../widgets/feature_item.dart';
import '../widgets/quick_action_item.dart';
import '../../auth/provider/auth_provider.dart';

import 'package:profinch_mobile_application/features/Transactions/provider/transaction_provider.dart';
import 'package:profinch_mobile_application/features/Transactions/widgets/transaction_tile_widget.dart';
import 'package:profinch_mobile_application/features/Transactions/screens/transaction_history_screen.dart';
import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

import 'package:profinch_mobile_application/core/l10n/app_localizations.dart';
// ─────────────────────────────────────────────────────────────────

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── NEW ── one-liner lookup, use t.xxx anywhere in this build
    final t = AppLocalizations.of(context);
    // ─────────────────────────────────────────────────────────────

    final provider = Provider.of<DashboardProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final accountProvider = Provider.of<AccountProvider>(context);
    final userAccounts = accountProvider.getAccountsByUserId(user.id);
    final selectedAccount = userAccounts.firstWhere(
      (account) =>
          account.id == (provider.selectedAccountId ?? user.primaryAccountId),
      orElse: () => userAccounts.first,
    );

    return Scaffold(
      // Hamburger menu, mirroring the presales environment's side menu.
      drawer: const AppMenuDrawer(),
      bottomNavigationBar: const BottomNavBar(),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/loginPhoneBg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER ──────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        // hamburger menu
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(Icons.menu, color: Colors.white, size: 28),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hello, ${user.username} 👋",
                              style: TextStyle(
                                fontSize: AppFontSize.large(context),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              // ── CHANGED ── was: "Welcome Back"
                              t.dashboard_welcomeBack,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: AppFontSize.body(context),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Consumer<NotificationProvider>(
                      builder: (context, notifProvider, _) {
                        final unread = notifProvider.unreadCount(user.id);
                        return GestureDetector(
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.notifications,
                          ),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              const Icon(
                                Icons.notifications_none,
                                size: 30,
                                color: Colors.white,
                              ),
                              if (unread > 0)
                                Positioned(
                                  right: -2,
                                  top: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      unread > 9 ? '9+' : '$unread',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: AppFontSize.xs(context),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // ── BALANCE CARD ────────────────────────────────
                BalanceCard(
                  accounts: userAccounts,
                  selectedAccountId: selectedAccount.id,
                  isBalanceHidden: provider.isBalanceHidden,
                  onToggleVisibility: provider.toggleBalanceVisibility,
                  onChanged: (accountId) {
                    if (accountId == null) return;
                    provider.selectAccount(accountId);
                  },
                  balance: selectedAccount.availableBalance,
                  accountNumber: selectedAccount.accountNumber,
                  accountType: selectedAccount.accountType,
                ),

                const SizedBox(height: 22),

                // ── QUICK ACTIONS ───────────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      QuickActionItem(
                        icon: Icons.send,
                        // ── CHANGED ── was: "Pay to anyone"
                        title: t.dashboard_send,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (ctx) => UpiProvider(
                                ctx.read<AuthProvider>(),
                                ctx.read<AccountProvider>(),
                              ),
                              child: const UpiHomeScreen(),
                            ),
                          ),
                        ),
                      ),
                      QuickActionItem(
                        icon: Icons.add_circle_outline,
                        // ── CHANGED ── was: "Receive"
                        title: t.dashboard_addMoney,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (ctx) => UpiProvider(
                                ctx.read<AuthProvider>(),
                                ctx.read<AccountProvider>(),
                              ),
                              child: const ReceiveMoneyScreen(),
                            ),
                          ),
                        ),
                      ),
                      QuickActionItem(
                        icon: Icons.qr_code_scanner,
                        // ── CHANGED ── was: "Scan"
                        title: t.dashboard_scan,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider(
                              create: (ctx) => UpiProvider(
                                ctx.read<AuthProvider>(),
                                ctx.read<AccountProvider>(),
                              ),
                              child: const ScanQrScreen(),
                            ),
                          ),
                        ),
                      ),
                      QuickActionItem(
                        icon: Icons.account_balance_wallet,
                        // ── CHANGED ── was: "Wallet"
                        title: t.dashboard_wallet,
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.wallet),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // ── QUICK ACCESS HEADER ─────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // ── CHANGED ── was: "Quick Access"
                      t.dashboard_quickAccess,
                      style: TextStyle(
                        fontSize: AppFontSize.large(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      // ── CHANGED ── was: "Edit"
                      t.dashboard_edit,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: AppFontSize.body(context),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // ── QUICK ACCESS GRID ───────────────────────────
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                  children: [
                    FeatureItem(
                      icon: Icons.account_balance,
                      // ── CHANGED ── was: "Accounts"
                      title: t.qa_accounts,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.accounts),
                    ),
                    FeatureItem(
                      icon: Icons.credit_card,
                      // ── CHANGED ── was: "Cards"
                      title: t.qa_cards,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.cards),
                    ),
                    FeatureItem(
                      icon: Icons.currency_rupee,
                      // ── CHANGED ── was: "Loans"
                      title: t.qa_loans,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.loans),
                    ),
                    FeatureItem(
                      icon: Icons.bar_chart,
                      // ── CHANGED ── was: "Analytics"
                      title: t.qa_analytics,
                     onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AnalyticsScreen(),
                          ),
                        );
                      },
                    ),
                    FeatureItem(
                      icon: Icons.calculate,
                      title:
                          t.qa_calculators,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.calculators),
                    ),
                    FeatureItem(
                      icon: Icons.receipt_long,
                      // ── CHANGED ── was: "Bills"
                      title: t.qa_bills,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.bills),
                    ),
                    FeatureItem(
                      icon: Icons.card_giftcard,
                      // ── CHANGED ── was: "Rewards"
                      title: t.qa_rewards,
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.rewards),
                    ),
                    if (!provider.showMoreServices)
                      FeatureItem(
                        icon: Icons.more_horiz,
                        // ── CHANGED ── was: "More"
                        title: t.qa_more,
                        onTap: () => provider.toggleMoreServices(),
                      ),
                    if (provider.showMoreServices) ...[
                      FeatureItem(
                        icon: Icons.savings,
                        title: t.qa_termDeposit,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.termDeposits,
                        ),
                      ),
                      FeatureItem(
                        icon: Icons.trending_up,
                        title: t.qa_invest,
                      ),
                      FeatureItem(
                        icon: Icons.security,
                        title: t.qa_insurance,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.insurance,
                        ),
                      ),
                      FeatureItem(
                        icon: Icons.people,
                        title: t.qa_beneficiary,
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.beneficiaries,
                        ),
                      ),
                      FeatureItem(
                        icon: Icons.expand_less,
                        title: t.qa_Less,
                        onTap: () => provider.toggleMoreServices(),
                      ),
                    ],
                  ],
                ),

                const SizedBox(height: 26),

                // ── RECENT TRANSACTIONS HEADER ──────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      // ── CHANGED ── was: "Recent Transactions"
                      t.dashboard_recentTx,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppFontSize.large(context),
                        color: Colors.white,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionHistoryScreen(),
                        ),
                      ),
                      child: Text(
                        // ── CHANGED ── was: "See All"
                        t.dashboard_seeAll,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: AppFontSize.body(context),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                AnimatedBuilder(
                  animation: TransactionProvider.instance,
                  builder: (context, _) {
                    final txnProvider = TransactionProvider.instance;
                    final recent = txnProvider.recentTransactions(count: 2);

                    if (recent.isEmpty && txnProvider.isLoading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      );
                    }

                    if (recent.isEmpty && txnProvider.loadError != null) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Could not load recent transactions',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: AppFontSize.body(context),
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () => txnProvider.refresh(),
                              child: const Text(
                                'Retry',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return Column(
                      children: recent
                          .map(
                            (transaction) => TransactionTileWidget(
                              transaction: transaction,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TransactionHistoryScreen(),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}