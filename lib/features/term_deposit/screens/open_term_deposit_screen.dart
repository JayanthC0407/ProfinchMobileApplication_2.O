import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../../../data/models/term_deposit_model.dart';
import '../../accounts/provider/account_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/term_deposit_provider.dart';
import '../../Transactions/provider/transaction_provider.dart';

class OpenTermDepositScreen extends StatefulWidget {
  const OpenTermDepositScreen({super.key});

  @override
  State<OpenTermDepositScreen> createState() => _OpenTermDepositScreenState();
}

class _OpenTermDepositScreenState extends State<OpenTermDepositScreen> {
  String? selectedAccountId;
  int tenureMonths = 12;
  final amountController = TextEditingController();
  String? amountError;

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  double get interestRate {
    switch (tenureMonths) {
      case 3:
        return 5.5;
      case 6:
        return 6.0;
      case 12:
        return 7.0;
      case 24:
        return 7.5;
      default:
        return 8.0;
    }
  }

  double get maturityAmount {
    final amount = double.tryParse(amountController.text) ?? 0;
    return amount + (amount * interestRate / 100);
  }

  double get interestEarned {
    final amount = double.tryParse(amountController.text) ?? 0;
    return amount * interestRate / 100;
  }

  void _handleOpenDeposit(BuildContext context) {
    final amount = double.tryParse(amountController.text) ?? 0;

    setState(() {
      amountError = null;
    });

    if (amount <= 0) {
      setState(() {
        amountError = "Please enter deposit amount";
      });

      return;
    }

    if (selectedAccountId == null) {
      return;
    }

    final accountProvider = context.read<AccountProvider>();
    final tdProvider = context.read<TermDepositProvider>();
    final user = context.read<AuthProvider>().currentUser!;

    final account = accountProvider.getAccountById(selectedAccountId!);
    if (amount > account.availableBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Insufficient balance'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    accountProvider.debitAccount(selectedAccountId!, amount);
    final depositId = 'TD${DateTime.now().millisecondsSinceEpoch}';
    tdProvider.addDeposit(
      TermDepositModel(
        id: depositId,
        userId: user.id,
        sourceAccountId: selectedAccountId!,
        principalAmount: amount,
        interestRate: interestRate,
        tenureMonths: tenureMonths,
        startDate: DateTime.now(),
        maturityDate: DateTime.now().add(Duration(days: tenureMonths * 30)),
        maturityAmount: maturityAmount,
        status: 'ACTIVE',
      ),
    );
    TransactionProvider.instance.recordTermDepositDeduction(
      accountId: selectedAccountId!,
      amount: amount,
      depositId: depositId,
      balanceAfter:
          accountProvider.getAccountById(selectedAccountId!).availableBalance,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: Colors.green,
                child: Icon(Icons.check, color: Colors.white, size: 42),
              ),

              const SizedBox(height: 20),

              const Text(
                "Deposit Created",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                "Fixed Deposit of ₹${amount.toStringAsFixed(2)} has been opened successfully.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    Navigator.pop(context);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),

                  child: const Text("Done"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final accountProvider = context.watch<AccountProvider>();
    final accounts = accountProvider.getAccountsByUserId(user.id);
    selectedAccountId ??= accounts.isNotEmpty ? accounts.first.id : null;

    final amount = double.tryParse(amountController.text) ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Open Deposit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Preview card ───────────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0A3D62), Color(0xFF1A5FA5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Maturity Amount',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${maturityAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _previewChip('Rate: $interestRate%'),
                      const SizedBox(width: 8),
                      _previewChip('$tenureMonths Months'),
                      const SizedBox(width: 8),
                      if (amount > 0)
                        _previewChip(
                          'Interest: ₹${interestEarned.toStringAsFixed(0)}',
                        ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── From account ───────────────────────────────────
            _sectionLabel('From Account'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedAccountId,
                  isExpanded: true,
                  onChanged: (val) => setState(() => selectedAccountId = val),
                  items: accounts.map((a) {
                    return DropdownMenuItem(
                      value: a.id,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${a.accountType} ••${a.accountNumber.replaceAll(' ', '').substring(a.accountNumber.replaceAll(' ', '').length - 4)}',
                            style: const TextStyle(fontSize: 14),
                          ),
                          Text(
                            '₹${a.availableBalance.toStringAsFixed(0)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Amount ─────────────────────────────────────────
            _sectionLabel('Deposit Amount (₹)'),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  onChanged: (_) {
                    setState(() {
                      amountError = null;
                    });
                  },
                  decoration: _inputDecoration(
                    hint: '0.00',
                    icon: Icons.currency_rupee_rounded,
                  ),
                ),

                if (amountError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, left: 4),
                    child: Text(
                      amountError!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Quick amount chips ──────────────────────────────
            Wrap(
              spacing: 8,
              children: [10000, 25000, 50000, 100000].map((amt) {
                return GestureDetector(
                  onTap: () {
                    amountController.text = amt.toString();
                    setState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      '₹$amt',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // ── Tenure ─────────────────────────────────────────
            _sectionLabel('Tenure'),
            const SizedBox(height: 10),
            Row(
              children: [3, 6, 12, 24].map((months) {
                final isSelected = tenureMonths == months;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => tenureMonths = months),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primaryDark
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primaryDark
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '$months',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            'Mo',
                            style: TextStyle(
                              fontSize: 10,
                              color: isSelected ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ── Submit button ──────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => _handleOpenDeposit(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Open Fixed Deposit',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Color(0xFF555555),
    ),
  );

  Widget _previewChip(String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
    prefixIcon: Icon(icon, size: 18, color: Colors.grey.shade500),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.grey.shade200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}