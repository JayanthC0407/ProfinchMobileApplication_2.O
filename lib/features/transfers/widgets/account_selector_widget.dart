import 'package:flutter/material.dart';
import '../../../data/models/account_model.dart';

class AccountSelectorWidget extends StatelessWidget {
  final List<AccountModel> accounts;
  final String? selectedAccountId;
  final Function(String?) onChanged;

  const AccountSelectorWidget({
    super.key,
    required this.accounts,
    required this.selectedAccountId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "DEBIT FROM",
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade500,
            letterSpacing: 0.7,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedAccountId,
              isExpanded: true,
              hint: const Text("Select account", style: TextStyle(fontSize: 14)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF2563B0)),
              items: accounts.map((account) {
                return DropdownMenuItem(
                  value: account.id,
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBEAFE),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(Icons.account_balance_wallet_outlined,
                            color: Color(0xFF2563B0), size: 17),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            account.accountType,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF111827),
                            ),
                          ),
                          Text(
                            "••••  ${account.accountNumber.substring(account.accountNumber.length - 4)}",
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF9CA3AF),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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