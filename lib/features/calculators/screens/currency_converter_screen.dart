import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final amountController = TextEditingController();

  String fromCurrency = "USD";
  String toCurrency = "INR";
  double convertedAmount = 0;
  bool _hasResult = false;

  final Map<String, double> rates = {
    "USD": 83.50,
    "EUR": 91.20,
    "GBP": 106.00,
    "AED": 22.70,
    "INR": 1.0,
  };

  final Map<String, String> currencyFlags = {
    "USD": "🇺🇸",
    "EUR": "🇪🇺",
    "GBP": "🇬🇧",
    "AED": "🇦🇪",
    "INR": "🇮🇳",
  };

  void calculateForex() {
    if (amountController.text.isEmpty) return;

    final amount = double.parse(amountController.text);
    final amountInInr = amount * rates[fromCurrency]!;
    final converted = amountInInr / rates[toCurrency]!;

    setState(() {
      convertedAmount = converted;
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
            title: "Currency Converter",
            subtitle: "Convert currencies instantly",
            icon: Icons.currency_exchange_rounded,
            iconBg: AppColors.warningLight,
            iconColor: AppColors.warning,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Info banner
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded,
                            size: 16, color:AppColors.warning),
                        SizedBox(width: 8),
                        Text(
                          "Exchange rates are indicative only",
                          style: TextStyle(
                            fontSize: AppFontSize.small(context),
                            color: AppColors.warning,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Input card
                  _InputCard(
                    children: [
                      // Amount field
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "AMOUNT",
                          hintText: "e.g. 100",
                          prefixIcon:
                              const Icon(Icons.monetization_on_outlined),
                          suffixText: fromCurrency,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // From / Swap / To row
                      Row(
                        children: [
                          Expanded(
                            child: _buildCurrencyDropdown(
                              label: "FROM",
                              value: fromCurrency,
                              onChanged: (val) =>
                                  setState(() => fromCurrency = val!),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => setState(() {
                              final temp = fromCurrency;
                              fromCurrency = toCurrency;
                              toCurrency = temp;
                            }),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color.fromARGB(255, 11, 73, 155),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.swap_horiz_rounded,
                                color: AppColors.light,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildCurrencyDropdown(
                              label: "TO",
                              value: toCurrency,
                              onChanged: (val) =>
                                  setState(() => toCurrency = val!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      _CalcButton(
                        label: "Convert",
                        color: const Color.fromARGB(255, 11, 73, 155),
                        onPressed: calculateForex,
                      ),
                    ],
                  ),

                  if (_hasResult) ...[
                    const SizedBox(height: 16),
                    _ResultHero(
                      label: "Converted Amount",
                      value:
                          "${currencyFlags[toCurrency] ?? ''} ${convertedAmount.toStringAsFixed(2)} $toCurrency",
                      gradient: const [Color(0xFF92400E), AppColors.warning],
                    ),
                    const SizedBox(height: 12),
                    _ResultChip(
                      label:
                          "1 $fromCurrency = ${(rates[fromCurrency]! / rates[toCurrency]!).toStringAsFixed(4)} $toCurrency",
                      value: "",
                      icon: Icons.compare_arrows_rounded,
                      color: AppColors.warning,
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

  Widget _buildCurrencyDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSize.small(context),
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey300),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textSecondary, size: 20),
              style: AppTextStyles.bodyBold(context, color: AppColors.textDark),
              items: rates.keys.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(
                      "${currencyFlags[currency] ?? ''} $currency"),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Shared UI Components (same pattern as Term Deposit) ───────────────────────

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
            onTap: () => Navigator.pop(context),
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
                Text(subtitle,
                    style: TextStyle(color: AppColors.light.withValues(alpha:0.7))),
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
      shadowColor: Colors.blue.withValues(alpha: 0.15),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: children),
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
        child: Text(
          label,
          style: TextStyle(
            color: AppColors.light,
            fontSize: AppFontSize.medium(context),
            fontWeight: FontWeight.bold,
          ),
        ),
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
          if (value.isNotEmpty)
            Text(
              value,
              style: TextStyle(color: color, fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }
}