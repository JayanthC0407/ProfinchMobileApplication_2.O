import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/utils/currency_formatter.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/loan_model.dart';
import '../../accounts/provider/account_provider.dart';
import '../provider/loan_provider.dart';
import '../../Transactions/provider/transaction_provider.dart';

class RepayLoanScreen extends StatefulWidget {
  final LoanModel loan;

  const RepayLoanScreen({super.key, required this.loan});

  @override
  State<RepayLoanScreen> createState() => _RepayLoanScreenState();
}

class _RepayLoanScreenState extends State<RepayLoanScreen> {
  String? selectedAccountId;

  @override
  Widget build(BuildContext context) {
    final accountProvider = Provider.of<AccountProvider>(context);

    final authProvider = Provider.of<AuthProvider>(context);

    final loanProvider = Provider.of<LoanProvider>(context, listen: false);

    final user = authProvider.currentUser!;

    final accounts = accountProvider.getAccountsByUserId(user.id);

    return Scaffold(
      backgroundColor: AppColors.light,

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        title: const Text("Repay EMI"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: AppColors.lightBlue,

                borderRadius: BorderRadius.circular(12),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    widget.loan.loanType,
                    style: TextStyle(
                      fontSize: RT.fs(context, 20),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text("EMI: ${CurrencyFormatter.format(widget.loan.emiAmount, widget.loan.currencyCode)}"),

                  Text(
                    "Outstanding: ${CurrencyFormatter.format(widget.loan.outstandingAmount, widget.loan.currencyCode)}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            DropdownButtonFormField<String>(
              initialValue: selectedAccountId,

              items: accounts.map((account) {
                return DropdownMenuItem(
                  value: account.id,

                  child: Text(
                    "${account.accountType} • ${account.accountNumber.substring(account.accountNumber.length - 4)}",
                  ),
                );
              }).toList(),

              onChanged: (value) {
                setState(() {
                  selectedAccountId = value;
                });
              },
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton(
                onPressed: () {
                  if (selectedAccountId == null) {
                    return;
                  }

                  final selectedAccount = accountProvider.accounts.firstWhere(
                    (account) => account.id == selectedAccountId,
                  );

                  if (selectedAccount.availableBalance <
                      widget.loan.emiAmount) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Insufficient Balance")),
                    );

                    return;
                  }

                  accountProvider.debitAccount(
                    selectedAccountId!,
                    widget.loan.emiAmount,
                  );

                  loanProvider.repayLoan(widget.loan.id, widget.loan.emiAmount);

                  TransactionProvider.instance.recordEmiDeduction(
                    accountId: selectedAccountId!,
                    amount: widget.loan.emiAmount,
                    loanId: widget.loan.id,
                    balanceAfter: accountProvider
                        .getAccountById(selectedAccountId!)
                        .availableBalance,
                  );

                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircleAvatar(
                              radius: 36,
                              backgroundColor: Colors.green,
                              child: Icon(
                                Icons.check,
                                color: AppColors.light,
                                size: 42,
                              ),
                            ),

                            const SizedBox(height: 20),

                            Text(
                              "Payment Successful",
                              style: TextStyle(
                                fontSize: AppFontSize.xl(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "EMI Paid Successfully",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: AppFontSize.body(context)),
                            ),

                            const SizedBox(height: 24),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: AppColors.light,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("OK"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },

                child: const Text("Pay EMI"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
