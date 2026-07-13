import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/routes/app_routes.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/dashboard/provider/dashboard_provider.dart';
import 'package:profinch_mobile_application/shared/widgets/background_wrapper.dart';

enum PinScreenMode { setup, login }

class PinScreen extends StatefulWidget {
  final PinScreenMode mode;
  const PinScreen({super.key, required this.mode});

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  static const int _pinLength = 4;

  String _entered = '';
  String _firstPin = '';
  bool _confirming = false;
  bool _hasError = false;
  String _errorMessage = '';

  // ignore: unused_element
  void _reset() {
    setState(() {
      _entered = '';
      _hasError = false;
      _errorMessage = '';
    });
  }

  void _onKey(String digit) {
    if (_entered.length >= _pinLength) return;
    setState(() {
      _entered += digit;
      _hasError = false;
    });
    if (_entered.length == _pinLength) {
      Future.delayed(const Duration(milliseconds: 150), _handlePinComplete);
    }
  }

  void _onDelete() {
    if (_entered.isEmpty) return;
    setState(() => _entered = _entered.substring(0, _entered.length - 1));
  }

  Future<void> _handlePinComplete() async {
    final authProvider = context.read<AuthProvider>();

    if (widget.mode == PinScreenMode.login) {
      final ok = authProvider.verifyPin(_entered);
      if (ok) {
        // verifyPin() restores currentUser if it was null after logout
        final user = authProvider.currentUser;
        if (user != null) {
          context.read<DashboardProvider>().resetToPrimary(
            user.primaryAccountId,
          );
        }
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.dashboard,
          (route) => false,
        );
      } else {
        setState(() {
          _entered = '';
          _hasError = true;
          _errorMessage = 'Incorrect PIN. Try again.';
        });
      }
      return;
    }

    // Setup mode
    if (!_confirming) {
      setState(() {
        _firstPin = _entered;
        _entered = '';
        _confirming = true;
      });
    } else {
      if (_entered == _firstPin) {
        authProvider.setPin(_entered);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PIN set successfully!'),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          _entered = '';
          _firstPin = '';
          _confirming = false;
          _hasError = true;
          _errorMessage = "PINs don't match. Please start again.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isLogin = widget.mode == PinScreenMode.login;
    final screenH = MediaQuery.of(context).size.height;

    final title = isLogin
        ? 'Welcome back'
        : (_confirming ? 'Confirm PIN' : 'Set PIN');
    final subtitle = isLogin
        ? 'Enter your 4-digit PIN to continue'
        : (_confirming
              ? 'Re-enter the same PIN to confirm'
              : 'Choose a 4-digit PIN for quick access');

    return BackgroundWrapper(
      child: SafeArea(
        child: SingleChildScrollView(
          // ✅ prevents overflow
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight:
                  screenH - // fill screen height
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              // lets Column use full height
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  if (isLogin) ...[
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        (authProvider.pinUsername ?? 'User')
                          .trim()
                          .split(' ')
                          .where((e) => e.isNotEmpty)
                          .take(2)
                          .map((e) => e[0].toUpperCase())
                          .join(),
                        style: TextStyle(
                          fontSize: AppFontSize.large(context),
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      authProvider.pinUsername ?? '',
                      style: TextStyle(
                        fontSize: AppFontSize.large(context),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  Text(
                    title,
                    style: TextStyle(
                      fontSize: AppFontSize.xl(context),
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: AppFontSize.body(context),
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // PIN dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pinLength, (i) {
                      final filled = i < _entered.length;
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _hasError
                              ? Colors.red.shade400
                              : filled
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.3),
                          border: Border.all(
                            color: _hasError
                                ? Colors.red.shade400
                                : Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 12),

                  // Error message — fixed height so layout stays stable
                  SizedBox(
                    height: 20,
                    child: _hasError
                        ? Text(
                            _errorMessage,
                            style: TextStyle(
                              fontSize: AppFontSize.small(context),
                              color: Colors.red.shade300,
                            ),
                          )
                        : null,
                  ),

                  const Spacer(),

                  // Keypad — fixed size, won't overflow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _keyRow(['1', '2', '3']),
                        const SizedBox(height: 14),
                        _keyRow(['4', '5', '6']),
                        const SizedBox(height: 14),
                        _keyRow(['7', '8', '9']),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (isLogin && authProvider.isBiometricEnabled)
                              _keyBtn(
                                child: Icon(
                                  Icons.fingerprint,
                                  size: 26,
                                  color: Colors.white,
                                ),
                                onTap: () {},
                              )
                            else
                              _keyBtn(
                                child: Text(
                                  '#',
                                  style: TextStyle(
                                    fontSize: AppFontSize.xl(context),
                                    color: Colors.white,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                                onTap: () => _onKey('0'),
                              ),
                            _keyBtn(
                              child: Text(
                                '0',
                                style: TextStyle(
                                  fontSize: AppFontSize.xl(context),
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              onTap: () => _onKey('0'),
                            ),
                            _keyBtn(
                              child: Icon(
                                Icons.backspace_outlined,
                                size: 22,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                              onTap: _onDelete,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (isLogin)
                    GestureDetector(
                      onTap: () => Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.login,
                        (route) => false,
                      ),
                      child: Text(
                        'Use password instead',
                        style: TextStyle(
                          fontSize: AppFontSize.body(context),
                          color: Colors.white.withValues(alpha: 0.65),
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white.withValues(alpha: 0.65),
                        ),
                      ),
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _keyRow(List<String> digits) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    children: digits
        .map(
          (d) => _keyBtn(
            child: Text(
              d,
              style: TextStyle(
                fontSize: AppFontSize.xl(context),
                color: Colors.white,
                fontWeight: FontWeight.w300,
              ),
            ),
            onTap: () => _onKey(d),
          ),
        )
        .toList(),
  );

  Widget _keyBtn({required Widget child, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.1),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Center(child: child),
        ),
      );
}
