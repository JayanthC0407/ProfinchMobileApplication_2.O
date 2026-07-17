import 'package:flutter/material.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/network/api_exception.dart';
import 'package:profinch_mobile_application/data/repositories/forgot_username_repository.dart';
import 'package:profinch_mobile_application/shared/widgets/background_wrapper.dart';
import 'package:profinch_mobile_application/shared/widgets/logo.dart';
import 'otp_screen.dart';

/// Real OBDX flow: emailId + dateOfBirth -> OTP -> done.
///
/// Mirrors ForgotPasswordScreen's structure (same OTP-challenge pattern,
/// same repository shape) — see ForgotUsernameRepository's doc for the
/// same caveat about the final response likely just triggering an
/// email/SMS with the username rather than returning it for display here.
class ForgotUsernameScreen extends StatefulWidget {
  const ForgotUsernameScreen({super.key});

  @override
  State<ForgotUsernameScreen> createState() => _ForgotUsernameScreenState();
}

class _ForgotUsernameScreenState extends State<ForgotUsernameScreen> {
  final _emailController = TextEditingController();
  final _repository = ForgotUsernameRepository();

  DateTime? _dateOfBirth;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      _dateOfBirth = picked;
      if (_error != null) _error = null;
    });
  }

  String _formatDob(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  bool _isValidEmail(String email) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);

  Future<void> _handleSendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      setState(() => _error = 'Please enter a valid email address');
      return;
    }
    if (_dateOfBirth == null) {
      setState(() => _error = 'Please select your date of birth');
      return;
    }

    final dob = _formatDob(_dateOfBirth!);
    setState(() {
      _isLoading = true;
      _error = null;
    });

    bool otpSent = false;
    String? realError;
    try {
      await _repository.initiate(emailId: email, dateOfBirth: dob);
      otpSent = true;
    } on ApiException catch (e) {
      if (e.requiresChallenge) {
        otpSent = true;
      } else {
        realError = e.message;
      }
    } catch (e) {
      realError = 'Something went wrong. Please try again.';
    }

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (!otpSent) {
      setState(() => _error = realError ?? 'Please try again.');
      return;
    }

    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          maskedDestination: 'your registered mobile number/email',
          onVerified: (otp) async {
            try {
              await _repository.confirm(
                emailId: email,
                dateOfBirth: dob,
                otp: otp,
              );
              return true;
            } catch (_) {
              return false;
            }
          },
          onResend: () async {
            try {
              await _repository.initiate(emailId: email, dateOfBirth: dob);
            } on ApiException catch (e) {
              if (!e.requiresChallenge) rethrow;
            }
          },
        ),
      ),
    );

    if (!mounted || verified != true) return;

    _showDoneDialog();
  }

  void _showDoneDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Verified'),
        content: const Text(
          'Your identity has been verified. Your username has been sent '
          'to your registered mobile number/email.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx); // close dialog
              Navigator.pop(context); // back to login
            },
            child: const Text('Back to Login'),
          ),
        ],
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
                    'Forgot Username',
                    style: TextStyle(
                      fontSize: AppFontSize.xl(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your registered email and date of birth. '
                    'We\'ll send a verification code to look up your username.',
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

                  const SizedBox(height: 14),

                  // Date of birth field
                  GestureDetector(
                    onTap: _pickDateOfBirth,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _error != null
                              ? Colors.red.shade400
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.cake_outlined,
                              color: Colors.grey, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _dateOfBirth == null
                                ? 'Date of birth'
                                : _formatDob(_dateOfBirth!),
                            style: TextStyle(
                              fontSize: AppFontSize.body(context),
                              color: _dateOfBirth == null
                                  ? Colors.grey.shade400
                                  : const Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
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