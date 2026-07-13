import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_up_widgets/signup_text_field.dart';

class SignUpForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController phoneController;
  final TextEditingController panController;
  final VoidCallback onSubmit;

  const SignUpForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.phoneController,
    required this.panController,
    required this.onSubmit,
  });

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  bool _obscurePassword = true;

  // ── Validators ─────────────────────────────────────────────────
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value.trim())) {
      return 'Only letters, numbers and underscores allowed';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Must contain at least one uppercase letter';
    }
    if (!RegExp(r'(?=.*[0-9])').hasMatch(value)) {
      return 'Must contain at least one number';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  String? _validatePan(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PAN number is required';
    }
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(value.trim().toUpperCase())) {
      return 'Enter a valid PAN (e.g. ABCDE1234F)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ── Username ───────────────────────────────────────────
          SignUpTextField(
            controller: widget.usernameController,
            label: 'Username',
            hint: 'john_doe',
            prefixIcon: Icons.person_outline_rounded,
            textInputAction: TextInputAction.next,
            validator: _validateUsername,
          ),

          const SizedBox(height: 16),

          // ── Password ───────────────────────────────────────────
          SignUpTextField(
            controller: widget.passwordController,
            label: 'Password',
            hint: '••••••••',
            prefixIcon: Icons.lock_outline_rounded,
            textInputAction: TextInputAction.next,
            obscureText: _obscurePassword,
            validator: _validatePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: Colors.black.withValues(alpha: 0.5),
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),

          const SizedBox(height: 16),

          // ── Phone number ───────────────────────────────────────
          SignUpTextField(
            controller: widget.phoneController,
            label: 'Phone Number',
            hint: '9876543210',
            prefixIcon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: _validatePhone,
          ),

          const SizedBox(height: 16),

          // ── PAN number ─────────────────────────────────────────
          SignUpTextField(
            controller: widget.panController,
            label: 'PAN Number',
            hint: 'ABCDE1234F',
            prefixIcon: Icons.credit_card_outlined,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.done,
            maxLength: 10,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
              TextInputFormatter.withFunction((oldValue, newValue) {
                return newValue.copyWith(
                  text: newValue.text.toUpperCase(),
                  selection: newValue.selection,
                );
              }),
            ],
            validator: _validatePan,
          ),

        ],
      ),
    );
  }
}