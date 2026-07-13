import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/beneficiary_model.dart';
import 'package:profinch_mobile_application/features/Beneficiaries/provider/beneficiary_provider.dart';
import 'package:provider/provider.dart';

class EditBeneficiaryScreen extends StatefulWidget {
  final BeneficiaryModel beneficiary;

  const EditBeneficiaryScreen({super.key, required this.beneficiary});

  @override
  State<EditBeneficiaryScreen> createState() => _EditBeneficiaryScreenState();
}

class _EditBeneficiaryScreenState extends State<EditBeneficiaryScreen> {
  late final TextEditingController _nicknameCtrl;
  late final TextEditingController _accountCtrl;
  late final TextEditingController _bankCtrl;
  late final TextEditingController _ifscCtrl;
  late final TextEditingController _countryCtrl;
  late final TextEditingController _ibanCtrl;
  late final TextEditingController _swiftCtrl;

  String? _nicknameError;
  String? _accountError;
  String? _bankError;
  String? _ifscError;
  String? _countryError;
  String? _ibanError;
  String? _swiftError;

  @override
  void initState() {
    super.initState();
    final b = widget.beneficiary;
    _nicknameCtrl = TextEditingController(text: b.nickname);
    _accountCtrl  = TextEditingController(text: b.accountNumber);
    _bankCtrl     = TextEditingController(text: b.bankName);
    _ifscCtrl     = TextEditingController(text: b.ifscCode);
    _countryCtrl  = TextEditingController(text: b.country ?? '');
    _ibanCtrl     = TextEditingController(text: b.ibanNumber ?? '');
    _swiftCtrl    = TextEditingController(text: b.swiftCode ?? '');
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _accountCtrl.dispose();
    _bankCtrl.dispose();
    _ifscCtrl.dispose();
    _countryCtrl.dispose();
    _ibanCtrl.dispose();
    _swiftCtrl.dispose();
    super.dispose();
  }

  String get _type => widget.beneficiary.beneficiaryType;

  bool _validate() {
    setState(() {
      _nicknameError = _nicknameCtrl.text.trim().isEmpty
          ? 'Please enter a nickname' : null;
      _accountError  = _accountCtrl.text.trim().isEmpty
          ? 'Please enter account number' : null;
      _bankError = (_type != 'PBI' && _bankCtrl.text.trim().isEmpty)
          ? 'Please enter bank name' : null;
      _ifscError = (_type == 'LOCAL' && _ifscCtrl.text.trim().isEmpty)
          ? 'Please enter IFSC code' : null;
      _countryError = (_type == 'INTERNATIONAL' &&
              _countryCtrl.text.trim().isEmpty)
          ? 'Please enter country' : null;
      _ibanError = (_type == 'INTERNATIONAL' && _ibanCtrl.text.trim().isEmpty)
          ? 'Please enter IBAN' : null;
      _swiftError = (_type == 'INTERNATIONAL' && _swiftCtrl.text.trim().isEmpty)
          ? 'Please enter SWIFT code' : null;
    });

    return [
      _nicknameError, _accountError, _bankError,
      _ifscError, _countryError, _ibanError, _swiftError,
    ].every((e) => e == null);
  }

  void _save() {
    if (!_validate()) return;

    Provider.of<BeneficiaryProvider>(context, listen: false).editBeneficiary(
      widget.beneficiary.id,
      nickname: _nicknameCtrl.text.trim(),
      accountNumber: _accountCtrl.text.trim(),
      bankName: _bankCtrl.text.trim(),
      ifscCode: _ifscCtrl.text.trim(),
      ibanNumber: _ibanCtrl.text.trim().isEmpty ? null : _ibanCtrl.text.trim(),
      swiftCode: _swiftCtrl.text.trim().isEmpty ? null : _swiftCtrl.text.trim(),
      country: _countryCtrl.text.trim().isEmpty ? null : _countryCtrl.text.trim(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Beneficiary updated'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? errorText,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTextStyles.caption(context).copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? AppColors.surfaceLight : AppColors.light,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText != null
                  ? AppColors.error
                  : AppColors.grey300,
            ),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            style: AppTextStyles.body(context),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.body(context,
                  color: AppColors.grey400),
              prefixIcon:
                  Icon(icon, color: AppColors.grey400, size: 18),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 14),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(errorText,
                style: AppTextStyles.small(context,
                    color: AppColors.error)),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onPressed: _save,
              child: Text('Save Changes',
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
                    child: Text(
                      'Edit Beneficiary',
                      style: AppTextStyles.whiteHeading(context),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: Text(
                      'Update details for ${widget.beneficiary.nickname}',
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
              padding: const EdgeInsets.all(20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.light,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  children: [
                    // Type badge — read-only, shown for context
                    Row(
                      children: [
                        Text('Type  ', style: AppTextStyles.bodySecondary(context)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(_type,
                              style: AppTextStyles.smallBold(context,
                                  color: AppColors.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _field(
                      controller: _nicknameCtrl,
                      label: 'Nickname',
                      icon: Icons.badge_outlined,
                      hint: 'e.g. John Doe',
                      errorText: _nicknameError,
                    ),
                    const SizedBox(height: 16),
                    _field(
                      controller: _accountCtrl,
                      label: 'Account Number',
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      hint: 'Enter account number',
                      errorText: _accountError,
                    ),

                    if (_type != 'PBI') ...[
                      const SizedBox(height: 16),
                      _field(
                        controller: _bankCtrl,
                        label: 'Bank Name',
                        icon: Icons.account_balance_outlined,
                        hint: 'e.g. HDFC Bank',
                        errorText: _bankError,
                      ),
                    ],

                    if (_type == 'LOCAL') ...[
                      const SizedBox(height: 16),
                      _field(
                        controller: _ifscCtrl,
                        label: 'IFSC Code',
                        icon: Icons.tag_outlined,
                        hint: 'e.g. HDFC0001234',
                        errorText: _ifscError,
                      ),
                    ],

                    if (_type == 'INTERNATIONAL') ...[
                      const SizedBox(height: 16),
                      _field(
                        controller: _countryCtrl,
                        label: 'Country',
                        icon: Icons.public_outlined,
                        hint: 'e.g. United States',
                        errorText: _countryError,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: _ibanCtrl,
                        label: 'IBAN Number',
                        icon: Icons.numbers_outlined,
                        hint: 'e.g. GB29 NWBK 6016 1331 9268 19',
                        errorText: _ibanError,
                      ),
                      const SizedBox(height: 16),
                      _field(
                        controller: _swiftCtrl,
                        label: 'SWIFT Code',
                        icon: Icons.swap_horiz_outlined,
                        hint: 'e.g. CITIUS33',
                        errorText: _swiftError,
                      ),
                    ],

                    const SizedBox(height: 8),

                    // Note about addedAt preservation
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 16, color: AppColors.warningDark),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'A 30-second cooling period applies after saving edits.',
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
          ),
        ],
      ),
    );
  }
}