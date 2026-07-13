import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../../../data/models/insurance_model.dart';
import '../widgets/app_notification.dart';
import 'my_policies_screen.dart';

class PurchaseSuccessScreen extends StatelessWidget {
  final InsuranceModel policy;
  const PurchaseSuccessScreen({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Animated checkmark ────────────────────────
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) {
                    return Transform.scale(scale: value, child: child);
                  },
                  child: Container(
                    width: 110, height: 110,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primaryDark, const Color(0xFF2A1F8F)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryDark.withValues(alpha: 0.35),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check, color: Colors.white, size: 54),
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Policy Purchased\nSuccessfully!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E),
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  'Policy Number',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 6),
                Text(
                  policy.policyNumber,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'A policy confirmation has been sent to\nyour registered mobile number and email.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.5),
                ),

                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const MyPoliciesScreen()),
                    (route) => route.isFirst,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Go to My Policies', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ),

                const SizedBox(height: 14),

                TextButton(
                  onPressed: () => AppNotification.show(context,
                    message: 'Downloading policy document...',
                    type: AppNotificationType.info),
                  child: Text('Download Policy',
                      style: TextStyle(color: AppColors.primary, fontSize: 15, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}