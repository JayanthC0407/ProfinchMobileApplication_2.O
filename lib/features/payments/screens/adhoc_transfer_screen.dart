import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/beneficiary_model.dart';
import 'package:profinch_mobile_application/features/transfers/screens/transfer_confirmation_screen.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/transfers/widgets/account_selector_widget.dart';
import 'package:profinch_mobile_application/features/transfers/widgets/amount_input_card.dart';
import 'package:provider/provider.dart';

/// Adhoc transfer — send money without saving a beneficiary.
/// The receiver details are typed manually. Reuses the existing
/// TransferConfirmationScreen by constructing a temporary BeneficiaryModel.
class AdhocTransferScreen extends StatefulWidget {
  const AdhocTransferScreen({super.key});

  @override
  State<AdhocTransferScreen> createState() => _AdhocTransferScreenState();
}

class _AdhocTransferScreenState extends State<AdhocTransferScreen> {
  final _nameCtrl    = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _bankCtrl    = TextEditingController();
  final _ifscCtrl    = TextEditingController();
  final _amountCtrl  = TextEditingController();
  final _remarksCtrl = TextEditingController();

  String _transferMode = 'NEFT';
  String? _selectedAccountId;

  String? _nameError;
  String? _accountError;
  String? _bankError;
  String? _ifscError;
  String? _amountError;
  String? _fromAccountError;

  static const _modes = ['NEFT', 'RTGS', 'IMPS'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _accountCtrl.dispose();
    _bankCtrl.dispose();
    _ifscCtrl.dispose();
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameError    = _nameCtrl.text.trim().isEmpty ? 'Enter receiver name' : null;
      _accountError = _accountCtrl.text.trim().isEmpty ? 'Enter account number' : null;
      _bankError    = _bankCtrl.text.trim().isEmpty ? 'Enter bank name' : null;
      _ifscError    = _ifscCtrl.text.trim().isEmpty ? 'Enter IFSC code' : null;
      _amountError  = _amountCtrl.text.trim().isEmpty ? 'Enter amount' : null;
      _fromAccountError = _selectedAccountId == null ? 'Select a debit account' : null;
    });
    return [_nameError, _accountError, _bankError, _ifscError,
            _amountError, _fromAccountError].every((e) => e == null);
  }

  void _proceed() {
    if (!_validate()) return;

    // Build a temporary beneficiary — id starts with 'ADHOC_' to distinguish
    final tempBeneficiary = BeneficiaryModel(
      id: 'ADHOC_${DateTime.now().millisecondsSinceEpoch}',
      userId: Provider.of<AuthProvider>(context, listen: false).currentUser!.id,
      nickname: _nameCtrl.text.trim(),
      beneficiaryType: 'LOCAL',
      accountNumber: _accountCtrl.text.trim(),
      bankName: _bankCtrl.text.trim(),
      ifscCode: _ifscCtrl.text.trim(),
      isVerified: false,
      addedAt: DateTime(2000), // no cooling on adhoc
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransferConfirmationScreen(
          beneficiary: tempBeneficiary,
          accountId: _selectedAccountId!,
          amount: double.parse(_amountCtrl.text.trim()),
          remarks: _remarksCtrl.text.trim(),
          transferMode: _transferMode,
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    String? hint,
    String? error,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(),
            style: AppTextStyles.caption(context).copyWith(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: AppColors.textPrimary,
            )),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: AppColors.light,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: error != null ? AppColors.error : AppColors.grey300),
          ),
          child: TextField(
            controller: ctrl,
            keyboardType: keyboard,
            style: AppTextStyles.body(context),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body(context, color: AppColors.grey400),
              prefixIcon: Icon(icon, color: AppColors.grey400, size: 18),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 5, left: 4),
            child: Text(error,
                style: AppTextStyles.small(context, color: AppColors.error)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final accounts = Provider.of<AccountProvider>(context)
        .getAccountsByUserId(
            Provider.of<AuthProvider>(context).currentUser!.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: AppColors.light,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.light,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _proceed,
              child: Text('Proceed to Confirm',
                  style: AppTextStyles.labelBold(context,
                      color: AppColors.light)),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Header ─────────────────────────────────────────────
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.blueButton],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 4, 8, 0),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.light),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Text('Adhoc Transfer',
                        style: AppTextStyles.whiteHeading(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      'Send money without saving a beneficiary',
                      style: AppTextStyles.whiteBody(context,
                          color: AppColors.light.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Form ───────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount card
                  AmountInputCard(controller: _amountCtrl),
                  if (_amountError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(_amountError!,
                          style: AppTextStyles.small(context,
                              color: AppColors.error)),
                    ),

                  const SizedBox(height: 16),

                  // Receiver details card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.light,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Receiver Details',
                            style: AppTextStyles.title(context)),
                        const SizedBox(height: 16),
                        _field(
                          ctrl: _nameCtrl,
                          label: 'Receiver Name',
                          icon: Icons.person_outline,
                          hint: 'e.g. Rahul Mehta',
                          error: _nameError,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          ctrl: _accountCtrl,
                          label: 'Account Number',
                          icon: Icons.credit_card_outlined,
                          hint: 'Enter account number',
                          error: _accountError,
                          keyboard: TextInputType.number,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          ctrl: _bankCtrl,
                          label: 'Bank Name',
                          icon: Icons.account_balance_outlined,
                          hint: 'e.g. HDFC Bank',
                          error: _bankError,
                        ),
                        const SizedBox(height: 14),
                        _field(
                          ctrl: _ifscCtrl,
                          label: 'IFSC Code',
                          icon: Icons.tag_outlined,
                          hint: 'e.g. HDFC0001234',
                          error: _ifscError,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Transfer mode + from account
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.light,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Transfer Details',
                            style: AppTextStyles.title(context)),
                        const SizedBox(height: 16),

                        // Transfer mode chips
                        Text('Transfer Mode'.toUpperCase(),
                            style: AppTextStyles.caption(context).copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: AppColors.textPrimary,
                            )),
                        const SizedBox(height: 8),
                        Row(
                          children: _modes.map((mode) {
                            final selected = _transferMode == mode;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GestureDetector(
                                onTap: () =>
                                    setState(() => _transferMode = mode),
                                child: AnimatedContainer(
                                  duration:
                                      const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 18, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.surfaceLight,
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.grey300,
                                    ),
                                  ),
                                  child: Text(
                                    mode,
                                    style: AppTextStyles.smallBold(context,
                                        color: selected
                                            ? AppColors.light
                                            : AppColors.textPrimary),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // From account
                        Text('Debit From'.toUpperCase(),
                            style: AppTextStyles.caption(context).copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: AppColors.textPrimary,
                            )),
                        const SizedBox(height: 8),
                        AccountSelectorWidget(
                          accounts: accounts,
                          selectedAccountId: _selectedAccountId,
                          onChanged: (v) =>
                              setState(() => _selectedAccountId = v),
                        ),
                        if (_fromAccountError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(_fromAccountError!,
                                style: AppTextStyles.small(context,
                                    color: AppColors.error)),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Remarks
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: AppColors.light,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.grey200),
                    ),
                    child: _field(
                      ctrl: _remarksCtrl,
                      label: 'Remarks (Optional)',
                      icon: Icons.notes_outlined,
                      hint: 'Add a note...',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Info banner
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline,
                            size: 16, color: AppColors.warningDark),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Adhoc transfers are not saved as beneficiaries. '
                            'Verify all details carefully before confirming.',
                            style: AppTextStyles.small(context,
                                color: AppColors.warningDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}