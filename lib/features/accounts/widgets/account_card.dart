import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/utils/currency_formatter.dart';
import 'package:profinch_mobile_application/data/models/account_model.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';

class AccountCard extends StatelessWidget {
  final AccountModel account;
  final VoidCallback onTap;

  const AccountCard({super.key, required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.light, // light blue background
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              account.accountType,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: AppFontSize.large(context),
              ),
            ),

            const SizedBox(height: 10),

            Text(account.accountNumber),
            const SizedBox(height: 10),
            Text(
              CurrencyFormatter.format(
                account.availableBalance,
                account.currencyCode,
              ),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: account.availableBalance < 0 ? Colors.red : Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
