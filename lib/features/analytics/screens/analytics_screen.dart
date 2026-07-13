import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'package:profinch_mobile_application/features/analytics/utils/analytics_helper.dart';
import '../../Transactions/provider/transaction_provider.dart';
import '../widgets/analytics_summary_card.dart';
import '../widgets/spending_pie_chart.dart';
import '../widgets/comparative_analysis_card.dart';

enum AnalyticsPeriod { month, threeMonths, year }

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  AnalyticsPeriod _selectedPeriod = AnalyticsPeriod.month;

  String get _periodLabel {
    switch (_selectedPeriod) {
      case AnalyticsPeriod.month:
        return 'This Month';
      case AnalyticsPeriod.threeMonths:
        return 'Last 3 Months';
      case AnalyticsPeriod.year:
        return 'This Year';
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactions = TransactionProvider.instance.allTransactionsSorted;

    final filtered = AnalyticsHelper.filterByPeriod(
      transactions,
      _selectedPeriod,
    );
    final totalSpent = AnalyticsHelper.totalSpent(filtered);
    final totalIncome = AnalyticsHelper.totalIncome(filtered);
    final groupedData = AnalyticsHelper.spendingByCategory(filtered);
    final chartData = AnalyticsHelper.comparativeData(
      transactions,
      _selectedPeriod,
    );
    final insight = AnalyticsHelper.generateInsight(
      transactions,
      _selectedPeriod,
      groupedData,
      totalSpent,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Gradient header ──────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.blueButton],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppColors.light,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Text(
                      'Insights & Analytics',
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: RT.fs(context, 26),
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      'Track your spending patterns',
                      style: AppTextStyles.whiteBody(
                        context,
                        color: AppColors.light.withValues(alpha: 0.65),
                      ),
                    ),
                  ),
                  // Period toggle chips
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Row(
                      children: AnalyticsPeriod.values.map((period) {
                        final isSelected = _selectedPeriod == period;
                        final label = period == AnalyticsPeriod.month
                            ? 'This Month'
                            : period == AnalyticsPeriod.threeMonths
                            ? '3 Months'
                            : 'This Year';
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _selectedPeriod = period),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.light
                                    : AppColors.light.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.light
                                      : AppColors.light.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(
                                  fontSize: RT.fs(context, 13),
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? AppColors.blueButton
                                      : AppColors.light,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable body ──────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary card
                  AnalyticsSummaryCard(
                    totalAmount: totalSpent,
                    totalIncome: totalIncome,
                    totalExpense: totalSpent,
                    period: _periodLabel,
                  ),

                  const SizedBox(height: 16),

                  // Pie chart
                  SpendingPieChart(data: groupedData),

                  const SizedBox(height: 16),

                  // Comparative analysis
                  ComparativeAnalysisCard(
                    chartData: chartData,
                    period: _selectedPeriod,
                    insight: insight,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}