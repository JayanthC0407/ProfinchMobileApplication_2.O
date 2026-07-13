import '../../../data/models/transaction_model.dart';
import '../../../features/analytics/screens/analytics_screen.dart';
import 'package:intl/intl.dart';

class AnalyticsHelper {
  AnalyticsHelper._();

  static const _monthNames = [
    '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  // filter
  static List<TransactionModel> filterByPeriod(
    List<TransactionModel> transactions,
    AnalyticsPeriod period,
  ) {
    final now = DateTime.now();
    return transactions.where((t) {
      switch (period) {
        case AnalyticsPeriod.month:
          return t.date.month == now.month && t.date.year == now.year;
        case AnalyticsPeriod.threeMonths:
          final start = DateTime(now.year, now.month - 2, 1);
          return !t.date.isBefore(start);
        case AnalyticsPeriod.year:
          return t.date.year == now.year;
      }
    }).toList();
  }

  // totals
  static double totalSpent(List<TransactionModel> transactions) =>
      transactions
          .where((t) => t.type == TransactionType.debit)
          .fold(0.0, (sum, t) => sum + t.amount);

  static double totalIncome(List<TransactionModel> transactions) =>
      transactions
          .where((t) => t.type == TransactionType.credit)
          .fold(0.0, (sum, t) => sum + t.amount);

  // categories
  static Map<String, double> spendingByCategory(
    List<TransactionModel> transactions,
  ) {
    final Map<String, double> result = {};
    for (final t
        in transactions.where((t) => t.type == TransactionType.debit)) {
      final label = _categoryLabel(t.category);
      result[label] = (result[label] ?? 0) + t.amount;
    }
    return result;
  }

  // comparative chart
  static Map<String, List<double>> comparativeData(
    List<TransactionModel> all,
    AnalyticsPeriod period,
  ) {
    final now = DateTime.now();
    final result = <String, List<double>>{};

    switch (period) {
      case AnalyticsPeriod.month:
        // category breakdown
        final lastMonth = DateTime(now.year, now.month - 1);
        final thisMonthTx = all.where((t) =>
            t.type == TransactionType.debit &&
            t.date.year == now.year &&
            t.date.month == now.month);
        final lastMonthTx = all.where((t) =>
            t.type == TransactionType.debit &&
            t.date.year == lastMonth.year &&
            t.date.month == lastMonth.month);

        final Map<String, double> thisCats = {};
        final Map<String, double> lastCats = {};
        for (final t in thisMonthTx) {
          final l = _categoryLabel(t.category);
          thisCats[l] = (thisCats[l] ?? 0) + t.amount;
        }
        for (final t in lastMonthTx) {
          final l = _categoryLabel(t.category);
          lastCats[l] = (lastCats[l] ?? 0) + t.amount;
        }

        final allCats = {...thisCats.keys, ...lastCats.keys};
        for (final cat in allCats) {
          result[cat] = [thisCats[cat] ?? 0, lastCats[cat] ?? 0];
        }
        break;

      case AnalyticsPeriod.threeMonths:
        for (int i = 2; i >= 0; i--) {
          final m = DateTime(now.year, now.month - i);
          final total = _monthTotal(all, m.year, m.month);
          result[_monthNames[m.month]] = [total, 0];
        }
        break;

      case AnalyticsPeriod.year:
        for (int m = 1; m <= 12; m++) {
          final total = _monthTotal(all, now.year, m);
          result[_monthNames[m]] = [total, 0];
        }
        break;
    }

    return result;
  }

  // insight
  static String generateInsight(
    List<TransactionModel> all,
    AnalyticsPeriod period,
    Map<String, double> groupedData,
    double totalSpent,
  ) {
    final fmt = NumberFormat('#,##,##0', 'en_IN');
    final now = DateTime.now();

    switch (period) {
      case AnalyticsPeriod.month:
        final lastMonth = DateTime(now.year, now.month - 1);
        final lastTotal = _monthTotal(all, lastMonth.year, lastMonth.month);

        if (lastTotal == 0) return 'No data from last month to compare.';

        final diff = totalSpent - lastTotal;
        final pct = (diff.abs() / lastTotal * 100).round();

        // biggest category change
        final lastCats = <String, double>{};
        for (final t in all.where((t) =>
            t.type == TransactionType.debit &&
            t.date.year == lastMonth.year &&
            t.date.month == lastMonth.month)) {
          final l = _categoryLabel(t.category);
          lastCats[l] = (lastCats[l] ?? 0) + t.amount;
        }

        String biggestChange = '';
        double biggestDiff = 0;
        for (final cat in groupedData.keys) {
          final d = (groupedData[cat]! - (lastCats[cat] ?? 0)).abs();
          if (d > biggestDiff) {
            biggestDiff = d;
            final change = groupedData[cat]! > (lastCats[cat] ?? 0)
                ? 'up'
                : 'down';
            biggestChange =
                '$cat is $change ₹${fmt.format(d)} vs last month.';
          }
        }

        if (diff > 0) {
          return 'Spending is $pct% higher than last month '
              '(₹${fmt.format(totalSpent)} vs ₹${fmt.format(lastTotal)}). '
              '$biggestChange';
        } else if (diff < 0) {
          return 'Spending is $pct% lower than last month '
              '(₹${fmt.format(totalSpent)} vs ₹${fmt.format(lastTotal)}). '
              '$biggestChange';
        }
        return 'Spending is on par with last month '
            '(₹${fmt.format(totalSpent)}).';

      case AnalyticsPeriod.threeMonths:
        final months = [
          _monthTotal(all, now.year, now.month),
          _monthTotal(all, now.year, now.month - 1),
          _monthTotal(all, now.year, now.month - 2),
        ];
        final avg = months.fold(0.0, (s, v) => s + v) / 3;
        final highest = months.reduce((a, b) => a > b ? a : b);
        final highestIdx = months.indexOf(highest);
        final highestMonth =
            _monthNames[DateTime(now.year, now.month - highestIdx).month];

        return 'Average monthly spend over 3 months: ₹${fmt.format(avg)}. '
            '$highestMonth was the highest at ₹${fmt.format(highest)}.';

      case AnalyticsPeriod.year:
        final monthTotals = List.generate(
            12, (i) => _monthTotal(all, now.year, i + 1));
        final nonZero = monthTotals.where((v) => v > 0).toList();
        if (nonZero.isEmpty) return 'No spending data for this year yet.';

        final avg = nonZero.fold(0.0, (s, v) => s + v) / nonZero.length;
        final highest = nonZero.reduce((a, b) => a > b ? a : b);
        final highestIdx = monthTotals.indexOf(highest);
        final highestMonth = _monthNames[highestIdx + 1];

        return 'Average monthly spend this year: ₹${fmt.format(avg)}. '
            '$highestMonth was the highest at ₹${fmt.format(highest)}.';
    }
  }

  // helpers
  static double _monthTotal(
      List<TransactionModel> transactions, int year, int month) {
    return transactions
        .where((t) =>
            t.type == TransactionType.debit &&
            t.date.year == year &&
            t.date.month == month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  static String _categoryLabel(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.food:
        return 'Food';
      case TransactionCategory.shopping:
        return 'Shopping';
      case TransactionCategory.billPayment:
      case TransactionCategory.recharge:
        return 'Bills';
      case TransactionCategory.insurance:
        return 'Insurance';
      case TransactionCategory.transfer:
      case TransactionCategory.upi:
      case TransactionCategory.wallet:
        return 'Transfers';
      case TransactionCategory.emi:
      case TransactionCategory.loan:
        return 'Loans & EMI';
      case TransactionCategory.atm:
        return 'Cash';
      case TransactionCategory.termDeposit:
        return 'Savings';
      case TransactionCategory.salary:
      case TransactionCategory.refund:
        return 'Income';
    }
  }
}