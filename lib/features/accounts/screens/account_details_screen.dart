import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';
import 'package:profinch_mobile_application/data/models/transaction_model.dart';
import 'package:profinch_mobile_application/features/Transactions/provider/transaction_provider.dart';
import 'account_statement_screen.dart';

class AccountDetailsScreen extends StatelessWidget {
  final AccountModel account;

  const AccountDetailsScreen({super.key, required this.account});

  // ── E-Statement bottom sheet ─────────────────────────────────────────────
  void _showEStatementSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (_) => _EStatementSheet(account: account),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.light,
        title: Text('Account Details', style: AppTextStyles.whiteTitle(context)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── ACCOUNT HEADER CARD ───────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.navy],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(account.accountType,
                      style: AppTextStyles.whiteTitle(context)),
                  const SizedBox(height: 6),
                  Text(account.accountNumber,
                      style: AppTextStyles.whiteBody(context,
                          color: AppColors.light.withValues(alpha: 0.8))),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Available Balance',
                              style: AppTextStyles.whiteCaption(context)),
                          const SizedBox(height: 4),
                          Text(
                            '₹ ${account.availableBalance.toStringAsFixed(2)}',
                            style: AppTextStyles.whiteHeading(context),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: account.isActive
                              ? AppColors.successLight
                              : AppColors.errorLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          account.isActive ? 'Active' : 'Inactive',
                          style: AppTextStyles.smallBold(context,
                              color: account.isActive
                                  ? AppColors.successDark
                                  : AppColors.errorDark),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── STATEMENT ACTIONS ─────────────────────────────────
            Text('Statements', style: AppTextStyles.title(context)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'Download\nPDF Statement',
                    color: AppColors.primary,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AccountStatementScreen(account: account),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.email_outlined,
                    label: 'E-Statement\n(Monthly Email)',
                    color: AppColors.blueButton,
                    onTap: () => _showEStatementSheet(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── ACCOUNT DETAILS LIST ──────────────────────────────
            Text('Account Information', style: AppTextStyles.title(context)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _DetailTile(label: 'Account Number',
                      value: account.accountNumber),
                  _DetailTile(label: 'Account Type',
                      value: account.accountType),
                  _DetailTile(label: 'Branch',
                      value: account.branchName),
                  _DetailTile(label: 'IFSC',
                      value: account.ifscCode),
                  _DetailTile(label: 'IBAN',
                      value: account.iban),
                  _DetailTile(label: 'Currency',
                      value: account.currencyCode),
                  _DetailTile(label: 'Opening Date',
                      value: _formatDate(account.openingDate)),
                  _DetailTile(label: 'Balance',
                      value: '₹ ${account.balance.toStringAsFixed(2)}'),
                  _DetailTile(
                    label: 'Available Balance',
                    value: '₹ ${account.availableBalance.toStringAsFixed(2)}',
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── FEATURES ─────────────────────────────────────────
            Text('Facilities', style: AppTextStyles.title(context)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _FeatureTile(label: 'Cheque Book',
                      enabled: account.hasChequeBook),
                  _FeatureTile(label: 'ATM / Debit Card',
                      enabled: account.hasATMFacility),
                  _FeatureTile(label: 'Overdraft',
                      enabled: account.hasOverDraftFacility),
                  _FeatureTile(label: 'Nominee Registered',
                      enabled: account.nomineeRegistered,
                      isLast: true),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';
}

// ── E-Statement bottom sheet ──────────────────────────────────────────────

class _EStatementSheet extends StatefulWidget {
  final AccountModel account;
  const _EStatementSheet({required this.account});

  @override
  State<_EStatementSheet> createState() => _EStatementSheetState();
}

class _EStatementSheetState extends State<_EStatementSheet> {
  // Last 6 months including current
  late final List<DateTime> _months = _buildMonths();
  int _selectedIndex = 0;

  List<DateTime> _buildMonths() {
    final now = DateTime.now();
    return List.generate(
        6, (i) => DateTime(now.year, now.month - i, 1));
  }

  String _monthLabel(DateTime d) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month]} ${d.year}';
  }

  List<TransactionModel> get _monthTransactions {
    final selected = _months[_selectedIndex];
    final start = DateTime(selected.year, selected.month, 1);
    final end = DateTime(selected.year, selected.month + 1, 1)
        .subtract(const Duration(seconds: 1));
    return TransactionProvider.instance.allTransactionsSorted
        .where((t) =>
            t.accountId == widget.account.id &&
            !t.date.isBefore(start) &&
            !t.date.isAfter(end))
        .toList();
  }

  void _sendEmail(BuildContext context) {
    final month = _monthLabel(_months[_selectedIndex]);
    final count = _monthTransactions.length;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'E-Statement for $month ($count transactions) will be sent to '
          'your registered email address.',
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactions = _monthTransactions;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.grey300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text('E-Statement', style: AppTextStyles.heading(context)),
            Text(
              'Select a month to send to your registered email',
              style: AppTextStyles.bodySecondary(context),
            ),

            const SizedBox(height: 16),

            // Month selector chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _months.length,
                // ignore: unnecessary_underscores
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final selected = i == _selectedIndex;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.primary
                            : AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : AppColors.grey300,
                        ),
                      ),
                      child: Text(
                        _monthLabel(_months[i]),
                        style: AppTextStyles.small(context,
                            color: selected
                                ? AppColors.light
                                : AppColors.textPrimary),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Transaction preview
            Text(
              '${transactions.length} transaction${transactions.length == 1 ? '' : 's'} in ${_monthLabel(_months[_selectedIndex])}',
              style: AppTextStyles.bodySecondary(context),
            ),

            const SizedBox(height: 10),

            Flexible(
              child: transactions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text('No transactions this month',
                            style: AppTextStyles.bodySecondary(context)),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: transactions.length,
                      itemBuilder: (_, i) {
                        final t = transactions[i];
                        final isCredit = t.type == TransactionType.credit;
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: isCredit
                                ? AppColors.successLight
                                : AppColors.errorLight,
                            child: Icon(
                              isCredit
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              size: 14,
                              color: isCredit
                                  ? AppColors.successDark
                                  : AppColors.errorDark,
                            ),
                          ),
                          title: Text(t.title,
                              style: AppTextStyles.body(context)),
                          subtitle: Text(
                            '${t.date.day}/${t.date.month}/${t.date.year}',
                            style: AppTextStyles.caption(context),
                          ),
                          trailing: Text(
                            '${isCredit ? '+' : '-'} ₹ ${t.amount.toStringAsFixed(2)}',
                            style: AppTextStyles.bodyBold(context,
                                color: isCredit
                                    ? AppColors.success
                                    : AppColors.error),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 12),

            // Send button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _sendEmail(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.light,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Icons.send_rounded),
                label: Text(
                  'Send E-Statement to Email',
                  style:
                      AppTextStyles.labelBold(context, color: AppColors.light),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Private helper widgets ─────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: AppTextStyles.bodyBold(context),
                maxLines: 2),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _DetailTile({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.bodySecondary(context)),
              Flexible(
                child: Text(value,
                    style: AppTextStyles.bodyBold(context),
                    textAlign: TextAlign.end),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 16, endIndent: 16,
              color: AppColors.surfaceLight),
      ],
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final String label;
  final bool enabled;
  final bool isLast;

  const _FeatureTile({
    required this.label,
    required this.enabled,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.body(context)),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: enabled
                      ? AppColors.successLight
                      : AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  enabled ? 'Available' : 'Not Available',
                  style: AppTextStyles.small(context,
                      color: enabled
                          ? AppColors.successDark
                          : AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 16, endIndent: 16,
              color: AppColors.surfaceLight),
      ],
    );
  }
}