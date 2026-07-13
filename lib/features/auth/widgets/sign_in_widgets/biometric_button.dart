import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

class BiometricButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BiometricButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Divider ────────────────────────────────────────────
        Row(
          children: [
            const Expanded(
              child: Divider(color: AppColors.light, thickness: 1),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.light.withValues(alpha: 0.9),
                ),
              ),
            ),
            const Expanded(
              child: Divider(color: AppColors.light, thickness: 1),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ── Biometric button ───────────────────────────────────
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.fingerprint_rounded, size: 20),
            label: const Text('Biometric sign-in'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.light, width: 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}