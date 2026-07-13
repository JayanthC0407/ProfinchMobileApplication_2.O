// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/auth/screens/forgot_password_screen.dart';
import 'package:profinch_mobile_application/features/auth/screens/otp_screen.dart';
import 'package:profinch_mobile_application/features/auth/screens/pin_screen.dart';
import 'package:profinch_mobile_application/features/auth/screens/pattern_screen.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_in_widgets/remember_forgot_row.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_in_widgets/sign_in_button.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_in_widgets/sign_up_button.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_in_widgets/signin_form.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_in_widgets/signin_header.dart';
import 'package:profinch_mobile_application/features/auth/screens/signup_screen.dart';
import 'package:profinch_mobile_application/features/dashboard/provider/dashboard_provider.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/loans/provider/loan_provider.dart';
import 'package:profinch_mobile_application/shared/widgets/background_wrapper.dart';
import 'package:profinch_mobile_application/shared/widgets/logo.dart';
import 'package:profinch_mobile_application/shared/widgets/security_badge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Sign in with username + password ─────────────────────────────
  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final authProvider = context.read<AuthProvider>();

    final success = await authProvider.login(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);
    if (!mounted) return;

    if (success) {
      if (authProvider.otpPending) {
        // /me came back requiring OTP verification — we don't have the
        // user's profile (and therefore their phone number) yet, so show
        // a generic destination message rather than a masked number.
        final verified = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(
              maskedDestination: 'your registered mobile number',
              onVerified: (otp) => authProvider.verifyLoginOtp(otp),
              onResend: () => authProvider.resendLoginOtp(),
            ),
          ),
        );

        if (!mounted || verified != true) return;
      }

      if (authProvider.currentUser == null) return;

      final userId = authProvider.currentUser!.id;
      // Kick off real CASA + Loan data fetch (tracker items #7, #8, #9).
      // Awaited (not fire-and-forget) here specifically so we can pick a
      // sensible "primary" account afterwards — the /me response has no
      // primaryAccountId field, so we fall back to the first CASA account
      // returned by the real API.
      final accountProvider = context.read<AccountProvider>();
      await accountProvider.loadAccounts(userId: userId);
      if (!mounted) return;
      context.read<LoanProvider>().loadLoanBalanceOverview(userId: userId);

      final accounts = accountProvider.getAccountsByUserId(userId);
      final primaryAccountId = accounts.isNotEmpty ? accounts.first.id : '';
      context.read<DashboardProvider>().resetToPrimary(primaryAccountId);

      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Invalid username or password'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ── Forgot password ───────────────────────────────────────────
  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  // ── Biometric ─────────────────────────────────────────────────
  Future<void> _handleBiometric() async {
    final authProvider = context.read<AuthProvider>();
    final available = await authProvider.checkBiometricAvailable();
    if (!mounted) return;

    if (!available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Biometric not available on this device'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final success = await authProvider.authenticateWithBiometric();
    if (!mounted) return;

    if (success && authProvider.currentUser != null) {
      context.read<DashboardProvider>().resetToPrimary(
          authProvider.currentUser!.primaryAccountId);
      Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Biometric authentication failed'),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  // ── PIN login ─────────────────────────────────────────────────
  void _handlePinLogin() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isPinSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'PIN not set. Log in with your password first, then set a PIN from Profile → Security.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PinScreen(mode: PinScreenMode.login),
      ),
    );
  }

  // ── Pattern login ─────────────────────────────────────────────
  void _handlePatternLogin() {
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isPatternSet) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Pattern not set. Log in with your password first, then set a pattern from Profile → Security.'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatternScreen(mode: PatternScreenMode.login),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

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

                  const LoginHeader(),
                  const SizedBox(height: 28),

                  LoginForm(
                    formKey: _formKey,
                    usernameController: _usernameController,
                    passwordController: _passwordController,
                    onSubmit: _handleSignIn,
                  ),

                  const SizedBox(height: 20),
                  RememberForgotRow(onForgotPassword: _handleForgotPassword),
                  const SizedBox(height: 24),

                  SignInButton(
                    isLoading: _isLoading,
                    onPressed: _handleSignIn,
                  ),

                  const SizedBox(height: 20),

                  // ── Quick login options ──────────────────────
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or quick login',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: AppFontSize.small(context),
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.3))),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      // PIN button
                      _quickLoginButton(
                        icon: Icons.pin_outlined,
                        label: 'PIN',
                        onTap: _handlePinLogin,
                        isEnabled: authProvider.isPinSet,
                      ),

                      const SizedBox(width: 16),

                      // Pattern button
                      _quickLoginButton(
                        icon: Icons.grid_view_rounded,
                        label: 'Pattern',
                        onTap: _handlePatternLogin,
                        isEnabled: authProvider.isPatternSet,
                      ),

                      const SizedBox(width: 16),

                      // Biometric button
                      _quickLoginButton(
                        icon: Icons.fingerprint_rounded,
                        label: 'Biometric',
                        onTap: _handleBiometric,
                        isEnabled: authProvider.isBiometricEnabled,
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  SignUpRow(
                    onSignUp: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (ctx) => const SignUpScreen()),
                    ),
                  ),

                  const SizedBox(height: 20),
                  const SecurityBadge(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickLoginButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isEnabled
              ? Colors.white.withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isEnabled
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isEnabled
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.35),
              size: 26,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: AppFontSize.xs(context),
                fontWeight: FontWeight.w500,
                color: isEnabled
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ),
    );
  }
}