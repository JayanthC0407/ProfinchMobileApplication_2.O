import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/core/network/api_exception.dart';
import 'package:profinch_mobile_application/data/repositories/registration_repository.dart';
import 'package:profinch_mobile_application/shared/widgets/background_wrapper.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_up_widgets/signup_button.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_up_widgets/personal_info_step.dart';
import 'package:profinch_mobile_application/features/auth/widgets/sign_up_widgets/account_info_step.dart';
import 'package:profinch_mobile_application/shared/widgets/security_badge.dart';

/// Registration, as a 2-step wizard rather than one long scrolling form —
/// Step 1: Personal Information, Step 2: Account Information. Each step
/// validates independently before advancing, so errors surface as you go
/// rather than all at once at the bottom of a long page.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const int _totalSteps = 2;
  int _currentStep = 0;

  final _personalFormKey = GlobalKey<FormState>();
  final _accountFormKey = GlobalKey<FormState>();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _partyIdController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _debitCardNumberController = TextEditingController();

  final _repository = RegistrationRepository();

  DateTime? _dateOfBirth;
  List<String> _accountTypes = [];
  bool _isLoadingAccountTypes = true;
  String? _selectedAccountType;
  bool _termsAccepted = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAccountTypes();
  }

  Future<void> _loadAccountTypes() async {
    try {
      final types = await _repository.getAccountTypes();
      if (!mounted) return;
      setState(() {
        _accountTypes = types;
        _isLoadingAccountTypes = false;
      });
    } catch (_) {
      if (!mounted) return;
      // Non-fatal — the dropdown just shows empty and the form validator
      // will catch it if the person tries to submit without a selection.
      // See RegistrationRepository.getAccountTypes doc: this response
      // shape is unconfirmed, so a parsing miss here is expected until
      // verified against a live call.
      setState(() => _isLoadingAccountTypes = false);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _partyIdController.dispose();
    _accountNumberController.dispose();
    _debitCardNumberController.dispose();
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
    setState(() => _dateOfBirth = picked);
  }

  String _formatDob(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ── Step navigation ────────────────────────────────────────────
  void _handleBack() {
    if (_currentStep == 0) {
      Navigator.pop(context);
      return;
    }
    setState(() => _currentStep -= 1);
  }

  void _handleContinueFromPersonal() {
    if (!_personalFormKey.currentState!.validate()) return;
    if (_dateOfBirth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your date of birth')),
      );
      return;
    }
    setState(() => _currentStep = 1);
  }

  // ── Submit ─────────────────────────────────────────────────────
  Future<void> _handleSignUp() async {
    if (!_accountFormKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms and Conditions'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final registrationId = await _repository.submit(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        emailId: _emailController.text.trim(),
        partyId: _partyIdController.text.trim(),
        dateOfBirth: _formatDob(_dateOfBirth!),
        accountType: _selectedAccountType!,
        accountNumber: _accountNumberController.text.trim(),
        debitCardNumber: _debitCardNumberController.text.trim(),
      );

      // Confirms/activates the registration. Uses the sandbox-hardcoded
      // token_id ('1111') from the Postman collection's pre-request
      // script — there's no real verification-code entry step here since
      // OBDX doesn't appear to surface one for the app to collect yet.
      // Swap this for a real code-entry UI once that's available.
      await _repository.confirmAuthentication(registrationId: registrationId);

      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account created successfully!'),
          backgroundColor: const Color(0xFF0F6E56),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );

      Navigator.pop(context); // back to login
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    }
  }

  // ── Step chrome ────────────────────────────────────────────────
  String get _stepTitle =>
      _currentStep == 0 ? 'Personal Information' : 'Account Information';

  Widget _stepProgress() {
    return Row(
      children: List.generate(_totalSteps, (i) {
        final isActive = i <= _currentStep;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i == _totalSteps - 1 ? 0 : 6),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.light.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
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
                  onTap: _handleBack,
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
                const SizedBox(height: 20),

                // ── Step progress ─────────────────────────────────
                _stepProgress(),
                const SizedBox(height: 8),
                Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: TextStyle(
                    fontSize: AppFontSize.small(context),
                    color: AppColors.light.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Heading ───────────────────────────────────────
                Text(
                  _stepTitle,
                  style: TextStyle(
                    fontSize: AppFontSize.xxl(context),
                    fontWeight: FontWeight.w700,
                    color: AppColors.light,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _currentStep == 0
                      ? "Let's start with a few details about you"
                      : 'Now, tell us about your existing account',
                  style: AppTextStyles.whiteBody(context),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fields marked * are required',
                  style: TextStyle(
                    fontSize: AppFontSize.small(context),
                    color: AppColors.light.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 24),

                // ── Step content ───────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.03, 0),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  ),
                  child: _currentStep == 0
                      ? PersonalInfoStep(
                          key: const ValueKey('step-personal'),
                          formKey: _personalFormKey,
                          firstNameController: _firstNameController,
                          lastNameController: _lastNameController,
                          emailController: _emailController,
                          dateOfBirth: _dateOfBirth,
                          onPickDateOfBirth: _pickDateOfBirth,
                        )
                      : AccountInfoStep(
                          key: const ValueKey('step-account'),
                          formKey: _accountFormKey,
                          partyIdController: _partyIdController,
                          accountNumberController: _accountNumberController,
                          debitCardNumberController:
                              _debitCardNumberController,
                          accountTypes: _accountTypes,
                          isLoadingAccountTypes: _isLoadingAccountTypes,
                          selectedAccountType: _selectedAccountType,
                          onAccountTypeChanged: (v) =>
                              setState(() => _selectedAccountType = v),
                          termsAccepted: _termsAccepted,
                          onTermsChanged: (v) =>
                              setState(() => _termsAccepted = v ?? false),
                        ),
                ),
                const SizedBox(height: 28),

                // ── Step action(s) ─────────────────────────────────
                if (_currentStep == 0)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _handleContinueFromPersonal,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryDark,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Continue',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w500)),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _handleBack,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.light,
                              side: BorderSide(
                                  color: AppColors.light.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text('Back',
                                style: TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.w500)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: SignUpButton(
                          isLoading: _isLoading,
                          onPressed: _handleSignUp,
                        ),
                      ),
                    ],
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