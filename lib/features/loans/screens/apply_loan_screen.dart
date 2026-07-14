import 'dart:math';

import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/colors.dart';
import '../../../data/models/loan_model.dart';
import '../../accounts/provider/account_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/loan_provider.dart';
import '../../Transactions/provider/transaction_provider.dart';

class ApplyLoanScreen extends StatefulWidget {
  const ApplyLoanScreen({super.key});

  @override
  State<ApplyLoanScreen> createState() => _ApplyLoanScreenState();
}

class _ApplyLoanScreenState extends State<ApplyLoanScreen> {
  final _formKey = GlobalKey<FormState>();

  final amountController = TextEditingController();

  final tenureController = TextEditingController();

  String loanType = "Personal Loan";

  String? selectedAccountId;

  bool autoPayEnabled = false;

  int autoPayDate = 5;

  double emiAmount = 0;

  void calculateEmi() {
    if (amountController.text.isEmpty || tenureController.text.isEmpty) {
      return;
    }

    final principal = double.parse(amountController.text);

    final tenure = int.parse(tenureController.text);

    const annualRate = 10.5;

    final monthlyRate = annualRate / 12 / 100;

    final emi =
        principal *
        monthlyRate *
        (pow(1 + monthlyRate, tenure) / (pow(1 + monthlyRate, tenure) - 1));

    setState(() {
      emiAmount = emi;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final accountProvider = Provider.of<AccountProvider>(
      context,
      listen: false,
    );

    final loanProvider = Provider.of<LoanProvider>(context, listen: false);

    final user = authProvider.currentUser!;

    final accounts = accountProvider.getAccountsByUserId(user.id);

    return Scaffold(
      backgroundColor: AppColors.light,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text("Apply Loan"),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Form(
          key: _formKey,

          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: loanType,

                decoration: const InputDecoration(labelText: "Loan Type"),

                items: const [
                  DropdownMenuItem(
                    value: "Personal Loan",
                    child: Text("Personal Loan"),
                  ),

                  DropdownMenuItem(
                    value: "Home Loan",
                    child: Text("Home Loan"),
                  ),

                  DropdownMenuItem(
                    value: "Vehicle Loan",
                    child: Text("Vehicle Loan"),
                  ),

                  DropdownMenuItem(
                    value: "Education Loan",
                    child: Text("Education Loan"),
                  ),

                  DropdownMenuItem(
                    value: "Business Loan",
                    child: Text("Business Loan"),
                  ),
                ],

                onChanged: (value) {
                  setState(() {
                    loanType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: amountController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(labelText: "Loan Amount"),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Loan Amount";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: tenureController,

                keyboardType: TextInputType.number,

                decoration: const InputDecoration(labelText: "Tenure (Months)"),

                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Enter Tenure";
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                initialValue: selectedAccountId,

                decoration: const InputDecoration(
                  labelText: "Repayment Account",
                ),

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

              const SizedBox(height: 16),

              SwitchListTile(
                title: const Text("Enable Auto Pay"),

                value: autoPayEnabled,

                onChanged: (value) {
                  setState(() {
                    autoPayEnabled = value;
                  });
                },
              ),

              if (autoPayEnabled)
                DropdownButtonFormField<int>(
                  initialValue: autoPayDate,

                  decoration: const InputDecoration(labelText: "Auto Pay Date"),

                  items: [1, 5, 10, 15, 20, 25].map((date) {
                    return DropdownMenuItem(
                      value: date,

                      child: Text("$date th"),
                    );
                  }).toList(),

                  onChanged: (value) {
                    setState(() {
                      autoPayDate = value!;
                    });
                  },
                ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: calculateEmi,

                  child: const Text("Calculate EMI"),
                ),
              ),

              const SizedBox(height: 20),

              if (emiAmount > 0)
                Container(
                  width: double.infinity,

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Column(
                    children: [
                       Text("Monthly EMI", style: TextStyle(fontSize: AppFontSize.medium(context)),),

                      const SizedBox(height: 8),

                      Text(
                        "₹${emiAmount.toStringAsFixed(2)}",

                        style:  TextStyle(
                          fontSize: RT.fs(context, 26),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,

                child: ElevatedButton(
                  onPressed: () {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    if (selectedAccountId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Select Repayment Account"),
                        ),
                      );

                      return;
                    }

                    final amount = double.parse(amountController.text);

                    final tenure = int.parse(tenureController.text);

                    accountProvider.creditAccount(selectedAccountId!, amount);

                    final loanId = DateTime.now().millisecondsSinceEpoch.toString();

                    loanProvider.addLoan(
                      LoanModel(
                        id: loanId,

                        userId: user.id,

                        loanType: loanType,

                        principalAmount: amount,

                        outstandingAmount: amount,

                        interestRate: 10.5,

                        tenureMonths: tenure,

                        emiAmount: emiAmount,

                        startDate: DateTime.now(),

                        endDate: DateTime.now().add(
                          Duration(days: tenure * 30),
                        ),

                        repaymentAccountId: selectedAccountId!,

                        autoPayEnabled: autoPayEnabled,

                        autoPayDate: autoPayDate,

                        status: "ACTIVE", 
                        
                        currencyCode: '',
                      ),
                    );

                    TransactionProvider.instance.recordLoanReimbursement(
                      accountId: selectedAccountId!,
                      amount: amount,
                      loanId: loanId,
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
                                "Success",
                                style: TextStyle(
                                  fontSize: AppFontSize.xl(context),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 10),

                              Text(
                                "Loan Applied Successfully",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: AppFontSize.medium(context)),
                              ),

                              const SizedBox(height: 24),

                              SizedBox(
                                width: double.infinity,

                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.blueButton,

                                    foregroundColor: AppColors.light,

                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),

                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),

                                  onPressed: () {
                                    Navigator.pop(context);

                                    Navigator.pop(context);
                                  },

                                  child: const Text("Done"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },

                  child: const Text("Apply Loan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}