import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/auth/screens/pin_screen.dart';
import 'package:profinch_mobile_application/features/auth/screens/pattern_screen.dart';
import 'change_password_screen.dart';

class SecuritySettingsScreen extends StatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  State<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends State<SecuritySettingsScreen> {
  bool twoFactorEnabled = false;
  bool appLockEnabled = true;
  bool transactionPinEnabled = true;
  bool loginAlertsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    // Compute security score based on what's enabled
    int score = 40; // base
    if (authProvider.isPinSet) score += 10;
    if (authProvider.isPatternSet) score += 10;
    if (authProvider.isBiometricEnabled) score += 10;
    if (twoFactorEnabled) score += 15;
    if (transactionPinEnabled) score += 10;
    if (appLockEnabled) score += 5;
    final scoreLabel = score >= 90
        ? 'Excellent'
        : score >= 70
            ? 'Good'
            : score >= 50
                ? 'Fair'
                : 'Weak';
    final scoreColor = score >= 90
        ? Colors.green.shade600
        : score >= 70
            ? Colors.blue.shade600
            : score >= 50
                ? Colors.orange.shade600
                : Colors.red.shade600;

    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Security Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: AppFontSize.large(context),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Security score banner ────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 6,
                          backgroundColor: Colors.grey.shade200,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(scoreColor),
                        ),
                      ),
                      Text('$score',
                          style: TextStyle(
                              color: scoreColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Security Score',
                            style: TextStyle(
                                color: Colors.grey.shade500, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(
                          scoreLabel,
                          style: TextStyle(
                              color: scoreColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          score < 90
                              ? 'Enable more features to improve your score'
                              : 'Your account is fully secured',
                          style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Authentication ───────────────────────────────
            _sectionLabel('AUTHENTICATION', context),
            const SizedBox(height: 10),

            // Biometric — wired to AuthProvider
            _switchTile(
              title: 'Biometric Login',
              subtitle: 'Use fingerprint or Face ID to sign in',
              icon: Icons.fingerprint_rounded,
              iconColor: const Color(0xFF185FA5),
              value: authProvider.isBiometricEnabled,
              onChanged: (v) async {
                if (v) {
                  final available =
                      await authProvider.checkBiometricAvailable();
                  if (!mounted) return;
                  if (!available) {
                    // ignore: use_build_context_synchronously
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content:
                          const Text('Biometric not available on this device'),
                      backgroundColor: Colors.orange.shade700,
                      behavior: SnackBarBehavior.floating,
                    ));
                    return;
                  }
                }
                authProvider.setBiometricEnabled(v);
              },
            ),

            // 2FA
            _switchTile(
              title: 'Two-Factor Authentication',
              subtitle: 'OTP sent to your registered mobile',
              icon: Icons.security_rounded,
              iconColor: const Color(0xFF10B981),
              value: twoFactorEnabled,
              onChanged: (v) {
                setState(() => twoFactorEnabled = v);
                if (v) _show2FASetup(context);
              },
            ),

            // PIN — navigates to real PinScreen
            _actionTile(
              title: 'PIN Login',
              subtitle: authProvider.isPinSet
                  ? '4-digit PIN is set — tap to change'
                  : 'Set a 4-digit PIN for quick access',
              icon: Icons.dialpad_rounded,
              iconColor: const Color(0xFF9B59B6),
              trailing: authProvider.isPinSet
                  ? _badge('Active', Colors.green)
                  : _badge('Not set', Colors.grey),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const PinScreen(mode: PinScreenMode.setup)),
              ),
            ),

            // Pattern — navigates to real PatternScreen
            _actionTile(
              title: 'Pattern Login',
              subtitle: authProvider.isPatternSet
                  ? 'Pattern is set — tap to change'
                  : 'Draw a pattern for quick access',
              icon: Icons.grid_view_rounded,
              iconColor: const Color(0xFF7C3AED),
              trailing: authProvider.isPatternSet
                  ? _badge('Active', Colors.green)
                  : _badge('Not set', Colors.grey),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const PatternScreen(mode: PatternScreenMode.setup)),
              ),
            ),

            // Change password
            _actionTile(
              title: 'Change Password',
              subtitle: 'Update your account login password',
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF0F6E56),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen()),
              ),
            ),

            const SizedBox(height: 24),

            // ── Transaction security ─────────────────────────
            _sectionLabel('TRANSACTION SECURITY', context),
            const SizedBox(height: 10),

            _switchTile(
              title: 'Transaction PIN',
              subtitle: 'Required for every fund transfer',
              icon: Icons.pin_rounded,
              iconColor: const Color(0xFFF59E0B),
              value: transactionPinEnabled,
              onChanged: (v) =>
                  setState(() => transactionPinEnabled = v),
            ),

            _actionTile(
              title: 'Change Transaction PIN',
              subtitle: '6-digit MPIN for payments',
              icon: Icons.lock_rounded,
              iconColor: const Color(0xFF0EA5E9),
              onTap: () =>
                  _showChangePinSheet(context, 'Transaction PIN', 6),
            ),

            _actionTile(
              title: 'Transaction Limits',
              subtitle: 'Daily: ₹1,00,000 per transaction',
              icon: Icons.price_check_rounded,
              iconColor: const Color(0xFFEF4444),
              onTap: () => _showTransactionLimits(context),
            ),

            const SizedBox(height: 24),

            // ── App security ─────────────────────────────────
            _sectionLabel('APP SECURITY', context),
            const SizedBox(height: 10),

            _switchTile(
              title: 'App Lock',
              subtitle: 'Lock app when minimised',
              icon: Icons.lock_outline_rounded,
              iconColor: const Color(0xFF185FA5),
              value: appLockEnabled,
              onChanged: (v) => setState(() => appLockEnabled = v),
            ),

            _switchTile(
              title: 'Login Alerts',
              subtitle: 'Notify on new sign-in attempts',
              icon: Icons.notifications_active_rounded,
              iconColor: const Color(0xFFF59E0B),
              value: loginAlertsEnabled,
              onChanged: (v) =>
                  setState(() => loginAlertsEnabled = v),
            ),

            _actionTile(
              title: 'Blocked Merchants',
              subtitle: 'Manage blocked merchant categories',
              icon: Icons.block_rounded,
              iconColor: const Color(0xFFEF4444),
              onTap: () {},
            ),

            const SizedBox(height: 24),

            // ── Danger zone ──────────────────────────────────
            if (authProvider.isPinSet || authProvider.isPatternSet) ...[
              _sectionLabel('RESET', context),
              const SizedBox(height: 10),

              if (authProvider.isPinSet)
                _actionTile(
                  title: 'Remove PIN',
                  subtitle: 'Disable PIN quick login',
                  icon: Icons.delete_outline_rounded,
                  iconColor: Colors.red.shade600,
                  onTap: () => _confirmRemove(
                    context,
                    title: 'Remove PIN?',
                    message:
                        'You will no longer be able to log in with PIN.',
                    onConfirm: () => authProvider.clearPin(),
                  ),
                ),

              if (authProvider.isPatternSet)
                _actionTile(
                  title: 'Remove Pattern',
                  subtitle: 'Disable pattern quick login',
                  icon: Icons.delete_outline_rounded,
                  iconColor: Colors.red.shade600,
                  onTap: () => _confirmRemove(
                    context,
                    title: 'Remove Pattern?',
                    message:
                        'You will no longer be able to log in with pattern.',
                    onConfirm: () => authProvider.clearPattern(),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────

  Widget _sectionLabel(String label, BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade500,
            fontSize: AppFontSize.xs(context),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      );

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color == Colors.green
                    ? Colors.green.shade700
                    : Colors.grey.shade600)),
      );

  Widget _switchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }

  Widget _actionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Color(0xFF1A1A2E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade500, fontSize: 11)),
                ],
              ),
            ),
            trailing ??
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  // ── Sheets ───────────────────────────────────────────────────

  void _showChangePinSheet(
      BuildContext context, String pinType, int length) {
    final controllers =
        List.generate(length, (_) => TextEditingController());
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Change $pinType',
                style: const TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text('Enter your new $pinType',
                style:
                    TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(length, (i) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: 42,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: TextField(
                    controller: controllers[i],
                    maxLength: 1,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    style: const TextStyle(
                        color: Color(0xFF1A1A2E),
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                    decoration: const InputDecoration(
                        border: InputBorder.none, counterText: ''),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Confirm',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _show2FASetup(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enable 2FA',
                style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(
              'An OTP will be sent to your registered mobile number every time you sign in.',
              style: TextStyle(
                  color: Colors.grey.shade500, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => twoFactorEnabled = false);
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Enable',
                        style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionLimits(BuildContext context) {
    final limits = [
      {'label': 'UPI (per transaction)', 'value': '₹1,00,000', 'icon': Icons.phone_android_rounded},
      {'label': 'NEFT / IMPS (daily)', 'value': '₹5,00,000', 'icon': Icons.swap_horiz_rounded},
      {'label': 'International transfer', 'value': '₹2,00,000', 'icon': Icons.public_rounded},
      {'label': 'ATM withdrawal (daily)', 'value': '₹25,000', 'icon': Icons.atm_rounded},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Transaction Limits',
                style: TextStyle(
                    color: Color(0xFF1A1A2E),
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            ...limits.map((l) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(l['icon'] as IconData,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                          child: Text(l['label'] as String,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13))),
                      Text(l['value'] as String,
                          style: const TextStyle(
                              color: Color(0xFF1A1A2E),
                              fontWeight: FontWeight.w700,
                              fontSize: 14)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _confirmRemove(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: Colors.red.shade50, shape: BoxShape.circle),
              child: Icon(Icons.warning_amber_rounded,
                  color: Colors.red.shade600, size: 26),
            ),
            const SizedBox(height: 14),
            Text(title,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      onConfirm();
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Remove',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}