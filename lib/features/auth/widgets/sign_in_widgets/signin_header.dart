import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.light,
            letterSpacing: -0.5,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Sign in to your account',
          style: TextStyle(fontSize: 15, color: AppColors.light),
        ),
      ],
    );
  }
}
