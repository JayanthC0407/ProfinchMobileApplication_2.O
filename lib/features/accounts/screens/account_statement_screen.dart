import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';
import 'package:profinch_mobile_application/data/models/transaction_model.dart';
import 'package:profinch_mobile_application/data/repositories/transaction_repository.dart';
import 'package:profinch_mobile_application/data/repositories/common_repository.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// ignore: avoid_web_libraries_in_flutter

import 'dart:typed_data';
import 'package:file_saver/file_saver.dart';

class AccountStatementScreen extends StatefulWidget {
  final AccountModel account;

  const AccountStatementScreen({super.key, required this.account});

  @override
  State<AccountStatementScreen> createState() => _AccountStatementScreenState();
}

class _AccountStatementScreenState extends State<AccountStatementScreen> {
  // Placeholder values until the real business date loads in initState —
  // overwritten before the first transactions request goes out, so these
  // never actually reach the server.
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _toDate = DateTime.now();
  bool _isGenerating = false;

  final _transactionRepository = TransactionRepository();
  final _commonRepository = CommonRepository();
  List<TransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _loadError;

  /// OBDX's core banking business date — see CommonRepository doc. Used
  /// as "today" for the default range, quick-range chips, and the date
  /// picker's max-selectable date, since the server rejects any fromDate/
  /// toDate later than this (DIGX_DDA_051), regardless of the device's
  /// actual current date.
  DateTime? _serverCurrentDate;

  @override
  void initState() {
    super.initState();
    _initDateRangeThenFetch();
  }

  Future<void> _initDateRangeThenFetch() async {
    DateTime today;
    try {
      today = await _commonRepository.getCurrentDate();
    } catch (_) {
      // Fall back to device time — worst case the transactions call below
      // surfaces the same "future date" validation error, which is
      // already shown to the user via _loadError rather than failing
      // silently.
      today = DateTime.now();
    }

    if (!mounted) return;
    setState(() {
      _serverCurrentDate = today;
      _toDate = today;
      _fromDate = today.subtract(const Duration(days: 30));
    });

    _fetchTransactions();
  }

  Future<void> _fetchTransactions() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });

    try {
      final result = await _transactionRepository.getAccountTransactions(
        accountId: widget.account.id,
        fromDate: _fromDate,
        toDate: _toDate,
      );

      // Defensive client-side filter: the fromDate/toDate query param
      // format sent to OBDX is confirmed correct (yyyy-MM-dd), but this
      // still guards against the server returning a wider range than
      // asked for.
      final from = DateTime(_fromDate.year, _fromDate.month, _fromDate.day);
      final to = DateTime(_toDate.year, _toDate.month, _toDate.day, 23, 59, 59);
      final filtered = result
          .where(
            (t) =>
                t.date.isAfter(from.subtract(const Duration(seconds: 1))) &&
                t.date.isBefore(to.add(const Duration(seconds: 1))),
          )
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (!mounted) return;
      setState(() {
        _transactions = filtered;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final maxDate = _serverCurrentDate ?? DateTime.now();
    final rawInitial = isFrom ? _fromDate : _toDate;
    final initial = rawInitial.isAfter(maxDate) ? maxDate : rawInitial;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: maxDate,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );

    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_fromDate.isAfter(_toDate)) _toDate = _fromDate;
      } else {
        _toDate = picked;
        if (_toDate.isBefore(_fromDate)) _fromDate = _toDate;
      }
    });
    _fetchTransactions();
  }

  void _applyQuickRange(int days) {
    final today = _serverCurrentDate ?? DateTime.now();
    setState(() {
      _fromDate = today.subtract(Duration(days: days));
      _toDate = today;
    });
    _fetchTransactions();
  }

  Future<void> _downloadPdf() async {
    final transactions = _transactions;
    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No transactions in this date range.')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      // ── Load a Unicode font from assets so ₹ and other glyphs render ──
      // Requires fonts/NotoSans-Regular.ttf and fonts/NotoSans-Bold.ttf
      // in your assets folder + pubspec.yaml fonts section.
      // Download from: https://fonts.google.com/noto/specimen/Noto+Sans
      pw.Font? regularFont;
      pw.Font? boldFont;
      try {
        final regularData = await rootBundle.load('fonts/NotoSans-Regular.ttf');
        final boldData = await rootBundle.load('fonts/NotoSans-Bold.ttf');
        regularFont = pw.Font.ttf(regularData);
        boldFont = pw.Font.ttf(boldData);
      } catch (_) {
        // Font not bundled yet — PDF will still generate but ₹ may be blank
      }

      final baseStyle = pw.TextStyle(font: regularFont, fontSize: 10);
      final boldStyle = pw.TextStyle(
        font: boldFont ?? regularFont,
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
      );
      final titleStyle = pw.TextStyle(
        font: boldFont ?? regularFont,
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
      );

      // Use ASCII-safe alternatives to avoid Unicode glyph errors:
      //   – (U+2013 en-dash)  → "to"
      //   ₹ (U+20B9 rupee)    → "Rs."  (replaced only in PDF, not in UI)
      String rs(double amount) => 'Rs. ${amount.toStringAsFixed(2)}';

      // Use each transaction's own runningBalance from OBDX — authoritative,
      // no need to walk/recompute it client-side like the old dummy-data
      // version did.
      // PDF shows oldest-first so running balance reads top-to-bottom
      final txnOldestFirst = List<TransactionModel>.from(transactions)
        ..sort((a, b) => a.date.compareTo(b.date));

      final doc = pw.Document();
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context ctx) => [
            pw.Text('Account Statement', style: titleStyle),
            pw.SizedBox(height: 8),
            pw.Text(
              'Account  : ${widget.account.accountNumber}',
              style: baseStyle,
            ),
            pw.Text(
              'Branch   : ${widget.account.branchName}',
              style: baseStyle,
            ),
            pw.Text(
              'Period   : ${_formatDate(_fromDate)} to ${_formatDate(_toDate)}',
              style: baseStyle,
            ),
            pw.Text(
              'Current Balance : Rs. ${widget.account.availableBalance.toStringAsFixed(2)}',
              style: boldStyle,
            ),
            pw.SizedBox(height: 16),
            pw.Table.fromTextArray(
              headers: ['Date', 'Description', 'Type', 'Amount', 'Balance'],
              headerStyle: boldStyle,
              cellStyle: baseStyle,
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blueGrey100,
              ),
              data: txnOldestFirst
                .map((t) => [
                      _formatDate(t.date),
                      t.title,
                      t.type == TransactionType.credit ? 'CR' : 'DR',
                      rs(t.amount),
                      rs(t.balanceAfter),
                    ])
                .toList(),
            ),
          ],
        ),
      );

      final pdfBytes = await doc.save();

      final filename =
          'statement_${widget.account.accountNumber}_${DateTime.now().millisecondsSinceEpoch}.pdf';

await FileSaver.instance.saveFile(
  name: filename.replaceAll('.pdf', ''),
  bytes: Uint8List.fromList(pdfBytes),
  ext: 'pdf',
);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Statement downloaded successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate statement: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  Color _amountColor(TransactionType type) =>
      type == TransactionType.credit ? AppColors.success : AppColors.error;

  @override
  Widget build(BuildContext context) {
    final transactions = _transactions;
    final totalCredit = transactions
        .where((t) => t.type == TransactionType.credit)
        .fold(0.0, (sum, t) => sum + t.amount);
    final totalDebit = transactions
        .where((t) => t.type == TransactionType.debit)
        .fold(0.0, (sum, t) => sum + t.amount);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.light,
        title: Text('Statement', style: AppTextStyles.whiteTitle(context)),
        elevation: 0,
      ),
      body: Column(
        children: [
          // ── ACCOUNT HEADER ──────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.navy],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.account.accountType,
                  style: AppTextStyles.whiteTitle(context),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.account.accountNumber,
                  style: AppTextStyles.whiteBody(
                    context,
                    color: AppColors.light.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.account.branchName,
                  style: AppTextStyles.whiteCaption(context),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── DATE RANGE PICKER ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.light,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Period',
                          style: AppTextStyles.title(context),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _DateButton(
                                label: 'From',
                                date: _fromDate,
                                onTap: () => _pickDate(isFrom: true),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _DateButton(
                                label: 'To',
                                date: _toDate,
                                onTap: () => _pickDate(isFrom: false),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          children: [
                            _RangeChip(
                              label: 'Last 7 days',
                              onTap: () => _applyQuickRange(7),
                            ),
                            _RangeChip(
                              label: 'Last 30 days',
                              onTap: () => _applyQuickRange(30),
                            ),
                            _RangeChip(
                              label: 'Last 3 months',
                              onTap: () => _applyQuickRange(90),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── SUMMARY ROW ───────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Credit',
                          amount: totalCredit,
                          color: AppColors.success,
                          icon: Icons.arrow_downward_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Debit',
                          amount: totalDebit,
                          color: AppColors.error,
                          icon: Icons.arrow_upward_rounded,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    '${transactions.length} transaction${transactions.length == 1 ? '' : 's'}',
                    style: AppTextStyles.bodySecondary(context),
                  ),
                  const SizedBox(height: 10),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_loadError != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline_rounded,
                              size: 48,
                              color: AppColors.error,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Could not load transactions',
                              style: AppTextStyles.bodyBold(context),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _loadError!,
                              style: AppTextStyles.caption(context),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _fetchTransactions,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (transactions.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 48,
                              color: AppColors.grey400,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions found',
                              style: AppTextStyles.bodySecondary(context),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...transactions.map(
                      (t) => _StatementRow(
                        transaction: t,
                        amountColor: _amountColor(t.type),
                        formatDate: _formatDate,
                        computedBalance: t.balanceAfter,
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ── DOWNLOAD BUTTON ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isGenerating ? null : _downloadPdf,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.light,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: _isGenerating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.light,
                        ),
                      )
                    : const Icon(Icons.download_rounded),
                label: Text(
                  _isGenerating ? 'Generating...' : 'Download PDF Statement',
                  style: AppTextStyles.labelBold(
                    context,
                    color: AppColors.light,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Private sub-widgets ────────────────────────────────────────────────────

class _DateButton extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.grey300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.caption(context)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_fmt(date), style: AppTextStyles.bodyBold(context)),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _RangeChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          label,
          style: AppTextStyles.small(context, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.15),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.caption(context)),
                const SizedBox(height: 2),
                Text(
                  '₹ ${amount.toStringAsFixed(2)}',
                  style: AppTextStyles.bodyBold(context, color: color),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatementRow extends StatelessWidget {
  final TransactionModel transaction;
  final Color amountColor;
  final String Function(DateTime) formatDate;
  final double? computedBalance;

  const _StatementRow({
    required this.transaction,
    required this.amountColor,
    required this.formatDate,
    this.computedBalance,
  });

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type == TransactionType.credit;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.light,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: amountColor.withValues(alpha: 0.1),
            child: Icon(
              isCredit
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: amountColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(transaction.title, style: AppTextStyles.bodyBold(context)),
                const SizedBox(height: 2),
                Text(
                  formatDate(transaction.date),
                  style: AppTextStyles.caption(context),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'} ₹ ${transaction.amount.toStringAsFixed(2)}',
                style: AppTextStyles.bodyBold(context, color: amountColor),
              ),
              const SizedBox(height: 2),
              Text(
                'Bal: ₹ ${(computedBalance ?? transaction.balanceAfter).toStringAsFixed(2)}',
                style: AppTextStyles.caption(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}