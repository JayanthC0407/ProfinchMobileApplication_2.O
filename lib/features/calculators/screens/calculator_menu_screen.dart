import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';

import '../widgets/calculator_card.dart';

class CalculatorMenuScreen extends StatelessWidget {
  const CalculatorMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: AppColors.light,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                size: 22,
                color: Color(0xFF1565C0),
              ),
              onPressed: () => Navigator.pop(context),
              padding: EdgeInsets.zero,
            ),
          
        
        title: Padding(
          padding: EdgeInsets.only(left: 8),
          child: Text(
            "Financial Calculators",
            style: TextStyle(
              fontSize: AppFontSize.large(context),
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B3E),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // Header banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0D47A1).withValues(alpha: 0.30),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Smart Tools",
                        style: TextStyle(
                          color: AppColors.light.withValues(alpha: 0.7),
                          fontSize: AppFontSize.small(context),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.8,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Plan your finances\nwith precision",
                        style: TextStyle(
                          color: AppColors.light,
                          fontSize: AppFontSize.large(context),
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.light.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.calculate_rounded,
                    color: AppColors.light,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Padding(
            padding: EdgeInsets.only(left: 2, bottom: 14),
            child: Text(
              "All Calculators",
              style: TextStyle(
                fontSize: AppFontSize.body(context),
                fontWeight: FontWeight.w600,
                color: Color(0xFF7A8BAD),
                letterSpacing: 0.6,
              ),
            ),
          ),

          CalculatorCard(
            title: "EMI Calculator",
            subtitle: "Calculate your monthly instalments",
            icon: Icons.calculate_rounded,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.emiCalculator);
            },
          ),

          CalculatorCard(
            title: "Loan Eligibility",
            subtitle: "Check your eligible loan amount",
            icon: Icons.account_balance_rounded,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.loanEligibility);
            },
          ),

          CalculatorCard(
            title: "Term Deposit",
            subtitle: "Calculate your maturity amount",
            icon: Icons.savings_rounded,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.tdCalculator);
            },
          ),

          CalculatorCard(
            title: "Currency Converter",
            subtitle: "Convert currencies instantly",
            icon: Icons.currency_exchange_rounded,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.currencyConverter);
            },
          ),

          CalculatorCard(
            title: "SIP Calculator",
            subtitle: "Estimate your future wealth",
            icon: Icons.trending_up_rounded,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.sipCalculator);
            },
          ),
        ],
      ),
    );
  }
}