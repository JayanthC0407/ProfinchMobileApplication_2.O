import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';

class LoanTypeCard extends StatelessWidget {

  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const LoanTypeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 4,
      color: AppColors.lightBlue,

      child: ListTile(
        leading: Icon(
          icon,
          color: AppColors.primary,
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: AppColors.primary,
        ),

        onTap: onTap,
      ),
    );
  }
}