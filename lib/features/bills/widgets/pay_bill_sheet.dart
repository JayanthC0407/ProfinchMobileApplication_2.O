import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';
import '../provider/bills_provider.dart';

import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';

class PayBillSheet extends StatefulWidget {
  final BillerModel biller;
  final List<AccountModel> accounts;

  const PayBillSheet({
    super.key,
    required this.biller,
    required this.accounts,
  });

  @override
  State<PayBillSheet> createState() => _PayBillSheetState();
}

class _PayBillSheetState extends State<PayBillSheet> {
  AccountModel? _selectedAccount;
  bool _isLoading = false;
  bool _success = false;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    if (widget.accounts.isNotEmpty) {
      _selectedAccount = widget.accounts.first;
    }
  }

  Future<void> _handlePay(BuildContext context) async {
    if (_selectedAccount == null) return;
    setState(() => _isLoading = true);

    final success = await context.read<BillsProvider>().payBill(
          billerId: widget.biller.id,
          accountId: _selectedAccount!.id,
        );

    // ── Fire notification on success ──────────────────────────
    if (success && context.mounted) {
      final userId = context.read<AuthProvider>().currentUser?.id ?? '';
      context.read<NotificationProvider>().addNotification(
        NotificationModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          title: 'Bill Paid Successfully',
          body: '₹${widget.biller.dueAmount.toStringAsFixed(2)} paid for ${widget.biller.nickname} (${widget.biller.providerName}).',
          type: NotificationType.transaction,
          createdAt: DateTime.now(),
        ),
      );
    }

    setState(() {
      _isLoading = false;
      _success = success;
      _failed = !success;
    });
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: _success || _failed
          ? _buildResult(formatter)
          : _buildForm(context, formatter),
    );
  }

  Widget _buildResult(NumberFormat formatter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: _success ? Colors.green.shade50 : Colors.red.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _success ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: _success ? Colors.green.shade600 : Colors.red.shade600,
            size: 40,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          _success ? 'Bill Paid Successfully!' : 'Payment Failed',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _success ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '₹${formatter.format(widget.biller.dueAmount)} paid for ${widget.biller.nickname}',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Done',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildForm(BuildContext context, NumberFormat formatter) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: widget.biller.category.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(widget.biller.category.icon,
                  color: widget.biller.category.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.biller.nickname,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                  Text(
                      '${widget.biller.providerName} • ${widget.biller.consumerNumber}',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade500)),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Amount Due',
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              Text(
                '₹${formatter.format(widget.biller.dueAmount)}',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E)),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        const Text('Pay From',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade50,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<AccountModel>(
              value: _selectedAccount,
              isExpanded: true,
              onChanged: (val) => setState(() => _selectedAccount = val),
              items: widget.accounts.map((acc) {
                return DropdownMenuItem(
                  value: acc,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${acc.accountType} ••${acc.accountNumber.replaceAll(' ', '').substring(acc.accountNumber.replaceAll(' ', '').length - 4)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        '₹${acc.availableBalance.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _handlePay(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white))
                : Text('Pay ₹${formatter.format(widget.biller.dueAmount)}',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600)),
          ),
        ),

        const SizedBox(height: 8),
      ],
    );
  }
}