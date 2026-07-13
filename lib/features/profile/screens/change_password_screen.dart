import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleChange() async {
    final authProvider = context.read<AuthProvider>();
    final current = _currentController.text;
    final newPass = _newController.text;
    final confirm = _confirmController.text;

    if (current.isEmpty || newPass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Please fill in all fields');
      return;
    }

    // Verify current password
    final email = authProvider.currentUser?.email ?? '';
    final valid = authProvider.passwordMatches(email: email, password: current);
    if (!valid) {
      setState(() => _error = 'Current password is incorrect');
      return;
    }

    if (newPass.length < 8) {
      setState(() => _error = 'New password must be at least 8 characters');
      return;
    }

    if (!newPass.contains(RegExp(r'[A-Z]')) ||
        !newPass.contains(RegExp(r'[0-9]'))) {
      setState(() =>
          _error = 'Password must have at least one uppercase letter and number');
      return;
    }

    if (newPass != confirm) {
      setState(() => _error = 'New passwords do not match');
      return;
    }

    if (newPass == current) {
      setState(() =>
          _error = 'New password cannot be the same as current password');
      return;
    }

    setState(() { _isLoading = true; _error = null; });
    await Future.delayed(const Duration(seconds: 1)); // TODO: call Auth Service
    setState(() => _isLoading = false);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password changed successfully!'),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    Navigator.pop(context);
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool show,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: AppFontSize.small(context),
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: !show,
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon: const Icon(Icons.lock_outline,
                color: Colors.grey, size: 20),
            suffixIcon: GestureDetector(
              onTap: onToggle,
              child: Icon(
                show
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
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
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Change Password',
            style:
                TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [

            // Info card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Password must be 8+ characters with at least one uppercase letter and number.',
                      style: TextStyle(
                          fontSize: AppFontSize.small(context),
                          color: AppColors.primaryDark),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _buildField(
                    controller: _currentController,
                    label: 'Current Password',
                    hint: 'Enter current password',
                    show: _showCurrent,
                    onToggle: () =>
                        setState(() => _showCurrent = !_showCurrent),
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: _newController,
                    label: 'New Password',
                    hint: 'Enter new password',
                    show: _showNew,
                    onToggle: () => setState(() => _showNew = !_showNew),
                  ),

                  const SizedBox(height: 16),

                  _buildField(
                    controller: _confirmController,
                    label: 'Confirm New Password',
                    hint: 'Re-enter new password',
                    show: _showConfirm,
                    onToggle: () =>
                        setState(() => _showConfirm = !_showConfirm),
                  ),
                ],
              ),
            ),

            if (_error != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.error_outline,
                      size: 15, color: Colors.red.shade600),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_error!,
                        style: TextStyle(
                            fontSize: AppFontSize.small(context),
                            color: Colors.red.shade600)),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 28),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleChange,
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
                    : const Text('Update Password',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}