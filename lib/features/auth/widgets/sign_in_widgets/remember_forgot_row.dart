import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

class RememberForgotRow extends StatefulWidget {
  final VoidCallback onTroubleSigningIn;

  const RememberForgotRow({
    super.key,
    required this.onTroubleSigningIn,
  });

  @override
  State<RememberForgotRow> createState() => _RememberForgotRowState();
}

class _RememberForgotRowState extends State<RememberForgotRow> {
  bool _rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ── Remember me ────────────────────────────────────────
        Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: _rememberMe,
                onChanged: (val) =>
                    setState(() => _rememberMe = val ?? false),
                activeColor: AppColors.primary,
                side: const BorderSide(color: AppColors.light, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Remember me',
              style: TextStyle(fontSize: 13, color: AppColors.light),
            ),
          ],
        ),

        // ── Trouble signing in ───────────────────────────────────
        // Single entry point instead of two competing "Forgot
        // password?"/"Forgot username?" links — branches into both via
        // a bottom sheet (see login_screen.dart's _handleTroubleSigningIn).
        GestureDetector(
          onTap: widget.onTroubleSigningIn,
          child: const Text(
            'Trouble signing in?',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.light,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.light,
            ),
          ),
        ),
      ],
    );
  }
}