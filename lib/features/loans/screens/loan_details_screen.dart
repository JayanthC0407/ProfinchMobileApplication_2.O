import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/utils/currency_formatter.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'package:profinch_mobile_application/features/loans/screens/loan_statement_screen.dart';
import 'package:profinch_mobile_application/features/loans/screens/repay_loan_screen.dart';
import '../../../core/constants/colors.dart';
import '../../../data/models/loan_model.dart';

class LoanDetailsScreen extends StatelessWidget {
  final LoanModel loan;

  const LoanDetailsScreen({super.key, required this.loan});

  Widget detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.light,

      appBar: AppBar(
        backgroundColor: Colors.transparent,

        title: const Text("Loan Details"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Container(
              width: double.infinity,

              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),

                borderRadius: BorderRadius.circular(20),
              ),

              child: Column(
                children: [
                  Text(
                    loan.loanType,

                    style:  TextStyle(
                      color: AppColors.light,
                      fontSize: RT.fs(context, 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    CurrencyFormatter.format(
                        loan.outstandingAmount, loan.currencyCode),

                    style:  TextStyle(
                      color: AppColors.light,
                      fontSize: RT.fs(context, 30),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Outstanding Amount",
                    style: TextStyle(color: AppColors.light.withValues(alpha:0.7)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            detailRow("Loan ID", loan.maskedId),

            detailRow(
              "Principal Amount",
              CurrencyFormatter.format(loan.principalAmount, loan.currencyCode),
            ),

            detailRow("Interest Rate", "${loan.interestRate}%"),

            detailRow("Tenure", "${loan.tenureMonths} Months"),

            detailRow("EMI", CurrencyFormatter.format(loan.emiAmount, loan.currencyCode)),

            detailRow("Status", loan.status),

            const Divider(),

            detailRow("Auto Pay", loan.autoPayEnabled ? "Enabled" : "Disabled"),

            detailRow("Deduction Date", "${loan.autoPayDate}th"),

            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(14),

              decoration: BoxDecoration(
                color: loan.autoPayEnabled
                    ? Colors.green.shade100
                    : Colors.orange.shade100,

                borderRadius: BorderRadius.circular(12),
              ),

              child: Text(
                loan.autoPayEnabled
                    ? "Auto Pay is enabled and cannot be modified after loan activation."
                    : "Auto Pay is disabled.",

                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.payment),

                label: const Text("Repay EMI"),

                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => RepayLoanScreen(loan: loan),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,

              child: ElevatedButton.icon(
                icon: const Icon(Icons.receipt_long),

                label: const Text("View Statements"),

                onPressed: () {
                  Navigator.push(
                    context,

                    MaterialPageRoute(
                      builder: (_) => LoanStatementScreen(loan: loan),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}