import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../accounts/provider/account_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../upi/provider/upi_provider.dart';
import '../../upi/screens/upi_home_screen.dart';

class MenuNode {
  final String label;
  final IconData? icon;
  final List<MenuNode> children;
  final void Function(BuildContext context)? onNavigate;

  const MenuNode(
    this.label, {
    this.icon,
    this.children = const [],
    this.onNavigate,
  });

  bool get isExpandable => children.isNotEmpty;
}

/// Opens the existing UPI home screen with the providers it needs.
void _openUpi(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (innerContext) => UpiProvider(
          innerContext.read<AuthProvider>(),
          innerContext.read<AccountProvider>(),
        ),
        child: const UpiHomeScreen(),
      ),
    ),
  );
}

/// Presales menu structure with existing Phase 1 screens mapped to their
/// closest corresponding menu options.
final List<MenuNode> _menuTree = [
  MenuNode(
    'Accounts',
    icon: Icons.account_balance_outlined,
    onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.accounts),
    children: [
      MenuNode(
        'Current & Savings',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.accounts),
        children: [
          MenuNode(
            'Current & Savings Accounts',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.accounts),
          ),
          MenuNode(
            'Current & Savings Account Details',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.accounts),
          ),
          MenuNode(
            'Transactions',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.transactions),
          ),
          const MenuNode('Cheque Status Inquiry'),
          const MenuNode('Cheque Book Request'),
          const MenuNode('Stop/Unblock Cheque'),
          MenuNode(
            'Debit Cards',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.cards),
          ),
          const MenuNode('Sweep-In'),
        ],
      ),

      MenuNode(
        'Term Deposits',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.termDeposits),
        children: [
          MenuNode(
            'Term Deposits',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.termDeposits),
          ),
          MenuNode(
            'Term Deposit Details',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.myDeposits),
          ),
          MenuNode(
            'New Term Deposit',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.openDeposit),
          ),
          MenuNode(
            'Transactions',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.depositStatements),
          ),
          const MenuNode('Top Up'),
          MenuNode(
            'Redeem Term Deposit',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.redeemDeposit),
          ),
          const MenuNode('Edit Maturity Instructions'),
        ],
      ),

      const MenuNode(
        'Recurring Deposits',
        children: [
          MenuNode('Recurring Deposits'),
          MenuNode('Recurring Deposit Details'),
          MenuNode('New Recurring Deposit'),
          MenuNode('Transactions'),
          MenuNode('Redeem Recurring Deposit'),
          MenuNode('Edit Maturity Instructions'),
        ],
      ),

      MenuNode(
        'Loans & Finances',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.loans),
        children: [
          MenuNode(
            'Loans & Finances',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.loans),
          ),
          MenuNode(
            'Loan & Finance Details',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.myLoans),
          ),
          MenuNode(
            'Transactions',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.loanStatements),
          ),
          MenuNode(
            'Loan & Finance Repayment',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.repayLoan),
          ),
          const MenuNode('Disbursement Inquiry'),
          MenuNode(
            'Schedule Inquiry',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.loanStatements),
          ),
        ],
      ),

      const MenuNode('Nominations'),

      const MenuNode(
        'Certificates',
        children: [
          MenuNode('Interest Certificates'),
          MenuNode('Balance Certificates'),
          MenuNode('TDS Certificates'),
        ],
      ),
    ],
  ),

  MenuNode(
    'Futura Wallet',
    icon: Icons.account_balance_wallet_outlined,
    onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.wallet),
    children: [
      MenuNode(
        'Recharge Futura Wallet',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.wallet),
      ),
      MenuNode(
        'Futura Wallet Requests',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.wallet),
      ),
      MenuNode(
        'Transfers - Existing Payee',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.transferMoney),
      ),
      MenuNode(
        'Billers',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.bills),
      ),
      MenuNode(
        'Futura Wallet Transactions',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.wallet),
      ),
      MenuNode(
        'Futura Wallet Details',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.wallet),
      ),
    ],
  ),

  MenuNode(
    'Credit Cards',
    icon: Icons.credit_card_outlined,
    onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.cards),
    children: [
      MenuNode(
        'Credit Cards',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.cards),
      ),
      MenuNode(
        'Credit Card Details',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.cards),
      ),
      MenuNode(
        'Transactions',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.transactions),
      ),
      MenuNode(
        'Card Payment',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.payments),
      ),
      const MenuNode('Request PIN'),
      const MenuNode('Block/Unblock Card'),
      const MenuNode('Cancel Card'),
      const MenuNode('Auto Pay'),
      const MenuNode('Reset PIN'),
      MenuNode(
        'Add-On Card',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.applyCard),
      ),
    ],
  ),

  MenuNode(
    'Payments',
    icon: Icons.payments_outlined,
    onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.payments),
    children: [
      MenuNode(
        'Favorites',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.favourites),
      ),
      const MenuNode('Saved Drafts'),

      MenuNode(
        'Payee',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.beneficiaries),
        children: [
          MenuNode(
            'Manage Payees',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.beneficiaries),
          ),
          MenuNode(
            'Add Account Payee',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.addBeneficiary),
          ),
          MenuNode(
            'Add Draft Payee',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.addBeneficiary),
          ),
          MenuNode(
            'Add Peer To Peer Payee',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.addBeneficiary),
          ),
        ],
      ),

      MenuNode(
        'Transfers',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.transferMoney),
        children: [
          MenuNode(
            'Transfers - Existing Payee',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.transferMoney),
          ),
          MenuNode(
            'Transfers - Adhoc Payee',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.adhocTransfer),
          ),
          MenuNode(
            'Repeat Transfers - Existing Payee',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.scheduledPayment),
          ),
          MenuNode(
            'Repeat Transfers - Adhoc Payee',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.scheduledPayment),
          ),
          MenuNode(
            'Other Transfers',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.payments),
          ),
          const MenuNode('International Low Value Payment'),
          const MenuNode('Multiple Transfers'),
        ],
      ),

      const MenuNode(
        'Payment Inquiries',
        children: [
          MenuNode('Payment Status Inquiry'),
          MenuNode('Repeat Transfers Inquiry'),
        ],
      ),

      const MenuNode(
        'Demand Draft',
        children: [
          MenuNode('Issue Demand Drafts'),
          MenuNode('Adhoc Demand Draft'),
        ],
      ),

      const MenuNode(
        'Positive Pay',
        children: [
          MenuNode('Create Positive Pay'),
          MenuNode('List Positive Pay'),
        ],
      ),

      MenuNode(
        'Debtors',
        children: [
          MenuNode(
            'Manage Debtors',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.beneficiaries),
          ),
          MenuNode(
            'Add New Debtors',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.addBeneficiary),
          ),
          const MenuNode('Request Money'),
        ],
      ),
    ],
  ),

  MenuNode(
    'Bill Payments',
    icon: Icons.receipt_long_outlined,
    onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.bills),
    children: [
      MenuNode(
        'Billers',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.bills),
      ),
      MenuNode(
        'Add Billers',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.bills),
      ),
      MenuNode(
        'Quick Bill Pay',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.bills),
      ),
      MenuNode(
        'Quick Recharge',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.bills),
      ),
      MenuNode(
        'Bill Payment History',
        onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.bills),
      ),
    ],
  ),

  MenuNode(
    'UPI',
    icon: Icons.qr_code_scanner_outlined,
    onNavigate: _openUpi,
    children: [
      MenuNode('Manage VPA', onNavigate: _openUpi),
      MenuNode('Adhoc Transfer', onNavigate: _openUpi),
      MenuNode('Transfer Money', onNavigate: _openUpi),
      MenuNode('Request Money', onNavigate: _openUpi),
      MenuNode('Pending Requests', onNavigate: _openUpi),
      MenuNode('Transaction History', onNavigate: _openUpi),
      MenuNode('Split Bill', onNavigate: _openUpi),
    ],
  ),

  MenuNode(
    'Personal Finance',
    icon: Icons.analytics_outlined,
    onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.analytics),
    children: [
      const MenuNode(
        'Goals',
        children: [MenuNode('Goals'), MenuNode('Goal Calculator')],
      ),
      MenuNode(
        'Spend Analysis',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.analytics),
      ),
      const MenuNode('Budgets'),
      const MenuNode('FuturaMax'),
    ],
  ),

  const MenuNode(
    'Wealth Management',
    icon: Icons.trending_up_outlined,
    children: [
      MenuNode('Investments Overview'),
      MenuNode(
        'Place Orders',
        children: [
          MenuNode('Purchase Mutual Funds'),
          MenuNode('Redeem Mutual Funds'),
          MenuNode('Switch Mutual Funds'),
          MenuNode('Order Status'),
        ],
      ),
      MenuNode(
        'Start Investing',
        children: [
          MenuNode('Open Investment Account'),
          MenuNode('Risk Profiling'),
        ],
      ),
      MenuNode('Investment Details'),
      MenuNode(
        'Reports',
        children: [
          MenuNode('Transactions Report'),
          MenuNode('Dividends Report'),
          MenuNode('Capital Gain Reports'),
        ],
      ),
    ],
  ),

  const MenuNode(
    'Service Requests',
    icon: Icons.support_agent_outlined,
    children: [MenuNode('Track Requests'), MenuNode('Raise a New Request')],
  ),

  MenuNode(
    'Account Settings',
    icon: Icons.settings_outlined,
    onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.profile),
    children: [
      MenuNode(
        'Preferences',
        icon: Icons.tune_outlined,
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.profile),
        children: [
          MenuNode(
            'Profile',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
          MenuNode(
            'Primary Account Number',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.accounts),
          ),
          const MenuNode('Third Party Applications'),
          MenuNode(
            'Security & Login',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
          MenuNode(
            'Themes',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
          MenuNode(
            'Settings',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.profile),
          ),
          const MenuNode('Manage DND Alerts'),
        ],
      ),
      MenuNode(
        'Change Password',
        icon: Icons.lock_outline,
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.profile),
      ),
      const MenuNode('My Limits', icon: Icons.speed_outlined),
      const MenuNode('Session Summary', icon: Icons.access_time_outlined),
      const MenuNode('Alerts Subscription'),
    ],
  ),

  MenuNode(
    'Mailbox',
    icon: Icons.mail_outline,
    children: [
      const MenuNode('Mails'),
      const MenuNode('Alerts'),
      MenuNode(
        'Notifications',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.notifications),
      ),
    ],
  ),

  MenuNode(
    'Product Offerings',
    icon: Icons.local_offer_outlined,
    children: [
      MenuNode(
        'Rewards',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.rewards),
      ),
      MenuNode(
        'Insurance',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.insurance),
        children: [
          MenuNode(
            'My Policies',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.myPolicies),
          ),
          MenuNode(
            'Buy Insurance',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.buyInsurance),
          ),
          MenuNode(
            'Insurance Claims',
            onNavigate: (context) =>
                Navigator.pushNamed(context, AppRoutes.insuranceClaims),
          ),
        ],
      ),
    ],
  ),

  MenuNode(
    'Calculators',
    icon: Icons.calculate_outlined,
    onNavigate: (context) =>
        Navigator.pushNamed(context, AppRoutes.calculators),
    children: [
      MenuNode(
        'Term Deposit Calculator',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.tdCalculator),
      ),
      MenuNode(
        'Loan Installment Calculator',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.emiCalculator),
      ),
      MenuNode(
        'Loan Eligibility Calculator',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.loanEligibility),
      ),
      MenuNode(
        'Forex Calculator',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.currencyConverter),
      ),
      MenuNode(
        'SIP Calculator',
        onNavigate: (context) =>
            Navigator.pushNamed(context, AppRoutes.sipCalculator),
      ),
    ],
  ),

  const MenuNode('Leave Feedback', icon: Icons.chat_bubble_outline),
  const MenuNode('ATM & Branch Locator', icon: Icons.location_on_outlined),
  MenuNode(
    'Help',
    icon: Icons.help_outline,
    onNavigate: (context) => Navigator.pushNamed(context, AppRoutes.profile),
  ),
  const MenuNode('About', icon: Icons.info_outline),
  const MenuNode('Logout', icon: Icons.logout),
];

class AppMenuDrawer extends StatelessWidget {
  const AppMenuDrawer({super.key});

  static const String _logoutLabel = 'Logout';

  void _onLeafTap(BuildContext context, String label) {
    final navigator = Navigator.of(context);
    navigator.pop();

    if (label == _logoutLabel) {
      context.read<AuthProvider>().logout();

      navigator.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
      return;
    }

    ScaffoldMessenger.of(navigator.context).showSnackBar(
      SnackBar(
        content: Text('$label is coming in a later phase.'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drawerWidth = MediaQuery.sizeOf(context).width * 0.88;

    return Drawer(
      width: drawerWidth > 380 ? 380 : drawerWidth,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const _MenuHeader(),
            const Divider(color: AppColors.grey300, height: 1),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 24),
                itemCount: _menuTree.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: _MenuNodeTile(
                      node: _menuTree[index],
                      depth: 0,
                      onLeafTap: _onLeafTap,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuNodeTile extends StatefulWidget {
  final MenuNode node;
  final int depth;
  final void Function(BuildContext, String) onLeafTap;

  const _MenuNodeTile({
    required this.node,
    required this.depth,
    required this.onLeafTap,
  });

  @override
  State<_MenuNodeTile> createState() => _MenuNodeTileState();
}

class _MenuNodeTileState extends State<_MenuNodeTile> {
  bool _expanded = false;

  void _toggleExpanded() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _navigate(BuildContext context) {
    final navigation = widget.node.onNavigate;
    if (navigation == null) return;

    final navigator = Navigator.of(context);

    navigator.pop();

    Future.microtask(() {
      navigation(navigator.context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final node = widget.node;
    final depth = widget.depth;
    final isTopLevel = depth == 0;

    // Each expanded group already adds indentation, so child rows only need a
    // small local inset. This keeps deeply nested menus from drifting right.
    final leftPadding = isTopLevel ? 12.0 : 10.0;

    final titleStyle = TextStyle(
      color: isTopLevel ? AppColors.textPrimary : AppColors.textSecondary,
      fontSize: isTopLevel ? 14.5 : 13.5,
      fontWeight: isTopLevel
          ? FontWeight.w600
          : node.isExpandable
          ? FontWeight.w600
          : FontWeight.w400,
    );

    final leading = node.icon != null
        ? Container(
            width: isTopLevel ? 36 : 30,
            height: isTopLevel ? 36 : 30,
            decoration: BoxDecoration(
              color: isTopLevel
                  ? AppColors.iconBackground
                  : AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              node.icon,
              color: isTopLevel ? AppColors.primary : AppColors.grey700,
              size: isTopLevel ? 20 : 16,
            ),
          )
        : null;

    if (!node.isExpandable) {
      return Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: node.onNavigate != null
              ? () => _navigate(context)
              : () => widget.onLeafTap(context, node.label),
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              leftPadding,
              isTopLevel ? 8 : 8,
              12,
              isTopLevel ? 8 : 8,
            ),
            child: Row(
              children: [
                if (leading != null) ...[
                  leading,
                  const SizedBox(width: 12),
                ] else if (!isTopLevel) ...[
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(child: Text(node.label, style: titleStyle)),
                if (node.label == 'Logout')
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.grey400,
                    size: 18,
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Material(
          color: isTopLevel && _expanded
              ? AppColors.iconBackground
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _toggleExpanded,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      leftPadding,
                      isTopLevel ? 8 : 7,
                      4,
                      isTopLevel ? 8 : 7,
                    ),
                    child: Row(
                      children: [
                        if (leading != null) ...[
                          leading,
                          const SizedBox(width: 12),
                        ] else if (!isTopLevel) ...[
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(child: Text(node.label, style: titleStyle)),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: _toggleExpanded,
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: AnimatedRotation(
                    duration: const Duration(milliseconds: 180),
                    turns: _expanded ? 0.5 : 0,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _expanded ? AppColors.primary : AppColors.grey400,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Container(
            width: double.infinity,
            margin: EdgeInsets.only(
              left: isTopLevel ? 28 : 16,
              top: 2,
              bottom: 5,
            ),
            padding: const EdgeInsets.only(left: 8),
            decoration: const BoxDecoration(
              border: Border(
                left: BorderSide(color: AppColors.grey300, width: 1),
              ),
            ),
            child: Column(
              children: node.children.map((child) {
                return _MenuNodeTile(
                  node: child,
                  depth: depth + 1,
                  onLeafTap: widget.onLeafTap,
                );
              }).toList(),
            ),
          ),
          crossFadeState: _expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
          sizeCurve: Curves.easeInOut,
        ),
      ],
    );
  }
}

class _MenuHeader extends StatelessWidget {
  const _MenuHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.light, AppColors.iconBackground],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.lightBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.menu_rounded,
              color: AppColors.primary,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Menu',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Banking services and settings',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close menu',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.close_rounded,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
