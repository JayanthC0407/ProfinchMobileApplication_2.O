import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../provider/upi_provider.dart';
import '../widgets/upi_payment_status_widget.dart';

import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';

class SendMoneyScreen extends StatefulWidget {
  final String? prefillUpiId;
  final String? prefillName;

  const SendMoneyScreen({super.key, this.prefillUpiId, this.prefillName});

  @override
  State<SendMoneyScreen> createState() => _SendMoneyScreenState();
}

class _SendMoneyScreenState extends State<SendMoneyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _upiController = TextEditingController();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.prefillUpiId != null) {
      _upiController.text = widget.prefillUpiId!;
    }
    if (widget.prefillName != null) {
      _nameController.text = widget.prefillName!;
    }
  }

  @override
  void dispose() {
    _upiController.dispose();
    _nameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ── Quick amount chips ─────────────────────────────────────────
  final List<int> _quickAmounts = [100, 500, 1000, 2000, 5000];

  void _setQuickAmount(int amount) {
    _amountController.text = amount.toString();
  }

  // ── Handle send ────────────────────────────────────────────────
  Future<void> _handleSend(UpiProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0;

    final success = await provider.sendMoney(
      receiverUpiId: _upiController.text.trim(),
      receiverName: _nameController.text.trim(),
      amount: amount,
      note: _noteController.text.trim(),
    );

    if (!mounted) return;

    // ── Fire notification on success ──────────────────────────
    if (success) {
      final userId = context.read<AuthProvider>().currentUser?.id ?? '';
      context.read<NotificationProvider>().addNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          title: 'UPI Payment Sent',
          body:
              '₹${amount.toStringAsFixed(2)} sent to ${_nameController.text.trim()} successfully.',
          type: NotificationType.upi,
          createdAt: DateTime.now(),
        ),
      );
    }

    // Show result bottom sheet
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => UpiPaymentStatusWidget(
        isSuccess: success,
        amount: amount,
        receiverName: _nameController.text.trim(),
        transactionId: provider.lastTransactionId,
        onDone: () {
          Navigator.pop(context); // close sheet
          Navigator.pop(context); // go back
          provider.resetStatus();
        },
        onRetry: () {
          Navigator.pop(context);
          provider.resetStatus();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Send Money',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<UpiProvider>(
        builder: (context, provider, _) {
          final isProcessing = provider.status == UpiPaymentStatus.processing;
          final accounts = provider.userAccounts;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── ✅ Account selector (NEW) ───────────────────
                  _buildLabel('Pay From'),
                  const SizedBox(height: 8),
                  _AccountSelector(
                    accounts: accounts,
                    selectedId: provider.selectedAccountId,
                    onChanged: provider.selectAccount,
                  ),

                  const SizedBox(height: 12),

                  // ── Balance info (now shows selected account) ─

                  // ── Balance info ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Available Balance',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        Text(
                          '₹${NumberFormat('#,##,##0.00', 'en_IN').format(provider.accountBalance)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── UPI ID field ────────────────────────────────
                  _buildLabel('UPI ID / Phone Number'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _upiController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'UPI ID is required';
                      }

                      final value = v.trim();

                        // Phone number (10 digits)
                        final phoneRegex = RegExp(r'^\d{10}$');

                        // UPI ID (e.g. name@bank)
                        final upiRegex = RegExp(r'^[a-zA-Z0-9._-]+@[a-zA-Z]+$');

                        if (!phoneRegex.hasMatch(value) && !upiRegex.hasMatch(value)) {
                          return 'Enter a valid UPI ID or phone number';
                        }

                      return null;
                    },
                    decoration: _inputDecoration(
                      hint: 'name@bank or 9876543210',
                      icon: Icons.alternate_email_rounded,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Name field ──────────────────────────────────
                  _buildLabel('Receiver Name'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Name is required';
                      }
                      return null;
                    },
                    decoration: _inputDecoration(
                      hint: 'Enter receiver name',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Amount field ────────────────────────────────
                  _buildLabel('Amount (₹)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Amount is required';
                      final amount = double.tryParse(v) ?? 0;
                      if (amount <= 0) return 'Enter a valid amount';
                      if (amount > provider.accountBalance) {
                        return 'Insufficient balance';
                      }
                      return null;
                    },
                    decoration: _inputDecoration(
                      hint: '0.00',
                      icon: Icons.currency_rupee_rounded,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── Quick amount chips ──────────────────────────
                  Wrap(
                    spacing: 8,
                    children: _quickAmounts.map((amount) {
                      return GestureDetector(
                        onTap: () => _setQuickAmount(amount),
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

                  const SizedBox(height: 16),

                  // ── Note field ──────────────────────────────────
                  _buildLabel('Note (Optional)'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _noteController,
                    textInputAction: TextInputAction.done,
                    maxLength: 50,
                    decoration: _inputDecoration(
                      hint: 'Add a note...',
                      icon: Icons.note_outlined,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Send button ─────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isProcessing
                          ? null
                          : () => _handleSend(provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: AppColors.primaryDark
                            .withValues(alpha: 0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: isProcessing
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.send_rounded, size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'Send Money',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: Color(0xFF555555),
    ),
  );

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) => InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
    prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
    filled: true,
    fillColor: Colors.white,
    counterText: '',
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
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Colors.red, width: 1.5),
    ),
  );
}

// ── ✅ Account selector widget (NEW) ───────────────────────────
class _AccountSelector extends StatelessWidget {
  final List<AccountModel> accounts;
  final String selectedId;
  final ValueChanged<String> onChanged;

  const _AccountSelector({
    required this.accounts,
    required this.selectedId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedId,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey,
          ),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
          items: accounts.map((account) {
            final last4 = account.accountNumber.length >= 4
                ? account.accountNumber.substring(
                    account.accountNumber.length - 4,
                  )
                : account.accountNumber;
            return DropdownMenuItem<String>(
              value: account.id,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_outlined,
                      color: AppColors.primaryDark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          account.accountType,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        Text(
                          '•••• $last4',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '₹${account.availableBalance.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
