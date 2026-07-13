import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/data/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/Transactions/provider/transaction_provider.dart';
import '../provider/insurance_provider.dart';
import '../../../data/models/insurance_model.dart';
import '../widgets/insurance_step_indicator.dart';
import 'purchase_success_screen.dart';

class BuyInsurancePaymentScreen extends StatelessWidget {
  final InsuranceTypeConfig typeConfig;
  final InsurancePlanConfig planConfig;
  final String holderName;
  final String holderDob;
  final String debitAccountId;
  final String nomineeName;
  final String nomineeRelationship;
  final String nomineeDoB;
  final String nomineeMobile;

  const BuyInsurancePaymentScreen({
    super.key,
    required this.typeConfig,
    required this.planConfig,
    required this.holderName,
    required this.holderDob,
    required this.debitAccountId,
    required this.nomineeName,
    required this.nomineeRelationship,
    required this.nomineeDoB,
    required this.nomineeMobile,
  });

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,##,##0.00', 'en_IN');
    final gst = planConfig.premiumAmount * 0.18;
    final total = planConfig.premiumAmount + gst;

    final account = context.read<AccountProvider>().getAccountById(debitAccountId);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Buy ${typeConfig.name}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: InsuranceStepIndicator(current: 3),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Payment Summary',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 16),

            // ── Summary card ─────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Column(
                children: [
                  _summaryRow('Plan',              planConfig.name,                          false),
                  _divider(),
                  _summaryRow('Coverage Amount',   '₹${moneyFmt.format(planConfig.coverageAmount)}', false),
                  _divider(),
                  _summaryRow('Premium (Monthly)', '₹${moneyFmt.format(planConfig.premiumAmount)}',   false),
                  _divider(),
                  _summaryRow('GST (18%)',         '₹${moneyFmt.format(gst)}',               false),
                  _divider(),
                  _summaryRow('Total Amount',      '₹${moneyFmt.format(total)}',             true),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text('Debit Account',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),

            // ── Debit account card ────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.account_balance_outlined, color: AppColors.primaryDark, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${account.accountType}  XXXX ${account.accountNumber.substring(account.accountNumber.length - 4)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () => _processPayment(context, total),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Pay ₹${moneyFmt.format(total)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _processPayment(BuildContext context, double total) {
    final user      = context.read<AuthProvider>().currentUser!;
    final acctProv  = context.read<AccountProvider>();
    final insProv   = context.read<InsuranceProvider>();

    acctProv.debitAccount(debitAccountId, total);

    final policy = insProv.addPolicy(
      userId:               user.id,
      type:                 typeConfig.type,
      planConfig:           planConfig,
      policyHolderName:     holderName,
      policyHolderDob:      holderDob,
      nomineeName:          nomineeName,
      nomineeRelationship:  nomineeRelationship,
      nomineeDoB:           nomineeDoB,
      nomineeMobile:        nomineeMobile,
      debitAccountId:       debitAccountId,
      typeConfig_name:      typeConfig.name,
      benefits:             typeConfig.benefits,
    );

    TransactionProvider.instance.addTransaction(
      accountId:    debitAccountId,
      title:        'Insurance Premium',
      description:  '${typeConfig.name} - ${planConfig.name}',
      amount:       total,
      type:         TransactionType.debit,
      category:     TransactionCategory.insurance,
      balanceAfter: acctProv.getAccountById(debitAccountId).availableBalance,
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => PurchaseSuccessScreen(policy: policy)),
      (route) => route.isFirst,
    );
  }

  Widget _summaryRow(String label, String value, bool isBold) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(
          fontSize: 13,
          color: isBold ? const Color(0xFF1A1A2E) : Colors.grey.shade500,
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w400)),
      Text(value, style: TextStyle(
          fontSize: 13,
          color: const Color(0xFF1A1A2E),
          fontWeight: isBold ? FontWeight.w700 : FontWeight.w600)),
    ]),
  );

  Widget _divider() => Divider(height: 1, color: Colors.grey.shade100);
}