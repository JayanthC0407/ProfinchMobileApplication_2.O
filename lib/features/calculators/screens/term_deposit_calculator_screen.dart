import 'dart:math';

import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';

class TermDepositCalculatorScreen extends StatefulWidget {
  const TermDepositCalculatorScreen({super.key});

  @override
  State<TermDepositCalculatorScreen> createState() =>
      _TermDepositCalculatorScreenState();
}

class _TermDepositCalculatorScreenState
    extends State<TermDepositCalculatorScreen> {
  final amountController = TextEditingController();

  final rateController = TextEditingController();

  final tenureController = TextEditingController();

  double maturityAmount = 0;

  double interestEarned = 0;

  bool _hasResult = false;

  void calculate() {
    if (amountController.text.isEmpty ||
        rateController.text.isEmpty ||
        tenureController.text.isEmpty) {
      return;
    }

    final principal = double.parse(amountController.text);

    final annualRate = double.parse(rateController.text);

    final months = int.parse(tenureController.text);

    final years = months / 12;

    final maturity = principal * pow((1 + annualRate / 100), years);

    setState(() {
      maturityAmount = maturity.toDouble();

      interestEarned = maturityAmount - principal;

      _hasResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      body: Column(
        children: [
          _CalcHeader(
            title: "Term Deposit",

            subtitle: "Calculate your FD maturity amount",

            icon: Icons.savings_outlined,

            iconBg: const Color(0xFFCCFBF1),

            iconColor: const Color(0xFF0D9488),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [
                  _InputCard(
                    children: [
                      _InputField(
                        controller: amountController,

                        label: "DEPOSIT AMOUNT",

                        hint: "e.g. 100000",

                        icon: Icons.currency_rupee,

                        suffix: "₹",
                      ),

                      const SizedBox(height: 16),

                      _InputField(
                        controller: rateController,

                        label: "INTEREST RATE",

                        hint: "e.g. 7.5",

                        icon: Icons.percent,

                        suffix: "% p.a.",
                      ),

                      const SizedBox(height: 16),

                      _InputField(
                        controller: tenureController,

                        label: "TENURE",

                        hint: "e.g. 12",

                        icon: Icons.calendar_today_outlined,

                        suffix: "months",
                      ),

                      const SizedBox(height: 20),

                      _CalcButton(
                        label: "Calculate Maturity",

                        color: const Color.fromARGB(255, 11, 73, 155),

                        onPressed: calculate,
                      ),
                    ],
                  ),

                  if (_hasResult) ...[
                    const SizedBox(height: 16),

                    _ResultHero(
                      label: "Maturity Amount",

                      value: "₹${maturityAmount.toStringAsFixed(2)}",

                      gradient: const [Color(0xFF065F46), Color(0xFF0D9488)],
                    ),

                    const SizedBox(height: 12),

                    _ResultChip(
                      label: "Interest Earned",

                      value: "₹${interestEarned.toStringAsFixed(2)}",

                      icon: Icons.trending_up,

                      color: const Color(0xFF0D9488),

                      fullWidth: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalcHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;

  const _CalcHeader({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E3A8A)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
             
            child: Container(
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: AppColors.light.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),

              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.light,
                size: 18,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: AppTextStyles.whiteHeading(context, color: AppColors.lightBlue),
                ),

                const SizedBox(height: 8),

                Text(subtitle, style: TextStyle(color: AppColors.light.withValues(alpha: 0.7))),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16),

            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),

            child: Icon(icon, size: 40, color: iconColor),
          ),
        ],
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final List<Widget> children;

  const _InputCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.light,
      shadowColor:
      Colors.blue.withValues(alpha: 0.15),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: children),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String suffix;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixText: suffix,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _CalcButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _CalcButton({
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(label,
            style: TextStyle(
              color: AppColors.light,
              fontSize: AppFontSize.medium(context),
              fontWeight: FontWeight.bold,
            )),
      ),
    );
  }
}

class _ResultHero extends StatelessWidget {
  final String label;
  final String value;
  final List<Color> gradient;

  const _ResultHero({
    required this.label,
    required this.value,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: AppColors.light.withValues(alpha: 0.7))),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.whiteHeading(context),
          ),
        ],
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _ResultChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
