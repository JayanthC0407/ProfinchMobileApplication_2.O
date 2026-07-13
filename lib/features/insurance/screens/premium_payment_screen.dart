import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/data/models/transaction_model.dart';
import 'package:provider/provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/Transactions/provider/transaction_provider.dart';
import '../provider/insurance_provider.dart';
import '../../../data/models/insurance_model.dart';
import '../widgets/app_notification.dart';

class PremiumPaymentScreen extends StatefulWidget {
  final InsuranceModel policy;
  const PremiumPaymentScreen({super.key, required this.policy});

  @override
  State<PremiumPaymentScreen> createState() => _PremiumPaymentScreenState();
}

class _PremiumPaymentScreenState extends State<PremiumPaymentScreen> {
  double? _customAmount;

  @override
  Widget build(BuildContext context) {
    final dateFmt  = DateFormat('dd MMM yyyy');
    final moneyFmt = NumberFormat('#,##,##0.00', 'en_IN');
    final moneyFmtShort = NumberFormat('#,##,##0', 'en_IN');

    final account = context.read<AccountProvider>().getAccountById(widget.policy.debitAccountId);
    final payAmount = _customAmount ?? widget.policy.totalPremium;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Premium Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Policy card ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.favorite_border_rounded, color: Colors.red, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(widget.policy.planName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 2),
                      Text('Policy No. ${widget.policy.policyNumber}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ]),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                    child: Text('Active', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green.shade700)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // ── Due info ──────────────────────────────────────
            _infoRow('Next Premium Due', dateFmt.format(widget.policy.nextPremiumDue)),
            const SizedBox(height: 8),
            _infoRow('Amount Due', '₹${moneyFmt.format(widget.policy.totalPremium)}'),

            const SizedBox(height: 20),

            // ── Debit account ─────────────────────────────────
            const Text('Select Debit Account',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
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
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.account_balance_outlined, color: AppColors.primaryDark, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${account.accountType}  XXXX ${account.accountNumber.substring(account.accountNumber.length - 4)}',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                      Text('₹${moneyFmt.format(account.availableBalance)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                    ]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Quick pay options ─────────────────────────────
            const Text('Quick Pay Options',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
            Row(
              children: [
                ...[ widget.policy.totalPremium, widget.policy.totalPremium * 2, widget.policy.totalPremium * 4 ]
                    .map((amt) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _customAmount = amt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: _customAmount == amt ? AppColors.primaryDark : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: _customAmount == amt ? AppColors.primaryDark : Colors.grey.shade300),
                          ),
                          child: Text('₹${moneyFmtShort.format(amt)}',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: _customAmount == amt ? Colors.white : const Color(0xFF1A1A2E),
                            )),
                        ),
                      ),
                    )),
                GestureDetector(
                  onTap: () => setState(() => _customAmount = null),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _customAmount == null ? AppColors.primaryDark : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _customAmount == null ? AppColors.primaryDark : Colors.grey.shade300),
                    ),
                    child: Text('Other',
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: _customAmount == null ? Colors.white : const Color(0xFF1A1A2E),
                      )),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () => _pay(context, payAmount),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Pay ₹${moneyFmt.format(payAmount)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _pay(BuildContext context, double amount) {
    final acctProv  = context.read<AccountProvider>();
    final insProv   = context.read<InsuranceProvider>();

    acctProv.debitAccount(widget.policy.debitAccountId, amount);
    insProv.payPremium(widget.policy.id);

    TransactionProvider.instance.addTransaction(
      accountId:    widget.policy.debitAccountId,
      title:        'Insurance Premium',
      description:  '${widget.policy.planName} premium payment',
      amount:       amount,
      type:         TransactionType.debit,
      category:     TransactionCategory.insurance,
      balanceAfter: acctProv.getAccountById(widget.policy.debitAccountId).availableBalance,
    );

    AppNotification.show(
      context,
      message: 'Premium of ₹${NumberFormat('#,##,##0.00', 'en_IN').format(amount)} paid successfully!',
      type: AppNotificationType.success,
    );
    Navigator.pop(context);
  }

  Widget _infoRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
      ]),
    );
  }
}