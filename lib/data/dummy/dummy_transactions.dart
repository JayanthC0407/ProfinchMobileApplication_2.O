import 'package:profinch_mobile_application/data/models/transaction_model.dart';

class DummyTransactions {
  DummyTransactions._();

  // ── Starter data ────────────────────────────────────────────────
  // Intentionally only 2 entries. This is what a first-time login
  // should show on the Dashboard and in Transaction History — nothing
  // more. Every transaction performed afterwards (UPI, transfer,
  // withdrawal, EMI, loan, term deposit, etc.) is added on top of
  // this through TransactionProvider.instance.addTransaction(...).
  static final List<TransactionModel> allTransactions = [
    TransactionModel(
      id: 'TXN001',
      accountId: 'ACC001',
      title: 'Salary Credit',
      description: 'Monthly salary from ProFinch Solutions',
      amount: 65000.00,
      type: TransactionType.credit,
      category: TransactionCategory.salary,
      date: DateTime(2026, 6, 15, 9, 0),
      referenceNumber: 'REF20260615001',
      balanceAfter: 125450.75,
      receiverName: null,
      receiverAccount: null,
    ),
    TransactionModel(
      id: 'TXN002',
      accountId: 'ACC001',
      title: 'Swiggy - Food Order',
      description: 'Online food delivery',
      amount: 450.00,
      type: TransactionType.debit,
      category: TransactionCategory.food,
      date: DateTime(2026, 6, 16, 13, 30),
      referenceNumber: 'REF20260616002',
      balanceAfter: 125000.75,
      receiverName: 'Swiggy',
      receiverAccount: null,
    ),
    TransactionModel(
    id: 'TXN003',
    accountId: 'ACC001',
    title: 'Carrefour Supermarket',
    description: 'Monthly grocery shopping',
    amount: 1200.00,
    type: TransactionType.debit,
    category: TransactionCategory.shopping,
    date: DateTime(2026, 7, 3, 18, 15),
    referenceNumber: 'REF20260703003',
    balanceAfter: 123800.75,
    receiverName: 'Carrefour',
  ),
  TransactionModel(
    id: 'TXN004',
    accountId: 'ACC001',
    title: 'DEWA Bill Payment',
    description: 'Electricity and water utility utilities',
    amount: 650.00,
    type: TransactionType.debit,
    category: TransactionCategory.billPayment,
    date: DateTime(2026, 7, 4, 10, 0),
    referenceNumber: 'REF20260704004',
    balanceAfter: 123150.75,
    receiverName: 'DEWA',
  ),
  TransactionModel(
    id: 'TXN005',
    accountId: 'ACC001',
    title: 'Zara Mall Transfer',
    description: 'Clothing items shopping',
    amount: 850.00,
    type: TransactionType.debit,
    category: TransactionCategory.shopping,
    date: DateTime(2026, 7, 5, 15, 45),
    referenceNumber: 'REF20260705005',
    balanceAfter: 122300.75,
    receiverName: 'Zara',
  ),
  TransactionModel(
    id: 'TXN006',
    accountId: 'ACC001',
    title: 'Zomato Dining out',
    description: 'Weekend dinner expense',
    amount: 320.00,
    type: TransactionType.debit,
    category: TransactionCategory.food,
    date: DateTime(2026, 7, 5, 21, 0),
    referenceNumber: 'REF20260705006',
    balanceAfter: 121980.75,
    receiverName: 'Zomato',
  ),
  TransactionModel(
    id: 'TXN007',
    accountId: 'ACC001',
    title: 'UPI Received',
    description: 'Received from friend for dinner split',
    amount: 160.00,
    type: TransactionType.credit,
    category: TransactionCategory.upi,
    date: DateTime(2026, 7, 6, 11, 20),
    referenceNumber: 'REF20260706007',
    balanceAfter: 122140.75,
    receiverName: 'Arjun Sharma',
  ),
  TransactionModel(
    id: 'TXN008',
    accountId: 'ACC001',
    title: 'Amazon Online Order',
    description: 'Electronics accessory purchase',
    amount: 110.00,
    type: TransactionType.debit,
    category: TransactionCategory.shopping,
    date: DateTime(2026, 7, 6, 14, 10),
    referenceNumber: 'REF20260706008',
    balanceAfter: 122030.75,
    receiverName: 'Amazon UAE',
  ),
  ];

  // ── Helpers ────────────────────────────────────────────────────

  /// Get transactions for a specific account
  static List<TransactionModel> forAccount(String accountId) {
    return allTransactions
        .where((t) => t.accountId == accountId)
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Get recent N transactions
  static List<TransactionModel> recent({int count = 5}) {
    final sorted = List<TransactionModel>.from(allTransactions)
      ..sort((a, b) => b.date.compareTo(a.date));
    return sorted.take(count).toList();
  }

  /// Get total spending this month (debits)
  static double totalSpentThisMonth() {
    final now = DateTime.now();
    return allTransactions
        .where((t) =>
            t.type == TransactionType.debit &&
            t.date.month == now.month &&
            t.date.year == now.year)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get spending grouped by category for chart
  static Map<TransactionCategory, double> spendingByCategory() {
    final Map<TransactionCategory, double> result = {};
    for (final t in allTransactions.where(
        (t) => t.type == TransactionType.debit)) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }
}