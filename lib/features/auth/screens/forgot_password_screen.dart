import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/shared/widgets/background_wrapper.dart';
import 'package:profinch_mobile_application/shared/widgets/logo.dart';
import 'otp_screen.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '${'*' * name.length}@$domain';
    return '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}@$domain';
  }

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (!authProvider.emailExists(email)) {
      setState(() => _error = 'No account found with this email');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call
    setState(() => _isLoading = false);

    if (!mounted) return;

    // Push OTP screen — reusing the generic OtpScreen
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          maskedDestination: _maskEmail(email),
          onVerified: (otp) async {
            // TODO: verify OTP against Auth Service
            await Future.delayed(const Duration(milliseconds: 800));
            return otp == '111111'; // same dummy rule as login
          },
          onResend: () async {
            // TODO: trigger real OTP resend API
            await Future.delayed(const Duration(milliseconds: 500));
          },
        ),
      ),
    );

    if (!mounted || verified != true) return;

    // OTP verified — go to Reset Password
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(email: email),
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
                    'Forgot Password',
                    style: TextStyle(
                      fontSize: AppFontSize.xl(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your registered email. We\'ll send a verification code to reset your password.',
                    style: TextStyle(
                      fontSize: AppFontSize.body(context),
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Email field
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                    style: TextStyle(
                        fontSize: AppFontSize.body(context),
                        color: const Color(0xFF1A1A2E)),
                    decoration: InputDecoration(
                      hintText: 'Registered email address',
                      hintStyle: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: AppFontSize.body(context)),
                      prefixIcon: const Icon(Icons.email_outlined,
                          color: Colors.grey, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
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
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            size: 14, color: Colors.red.shade300),
                        const SizedBox(width: 6),
                        Text(_error!,
                            style: TextStyle(
                                fontSize: AppFontSize.small(context),
                                color: Colors.red.shade300)),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSendOtp,
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
                          : Text('Send OTP',
                              style: TextStyle(
                                  fontSize: AppFontSize.body(context),
                                  fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Back to Login',
                        style: TextStyle(
                          fontSize: AppFontSize.body(context),
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
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
}