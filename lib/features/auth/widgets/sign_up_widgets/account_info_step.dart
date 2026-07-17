import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_up_widgets/signup_text_field.dart';
import 'package:profinch_mobile_application/data/repositories/registration_repository.dart';

/// Registration wizard — Step 2: Account Information.
/// (Customer ID, Account Number, Account Type, Debit Card Number, Terms)
class AccountInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController partyIdController;
  final TextEditingController accountNumberController;
  final TextEditingController debitCardNumberController;
  final List<AccountTypeOption> accountTypes;
  final bool isLoadingAccountTypes;
  final String? selectedAccountType;
  final ValueChanged<String?> onAccountTypeChanged;
  final bool termsAccepted;
  final ValueChanged<bool?> onTermsChanged;

  const AccountInfoStep({
    super.key,
    required this.formKey,
    required this.partyIdController,
    required this.accountNumberController,
    required this.debitCardNumberController,
    required this.accountTypes,
    required this.isLoadingAccountTypes,
    required this.selectedAccountType,
    required this.onAccountTypeChanged,
    required this.termsAccepted,
    required this.onTermsChanged,
  });

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  Widget _fieldLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RichText(
          text: TextSpan(
            text: text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 0.2,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: Color(0xFFFF6B6B)),
              ),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignUpTextField(
            controller: partyIdController,
            label: 'Customer ID *',
            hint: 'e.g. 000047',
            prefixIcon: Icons.badge_outlined,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: (v) => _validateRequired(v, 'Customer ID'),
          ),
          const SizedBox(height: 16),

          SignUpTextField(
            controller: accountNumberController,
            label: 'Account Number *',
            hint: 'Your existing account number',
            prefixIcon: Icons.account_balance_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (v) => _validateRequired(v, 'Account number'),
          ),
          const SizedBox(height: 16),

          _fieldLabel('Account Type'),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
            ),
            child: isLoadingAccountTypes
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Loading account types…',
                            style: TextStyle(fontSize: 14)),
                      ],
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButtonFormField<String>(
                      value: selectedAccountType,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                      hint: const Text('Select account type',
                          style: TextStyle(fontSize: 14)),
                      items: accountTypes
                          .map((t) => DropdownMenuItem(
                                value: t.code,
                                child: Text(t.label,
                                    style: const TextStyle(fontSize: 14)),
                              ))
                          .toList(),
                      onChanged: onAccountTypeChanged,
                      validator: (v) =>
                          v == null ? 'Please select an account type' : null,
                    ),
                  ),
          ),
          const SizedBox(height: 16),

          SignUpTextField(
            controller: debitCardNumberController,
            label: 'Debit Card Number (optional)',
            hint: '8888 8989 8989 9898 989',
            prefixIcon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            // Confirmed not actually required server-side, despite the
            // reference UI marking it required — no validator here.
          ),
          const SizedBox(height: 20),

          // ── Terms and Conditions ───────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: termsAccepted,
                  onChanged: onTermsChanged,
                  fillColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : Colors.transparent,
                  ),
                  checkColor: Colors.black87,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => onTermsChanged(!termsAccepted),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      'I agree to Terms and Conditions',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}