// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import 'package:profinch_mobile_application/shared/widgets/background_wrapper.dart';
import 'package:profinch_mobile_application/shared/widgets/logo.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isStrongPassword(String password) {
    if (password.length < 8) return false;
    if (!password.contains(RegExp(r'[A-Z]'))) return false;
    if (!password.contains(RegExp(r'[0-9]'))) return false;
    return true;
  }

  Future<void> _handleReset() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;

    if (newPass.isEmpty || confirmPass.isEmpty) {
      setState(() => _error = 'Please fill in both fields');
      return;
    }
    if (!_isStrongPassword(newPass)) {
      setState(() => _error =
          'Password must be 8+ characters with at least one uppercase letter and number');
      return;
    }
    if (newPass != confirmPass) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    await Future.delayed(const Duration(seconds: 1)); // TODO: call Auth Service
    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password reset successfully! Please log in.'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // Clear the entire auth stack and go back to login
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.login, (route) => false);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required bool showText,
    required VoidCallback onToggle,
  }) {
    return TextField(
      controller: controller,
      obscureText: !showText,
      onChanged: (_) {
        if (_error != null) setState(() => _error = null);
      },
      style: TextStyle(
          fontSize: AppFontSize.body(context),
          color: const Color(0xFF1A1A2E)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: Colors.grey.shade400,
            fontSize: AppFontSize.body(context)),
        prefixIcon:
            const Icon(Icons.lock_outline, color: Colors.grey, size: 20),
        suffixIcon: GestureDetector(
          onTap: onToggle,
          child: Icon(
            showText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
            color: Colors.grey,
            size: 20,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: _error != null
                  ? Colors.red.shade400
                  : Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: _error != null
                  ? Colors.red.shade400
                  : Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
              color: _error != null
                  ? Colors.red.shade400
                  : AppColors.primary,
              width: 1.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppLogo(),
                  const SizedBox(height: 32),

                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontSize: AppFontSize.xl(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a new password for ${widget.email}',
                    style: TextStyle(
                      fontSize: AppFontSize.body(context),
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Password rules hint
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.15)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Password must have:',
                            style: TextStyle(
                                fontSize: AppFontSize.small(context),
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500)),
                        const SizedBox(height: 6),
                        _ruleRow('At least 8 characters'),
                        _ruleRow('One uppercase letter (A-Z)'),
                        _ruleRow('One number (0-9)'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _buildField(
                    controller: _newPasswordController,
                    hint: 'New password',
                    showText: _showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                  ),

                  const SizedBox(height: 12),

                  _buildField(
                    controller: _confirmPasswordController,
                    hint: 'Confirm new password',
                    showText: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            size: 14, color: Colors.red.shade300),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(_error!,
                              style: TextStyle(
                                  fontSize: AppFontSize.small(context),
                                  color: Colors.red.shade300)),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleReset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : Text('Reset Password',
                              style: TextStyle(
                                  fontSize: AppFontSize.body(context),
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _ruleRow(String text) => Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Row(
          children: [
            Icon(Icons.check_circle_outline,
                size: 13, color: Colors.white.withValues(alpha: 0.6)),
            const SizedBox(width: 6),
            Text(text,
                style: TextStyle(
                    fontSize: AppFontSize.xs(context),
                    color: Colors.white.withValues(alpha: 0.65))),
          ],
        ),
      );
}