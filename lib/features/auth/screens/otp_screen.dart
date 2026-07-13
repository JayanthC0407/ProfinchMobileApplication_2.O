import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'package:profinch_mobile_application/shared/widgets/background_wrapper.dart';
import 'package:profinch_mobile_application/shared/widgets/logo.dart';

/// Generic OTP screen used by both:
///  1. Login flow      -> Login success -> OTP -> Dashboard
///  2. Forgot Password -> Enter email/phone -> OTP -> Reset Password
///
/// [maskedDestination] is shown to the user, e.g. "+91 98765 43210" or "j***@mail.com"
/// [onVerified] is called with the entered OTP once length == 6.
///   Return true to proceed, false to show an "Incorrect OTP" error.
class OtpScreen extends StatefulWidget {
  final String maskedDestination;
  final Future<bool> Function(String otp) onVerified;
  final Future<void> Function() onResend;

  /// Number of OTP digits to collect. The real backend sends a 4-digit
  /// OTP (confirmed from the live X-CHALLENGE response), so this now
  /// defaults to 4 instead of the previous hardcoded 6.
  final int otpLength;

  const OtpScreen({
    super.key,
    required this.maskedDestination,
    required this.onVerified,
    required this.onResend,
    this.otpLength = 4,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  late final int _otpLength = widget.otpLength;
  static const int _resendSeconds = 30;

  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  bool _isVerifying = false;
  bool _hasError = false;
  int _secondsLeft = _resendSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controllers.addAll(List.generate(_otpLength, (_) => TextEditingController()));
    _focusNodes.addAll(List.generate(_otpLength, (_) => FocusNode()));
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _startResendTimer() {
    _secondsLeft = _resendSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _enteredOtp => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (_hasError) setState(() => _hasError = false);

    if (value.isNotEmpty && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_enteredOtp.length == _otpLength) {
      _handleVerify();
    }
  }

  Future<void> _handleVerify() async {
    if (_enteredOtp.length != _otpLength || _isVerifying) return;

    setState(() => _isVerifying = true);
    final success = await widget.onVerified(_enteredOtp);
    setState(() => _isVerifying = false);

    if (!mounted) return;

    if (!success) {
      setState(() => _hasError = true);
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes[0].requestFocus();
    } else if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _handleResend() async {
    if (_secondsLeft > 0) return;
    await widget.onResend();
    if (!mounted) return;
    _startResendTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('OTP resent successfully'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                    'Verify OTP',
                    style: TextStyle(
                      fontSize: RT.fs(context, 26),
                      fontWeight: FontWeight.w700,
                      color: AppColors.light,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the $_otpLength-digit code sent to\n${widget.maskedDestination}',
                    style: AppTextStyles.whiteBody(context, color: AppColors.light.withValues(alpha: 0.8)),
                  ),

                  const SizedBox(height: 32),

                  // OTP boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(_otpLength, (index) {
                      return SizedBox(
                        width: 46,
                        height: 54,
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1,
                          style: TextStyle(
                            fontSize: RT.fs(context, 20),
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: AppColors.light,
                            contentPadding: EdgeInsets.zero,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? Colors.red.shade400
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? Colors.red.shade400
                                    : Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: _hasError
                                    ? Colors.red.shade400
                                    : AppColors.primary,
                                width: 2,
                              ),
                            ),
                          ),
                          onChanged: (value) => _onDigitChanged(index, value),
                        ),
                      );
                    }),
                  ),

                  if (_hasError) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(Icons.error_outline,
                            size: 16, color: Colors.red.shade300),
                        const SizedBox(width: 6),
                        Text(
                          'Incorrect OTP. Please try again.',
                          style:AppTextStyles.body(context, color: Colors.red.shade300),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 28),

                  // Verify button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isVerifying ? null : _handleVerify,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: AppColors.light,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifying
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.light,
                              ),
                            )
                          : Text(
                              'Verify & Continue',
                              style: TextStyle(
                                  fontSize: AppFontSize.medium(context), fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Resend row
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Didn't receive the code? ",
                          style: AppTextStyles.body(context, color: AppColors.light.withValues(alpha: 0.7)),
                        ),
                        GestureDetector(
                          onTap: _secondsLeft == 0 ? _handleResend : null,
                          child: Text(
                            _secondsLeft == 0
                                ? 'Resend OTP'
                                : 'Resend in ${_secondsLeft}s',
                            style: TextStyle(
                              fontSize: AppFontSize.body(context),
                              fontWeight: FontWeight.w600,
                              color: _secondsLeft == 0
                                  ? AppColors.light
                                  : AppColors.light.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                      ],
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