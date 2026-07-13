import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/beneficiary_model.dart';
import '../../../data/models/transfer_model.dart';
import '../../accounts/provider/account_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/transfer_provider.dart';
import '../../Transactions/provider/transaction_provider.dart';
import 'transfer_success_screen.dart';

import 'package:profinch_mobile_application/features/notifications/provider/notification_provider.dart';
import 'package:profinch_mobile_application/data/models/notification_model.dart';
class TransferConfirmationScreen extends StatelessWidget {
  final BeneficiaryModel beneficiary;
  final String accountId;
  final double amount;
  final String remarks;
  final String transferMode;

  const TransferConfirmationScreen({
    super.key,
    required this.beneficiary,
    required this.accountId,
    required this.amount,
    required this.remarks,
    required this.transferMode,
  });

  Color get _modeColor {
    switch (transferMode) {
      case 'INTERNATIONAL': return const Color(0xFFB45309);
      case 'LOCAL':
      case 'IMPS':
      case 'NEFT':
      case 'RTGS': return const Color(0xFF0D9488);
      default: return const Color(0xFF2563B0);
    }
  }

  Widget _row(String label, String value, {bool bold = false, Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: valueColor ?? const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final account = accountProvider.getAccountById(accountId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // Header
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A3A6B), Color(0xFF2563B0)],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        const Text(
                          "Confirm Transfer",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "₹${amount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "to ${beneficiary.nickname}",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Details card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _row("From Account", "••••  ${account.accountNumber.substring(account.accountNumber.length - 4)}"),
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        _row("To", beneficiary.nickname),
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        _row("Transfer Mode", transferMode, valueColor: _modeColor),
                        const Divider(height: 1, color: Color(0xFFF3F4F6)),
                        _row(
                          "Amount",
                          "₹${amount.toStringAsFixed(2)}",
                          bold: true,
                          valueColor: const Color(0xFF111827),
                        ),
                        if (remarks.isNotEmpty) ...[
                          const Divider(height: 1, color: Color(0xFFF3F4F6)),
                          _row("Remarks", remarks),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lock_outline,
                            size: 14, color: Colors.amber.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Please verify all details before confirming. This action cannot be undone.",
                            style: TextStyle(
                                fontSize: 11, color: Colors.amber.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563B0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () {
                        if (account.availableBalance < amount) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Insufficient Balance")),
                          );
                          return;
                        }
                        accountProvider.debitAccount(accountId, amount);
                        Provider.of<TransferProvider>(context, listen: false)
                            .addTransfer(TransferModel(
                          id: DateTime.now()
                              .millisecondsSinceEpoch
                              .toString(),
                          userId: authProvider.currentUser!.id,
                          fromAccountId: accountId,
                          beneficiaryId: beneficiary.id,
                          beneficiaryName: beneficiary.nickname,
                          beneficiaryType: beneficiary.beneficiaryType,
                          amount: amount,
                          remarks: remarks,
                          transferMode: transferMode,
                          status: "SUCCESS",
                          transferDate: DateTime.now(),
                        ));
                        TransactionProvider.instance.recordAccountTransfer(
                          accountId: accountId,
                          amount: amount,
                          receiverName: beneficiary.nickname,
                          receiverAccount: beneficiary.accountNumber,
                          balanceAfter: accountProvider
                              .getAccountById(accountId)
                              .availableBalance,
                        );

                        // ── Fire notification ──────────────────────────────────
                        final userId = authProvider.currentUser?.id ?? '';
                        context.read<NotificationProvider>().addNotification(
                          NotificationModel(
                            id: DateTime.now().millisecondsSinceEpoch.toString(),
                            userId: userId,
                            title: 'Transfer Successful',
                            body: '₹${amount.toStringAsFixed(2)} transferred to ${beneficiary.nickname} via $transferMode.',
                            type: NotificationType.transaction,
                            createdAt: DateTime.now(),
                          ),
                        );
                        
                       Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TransferSuccessScreen(
                              beneficiaryName: beneficiary.nickname,
                              amount: amount,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        "Confirm & Transfer",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text("Go Back",
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 13)),
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