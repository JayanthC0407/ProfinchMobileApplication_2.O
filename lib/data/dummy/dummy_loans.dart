import '../models/loan_model.dart';

class DummyLoans {

  DummyLoans._();

  static final List<LoanModel> loans = [

    LoanModel(
      id: "LN001",
      userId: "USR001",

      loanType: "Personal Loan",

      principalAmount: 500000,

      interestRate: 10.5,

      tenureMonths: 60,

      emiAmount: 10747,

      outstandingAmount: 425000,

      startDate: DateTime(2025, 1, 10),

      endDate: DateTime(2030, 1, 10),

      repaymentAccountId: "ACC001",

      autoPayEnabled: true,

      autoPayDate: 5,

      status: "ACTIVE",
      currencyCode: "INR",

    ),
  ];
}