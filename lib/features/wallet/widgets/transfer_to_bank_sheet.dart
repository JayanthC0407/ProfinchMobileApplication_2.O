import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';

class TransferToBankSheet extends StatefulWidget {
  final List<AccountModel> accounts;
  final double walletBalance;
  final Future<bool> Function({
    required String accountId,
    required double amount,
  }) onTransfer;

  const TransferToBankSheet({
    super.key,
    required this.accounts,
    required this.walletBalance,
    required this.onTransfer,
  });

  @override
  State<TransferToBankSheet> createState() => _TransferToBankSheetState();
}

class _TransferToBankSheetState extends State<TransferToBankSheet> {
  final _amountController = TextEditingController();
  AccountModel? _selectedAccount;
  bool _isLoading = false;
  final List<int> _quickAmounts = [500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    if (widget.accounts.isNotEmpty) {
      _selectedAccount = widget.accounts.first;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _handleTransfer() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _selectedAccount == null) return;
    if (amount > widget.walletBalance) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Insufficient wallet balance'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await widget.onTransfer(
      accountId: _selectedAccount!.id,
      amount: amount,
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success
            ? '₹${amount.toStringAsFixed(0)} transferred to bank!'
            : 'Transfer failed. Try again.'),
        backgroundColor:
            success ? Colors.green.shade600 : Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');

    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Transfer to Bank',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E)),
                ),
                Text(
                  'Wallet: ₹${formatter.format(widget.walletBalance)}',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              'To Account',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade200),
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade50,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<AccountModel>(
                  value: _selectedAccount,
                  isExpanded: true,
                  onChanged: (val) =>
                      setState(() => _selectedAccount = val),
                  items: widget.accounts.map((acc) {
                    return DropdownMenuItem(
                      value: acc,
                      child: Text(
                        '${acc.accountType} ••${acc.accountNumber.replaceAll(' ', '').substring(acc.accountNumber.replaceAll(' ', '').length - 4)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Amount (₹)',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(
                    RegExp(r'^\d+\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: '0.00',
                prefixIcon: const Icon(Icons.currency_rupee,
                    size: 18, color: Colors.grey),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: AppColors.primary, width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              children: _quickAmounts.map((amount) {
                return GestureDetector(
                  onTap: () => setState(() =>
                      _amountController.text = amount.toString()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: AppColors.primary
                              .withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      '₹$amount',
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

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleTransfer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Transfer to Bank',
                        style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}