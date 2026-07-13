import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';

class LoginForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final VoidCallback onSubmit;

  final String? usernameError;
  final String? passwordError;

  const LoginForm({
    super.key,
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.onSubmit,
    this.usernameError,
    this.passwordError,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;

  // ── Validators ─────────────────────────────────────────────────
  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
     if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  // ── Shared input decoration ────────────────────────────────────
  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.black.withValues(alpha: 0.6),
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        size: 20,
        color: Colors.black.withValues(alpha: 0.6),
      ),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.light, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.light, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
      ),
      errorStyle: const TextStyle(color: AppColors.light, fontSize: 12),
    );
  }

  // ── Label ──────────────────────────────────────────────────────
  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.light,
        letterSpacing: 0.2,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Username ─────────────────────────────────────────
          _fieldLabel('Username'),
          if (widget.usernameError != null) ...[
            const SizedBox(height: 6),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),

              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      widget.usernameError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.usernameController,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            validator: _validateUsername,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: _inputDecoration(
              hint: 'Enter your Username',
              prefixIcon: Icons.person_outline_rounded,
            ),
          ),

          const SizedBox(height: 16),

          // ── Password ───────────────────────────────────────────
          _fieldLabel('Password'),
          if (widget.passwordError != null) ...[
            const SizedBox(height: 6),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),

              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),

              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 18),

                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      widget.passwordError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),
          ],
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => widget.onSubmit(),
            validator: _validatePassword,
            style: const TextStyle(fontSize: 14, color: Colors.black),
            decoration: _inputDecoration(
              hint: '••••••••',
              prefixIcon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
