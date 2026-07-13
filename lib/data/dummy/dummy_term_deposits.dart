import '../models/term_deposit_model.dart';

class DummyTermDeposits {

  DummyTermDeposits._();

  static final List<TermDepositModel> deposits = [

    TermDepositModel(
      id: 'TD001',
      userId: 'USR001',
      sourceAccountId: 'ACC001',
      principalAmount: 5000,
      interestRate: 7.0,
      tenureMonths: 12,
      startDate: DateTime(2025, 1, 1),
      maturityDate: DateTime(2026, 1, 1),
      maturityAmount: 5350,
      status: 'ACTIVE',
    ),

    TermDepositModel(
      id: 'TD002',
      userId: 'USR002',
      sourceAccountId: 'ACC004',
      principalAmount: 100000,
      interestRate: 7.5,
      tenureMonths: 24,
      startDate: DateTime(2025, 2, 1),
      maturityDate: DateTime(2027, 2, 1),
      maturityAmount: 115000,
      status: 'ACTIVE',
    ),

    TermDepositModel(
      id: 'TD003',
      userId: 'USR003',
      sourceAccountId: 'ACC007',
      principalAmount: 25000,
      interestRate: 6.5,
      tenureMonths: 12,
      startDate: DateTime(2025, 3, 1),
      maturityDate: DateTime(2026, 3, 1),
      maturityAmount: 26625,
      status: 'ACTIVE',
    ),
  ];
}