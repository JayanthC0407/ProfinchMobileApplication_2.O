import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

class SignUpRow extends StatelessWidget {
  final VoidCallback onSignUp;

  const SignUpRow({super.key, required this.onSignUp});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Don't have an account? ",
            style: TextStyle(fontSize: 13, color: AppColors.light),
          ),
          GestureDetector(
            onTap: onSignUp,
            child: const Text(
              'Create one',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}