import 'package:flutter/material.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/card_model.dart';

class ApplyCardScreen extends StatefulWidget {
  const ApplyCardScreen({super.key});

  @override
  State<ApplyCardScreen> createState() => _ApplyCardScreenState();
}

class _ApplyCardScreenState extends State<ApplyCardScreen> {
  CardType _selectedType = CardType.debit;
  String _selectedNetwork = 'Visa';
  bool _isSubmitting = false;

  final List<String> _networks = ['Visa', 'Mastercard', 'RuPay'];

  // ── Card type option ──────────────────────────────────────────
  Widget _buildCardTypeOption({
    required CardType type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final selected = _selectedType == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark :AppColors.light,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primaryDark : Colors.grey.shade200,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.primaryDark.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.light.withValues(alpha: 0.15)
                    : AppColors.primaryDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.light : AppColors.primaryDark,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSize.body(context),
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.light : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: AppFontSize.small(context),
                      color: selected ? AppColors.light.withValues(alpha: 0.7) : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.light, size: 20),
          ],
        ),
      ),
    );
  }

  // ── Network chip ──────────────────────────────────────────────
  Widget _buildNetworkChip(String network) {
    final selected = _selectedNetwork == network;
    return GestureDetector(
      onTap: () => setState(() => _selectedNetwork = network),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDark : AppColors.light,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? AppColors.primaryDark : Colors.grey.shade300,
          ),
        ),
        child: Text(
          network,
          style: TextStyle(
            fontSize: AppFontSize.small(context), //13
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.light : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  // ── Benefits row ──────────────────────────────────────────────
  Widget _buildBenefit(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primaryDark.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: AppFontSize.body(context), color: Color(0xFF444466)), //13
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitApplication() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(28),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFFDDF7E3),
                borderRadius: BorderRadius.circular(32),
              ),
              child: const Icon(Icons.check_rounded,
                  color: Color(0xFF2E7D32), size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Application Submitted!',
              style: TextStyle(
                fontSize: AppFontSize.large(context),
                fontWeight: FontWeight.w700, 
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your ${_selectedType == CardType.debit ? 'Debit' : 'Credit'} Card application is under review. You\'ll be notified within 3–5 business days.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: AppFontSize.body(context), color: Colors.grey.shade600), //13
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  Navigator.pop(context); // back to cards screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.light,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Done',
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.light),
        title: Text(
          'Apply for Card',
          style: AppTextStyles.whiteTitle(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Header ───────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.textPrimary, Color(0xFF0F3460)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New Card',
                          style: TextStyle(
                            color: AppColors.light,
                            fontSize: AppFontSize.large(context),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Choose the card that fits your needs and apply in seconds.',
                          style:
                              TextStyle(color: AppColors.light.withValues(alpha: 0.60), fontSize: AppFontSize.body(context)), //13
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.credit_card_rounded,
                      size: 48, color: AppColors.light.withValues(alpha: 0.24)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Card type ─────────────────────────────────────────
            Text(
              'Select Card Type',
              style: TextStyle(
                fontSize: AppFontSize.body(context),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary
              ),
            ),
            const SizedBox(height: 12),
            _buildCardTypeOption(
              type: CardType.debit,
              title: 'Debit Card',
              subtitle: 'Spend directly from your savings account',
              icon: Icons.account_balance_wallet_outlined,
            ),
            const SizedBox(height: 10),
            _buildCardTypeOption(
              type: CardType.credit,
              title: 'Credit Card',
              subtitle: 'Up to ₹5,00,000 credit limit with rewards',
              icon: Icons.credit_score_outlined,
            ),

            const SizedBox(height: 24),

            // ── Network ───────────────────────────────────────────
            Text(
              'Select Network',
              style: TextStyle(
                fontSize: AppFontSize.body(context),
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: _networks
                  .map((n) => Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: _buildNetworkChip(n),
                      ))
                  .toList(),
            ),

            const SizedBox(height: 24),

            // ── Benefits ──────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'What you get',
                    style: TextStyle(
                      fontSize: AppFontSize.body(context),
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBenefit(Icons.security_rounded,
                      'Zero liability on unauthorised transactions'),
                  _buildBenefit(Icons.contactless_rounded,
                      'Contactless tap & pay (NFC)'),
                  _buildBenefit(Icons.language_rounded,
                      'International usage enabled on request'),
                  if (_selectedType == CardType.credit) ...[
                    _buildBenefit(Icons.star_rounded,
                        'Earn reward points on every spend'),
                    _buildBenefit(Icons.percent_rounded,
                        'Up to 5% cashback on select categories'),
                  ],
                  _buildBenefit(Icons.support_agent_rounded,
                      '24/7 customer support'),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Submit button ─────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitApplication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.light,
                  disabledBackgroundColor:
                      AppColors.primaryDark.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.light,
                        ),
                      )
                    : Text(
                        'Submit Application',
                        style: TextStyle(
                          fontSize: AppFontSize.medium(context),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            Center(
              child: Text(
                'Application is subject to bank approval & KYC verification.',
                textAlign: TextAlign.center,
                style: AppTextStyles.caption(context,
                    color: Colors.grey.shade400),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}