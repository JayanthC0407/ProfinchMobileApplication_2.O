import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/shared/widgets/background_wrapper.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_up_widgets/signup_button.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_up_widgets/signup_form.dart';
import 'package:profinch_mobile_application/shared/widgets/security_badge.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _panController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _panController.dispose();
    super.dispose();
  }

  // ── Handlers ───────────────────────────────────────────────────
  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Replace with your actual sign-up API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _isLoading = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Account created successfully!'),
        backgroundColor: const Color(0xFF0F6E56),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    // TODO: Navigate to OTP verification or login screen
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OtpScreen()));
  }

  // ── Build ──────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return BackgroundWrapper(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 420,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Back arrow ───────────────────────────────────
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.light.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.light,
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Heading ───────────────────────────────────────
                Text(
                  'Register your account',
                  style: TextStyle(
                    fontSize: AppFontSize.xxl(context),
                    fontWeight: FontWeight.w700,
                    color: AppColors.light,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill in the details below to get started',
                  style: AppTextStyles.whiteBody(context),
                ),
                const SizedBox(height: 28),

                // ── Form ──────────────────────────────────────────
                SignUpForm(
                  formKey: _formKey,
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  phoneController: _phoneController,
                  panController: _panController,
                  onSubmit: _handleSignUp,
                ),
                const SizedBox(height: 28),

                // ── Submit button ─────────────────────────────────
                SignUpButton(
                  isLoading: _isLoading,
                  onPressed: _handleSignUp,
                ),
                const SizedBox(height: 20),

                // ── Security badge ────────────────────────────────
                const SecurityBadge(),
                const SizedBox(height: 16),

              ],
            ),
          ),
        ),
      ),
    );
  }
}