import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_up_widgets/signup_text_field.dart';

/// Registration wizard — Step 1: Personal Information.
/// (First Name, Last Name, Email, Date of Birth)
class PersonalInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController emailController;
  final DateTime? dateOfBirth;
  final VoidCallback onPickDateOfBirth;

  const PersonalInfoStep({
    super.key,
    required this.formKey,
    required this.firstNameController,
    required this.lastNameController,
    required this.emailController,
    required this.dateOfBirth,
    required this.onPickDateOfBirth,
  });

  String? _validateRequired(String? value, String label) {
    if (value == null || value.trim().isEmpty) {
      return '$label is required';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String _formatDob(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

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
            controller: firstNameController,
            label: 'First Name *',
            hint: 'Sachin',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) => _validateRequired(v, 'First name'),
          ),
          const SizedBox(height: 16),

          SignUpTextField(
            controller: lastNameController,
            label: 'Last Name *',
            hint: 'Tendulkar',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: (v) => _validateRequired(v, 'Last name'),
          ),
          const SizedBox(height: 16),

          SignUpTextField(
            controller: emailController,
            label: 'Email Address *',
            hint: 'you@example.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: _validateEmail,
          ),
          const SizedBox(height: 16),

          _fieldLabel('Date of Birth'),
          GestureDetector(
            onTap: onPickDateOfBirth,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white.withValues(alpha: 0.6)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cake_outlined,
                      size: 20, color: Colors.black.withValues(alpha: 0.5)),
                  const SizedBox(width: 12),
                  Text(
                    dateOfBirth == null
                        ? 'Select date of birth'
                        : _formatDob(dateOfBirth!),
                    style: TextStyle(
                      fontSize: 14,
                      color: dateOfBirth == null
                          ? Colors.black.withValues(alpha: 0.4)
                          : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}