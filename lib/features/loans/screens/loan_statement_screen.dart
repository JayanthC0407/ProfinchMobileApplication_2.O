import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/utils/currency_formatter.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/loan_model.dart';
import '../provider/loan_provider.dart';

class LoanStatementScreen
    extends StatelessWidget {

  final LoanModel loan;

  const LoanStatementScreen({
    super.key,
    required this.loan,
  });

  @override
  Widget build(BuildContext context) {

    final statements =
        Provider.of<LoanProvider>(
      context,
    ).getStatementsByLoan(
      loan.id,
    );

    return Scaffold(
      backgroundColor:
          AppColors.light,

      appBar: AppBar(
        backgroundColor:
            Colors.transparent,

        title:
            const Text(
          "Loan Statements",
        ),
      ),

      body: statements.isEmpty

          ? const Center(
              child: Text(
                "No EMI Payments Yet",
              ),
            )

          : ListView.builder(
              itemCount:
                  statements.length,

              itemBuilder:
                  (context, index) {

                final statement =
                    statements[index];

                return Card(
                  margin:
                      const EdgeInsets.all(
                    12,
                  ),

                  color:
                      AppColors.lightBlue,

                  child: ListTile(
                    leading:
                        const CircleAvatar(
                      child: Icon(
                        Icons.receipt_long,
                      ),
                    ),

                    title: Text(
                     CurrencyFormatter.format(
                          statement.emiAmount, loan.currencyCode),
                    ),

                    subtitle: Text(
                      statement
                          .paymentDate
                          .toString()
                          .split(" ")
                          .first,
                    ),

                    trailing: Text(
                      statement.status,
                    ),

                    onTap: () {

                      showDialog(
                        context:
                            context,

                        builder:
                            (_) {

                          return AlertDialog(
                            title: const Text(
                              "EMI Details",
                            ),

                            content:
                                Column(
                              mainAxisSize:
                                  MainAxisSize.min,

                              children: [

                                Text(
                                  "EMI : ${CurrencyFormatter.format(statement.emiAmount, loan.currencyCode)}",
                                ),

                                Text(
                                  "Principal : ${CurrencyFormatter.format(statement.principalComponent, loan.currencyCode)}",
                                ),

                                Text(
                                  "Interest : ${CurrencyFormatter.format(statement.interestComponent, loan.currencyCode)}",
                                ),

                                Text(
                                  "Outstanding : ${CurrencyFormatter.format(statement.remainingOutstanding, loan.currencyCode)}",
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}