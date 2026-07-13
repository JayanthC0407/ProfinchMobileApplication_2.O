import 'package:flutter/material.dart';
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
                      "₹${statement.emiAmount.toStringAsFixed(2)}",
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
                                  "EMI : ₹${statement.emiAmount}",
                                ),

                                Text(
                                  "Principal : ₹${statement.principalComponent.toStringAsFixed(2)}",
                                ),

                                Text(
                                  "Interest : ₹${statement.interestComponent.toStringAsFixed(2)}",
                                ),

                                Text(
                                  "Outstanding : ₹${statement.remainingOutstanding.toStringAsFixed(2)}",
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