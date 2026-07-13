import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart'; 
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'images/logoPhone.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Profinch Bank',
          style: TextStyle(
            fontSize: AppFontSize.xl(context),
            fontWeight: FontWeight.w600,
            color: AppColors.light,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}