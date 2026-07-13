import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/features/dashboard/provider/dashboard_provider.dart';
import 'package:provider/provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../../data/dummy/dummy_accounts.dart';

import 'dart:io';    
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  String? selectedPrimaryAccountId;
  bool _isSaving = false;
  Uint8List? _pickedImageBytes;

  @override
  void initState() {
    super.initState();
    final user =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;
    usernameController = TextEditingController(text: user.username);
    emailController = TextEditingController(text: user.email);
    phoneController = TextEditingController(text: user.phoneNumber);
    selectedPrimaryAccountId = user.primaryAccountId;
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  //add profile image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() => _pickedImageBytes = bytes);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final updatedUser = authProvider.currentUser!.copyWith(
      username: usernameController.text.trim(),
      email: emailController.text.trim(),
      phoneNumber: phoneController.text.trim(),
      primaryAccountId: selectedPrimaryAccountId,
    );

    authProvider.updateUser(updatedUser);
    if (_pickedImageBytes != null) {
      authProvider.updateProfileImageBytes(_pickedImageBytes!);  // ← add this
    }

    authProvider.updateUser(updatedUser);
    Provider.of<DashboardProvider>(context, listen: false)
        .resetToPrimary(selectedPrimaryAccountId!);

    if (mounted) {
      setState(() => _isSaving = false);
      _showSuccessSnackbar();
      Navigator.pop(context);
    }
  }

  void _showSuccessSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.light,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Color(0xFF4CD964)),
            SizedBox(width: 10),
            Text('Profile updated successfully',
                style: TextStyle(color: Colors.black)),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;
    final accounts = DummyAccounts.allAccounts
        .where((a) => a.userId == user.id)
        .toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.lightBlue,
        appBar: AppBar(
          backgroundColor: AppColors.lightBlue,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.light,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.black, size: 18),
            ),
          ),
          title: Text(
            'Edit Profile',
            style: TextStyle(
              color: Colors.black,
              fontSize: AppFontSize.large(context),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Avatar section ─────────────────────────────
                //updated to add profile image
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Stack(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.light,
                          border: Border.all(color: const Color(0xFF4A90D9), width: 2),
                        ),
                        child: ClipOval(
                          child: _pickedImageBytes != null
                              ? Image.memory(_pickedImageBytes!, fit: BoxFit.cover, width: 90, height: 90)
                              : (user.profileImage.isNotEmpty
                                  ? Image.asset(
                                      user.profileImage,
                                      fit: BoxFit.cover,
                                      width: 90,
                                      height: 90,
                                      errorBuilder: (_, __, ___) => const Icon(
                                          Icons.person_rounded, size: 48, color: Color(0xFF4A90D9)),
                                    )
                                  : const Icon(Icons.person_rounded, size: 48, color: Color(0xFF4A90D9))),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90D9),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.lightBlue, width: 2),
                          ),
                          child: const Icon(Icons.camera_alt_rounded, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

                const SizedBox(height: 8),

                Center(
                  child: GestureDetector(
                  onTap: _pickImage,
                  child: Text(
                    'Tap to change photo',
                    style: TextStyle(
                      color: const Color(0xFF4A90D9),
                      fontSize: AppFontSize.xs(context),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // ── Form fields ────────────────────────────────
                _sectionLabel('PERSONAL DETAILS', context),
                const SizedBox(height: 12),

                _buildField(
                  controller: usernameController,
                  label: 'Full Name',
                  icon: Icons.person_rounded,
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Name cannot be empty'
                      : null,
                ),

                const SizedBox(height: 12),

                _buildField(
                  controller: emailController,
                  label: 'Email Address',
                  icon: Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Email cannot be empty';
                    }
                    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(v.trim())) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                _buildField(
                  controller: phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone_rounded,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Phone cannot be empty';
                    }
                    if (v.trim().length < 10) {
                      return 'Enter a valid 10-digit number';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                _sectionLabel('PRIMARY ACCOUNT', context),
                const SizedBox(height: 12),

                // ── Account dropdown ───────────────────────────
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.light,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: DropdownButtonFormField<String>(
                    value: selectedPrimaryAccountId,
                    isExpanded: true,
                    dropdownColor: AppColors.light,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: AppFontSize.body(context),
                      fontWeight: FontWeight.w500,
                    ),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF4A90D9)),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(
                          Icons.account_balance_rounded,
                          color: Color(0xFF4A90D9),
                          size: 20),
                      labelText: 'Select Primary Account',
                      labelStyle: TextStyle(
                        color: const Color(0xFF8A9BB5),
                        fontSize: AppFontSize.small(context),
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    items: accounts.map((account) {
                      return DropdownMenuItem(
                        value: account.id,
                        child: Text(
                          '${account.accountType}  •  ••••${account.accountNumber.substring(account.accountNumber.length - 4)}',
                          style: const TextStyle(color: Colors.black),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => selectedPrimaryAccountId = value),
                  ),
                ),

                const SizedBox(height: 8),

                // ── Info note ──────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: const Color(0xFF4A90D9).withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFF4A90D9), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your primary account is used for salary credits and default transactions.',
                          style: TextStyle(
                            color: const Color(0xFF8A9BB5),
                            fontSize: AppFontSize.xs(context),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // ── Save button ────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
                      foregroundColor: AppColors.light,
                      disabledBackgroundColor:
                          const Color(0xFF4A90D9).withValues(alpha: 0.5),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.light,
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: AppFontSize.medium(context),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label, BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        color: const Color(0xFF8A9BB5),
        fontSize: AppFontSize.xs(context),
        fontWeight: FontWeight.w600,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        color: Colors.black,
        fontSize: AppFontSize.body(context),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: const Color(0xFF8A9BB5),
          fontSize: AppFontSize.small(context),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF4A90D9), size: 20),
        filled: true,
        fillColor: AppColors.light,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:  BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFF4A90D9), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE53935), width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFE53935), width: 1.5),
        ),
        errorStyle: const TextStyle(color: Color(0xFFE53935)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}