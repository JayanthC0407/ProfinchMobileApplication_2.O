import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import '../../../data/models/insurance_model.dart';
import '../widgets/insurance_step_indicator.dart';
import 'buy_insurance_nominee_screen.dart';

class BuyInsuranceFillScreen extends StatefulWidget {
  final InsuranceTypeConfig typeConfig;
  final InsurancePlanConfig planConfig;

  const BuyInsuranceFillScreen({
    super.key,
    required this.typeConfig,
    required this.planConfig,
  });

  @override
  State<BuyInsuranceFillScreen> createState() => _BuyInsuranceFillScreenState();
}

class _BuyInsuranceFillScreenState extends State<BuyInsuranceFillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _dobCtrl   = TextEditingController();
  String? _selectedAccountId;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    final accountProvider = context.read<AccountProvider>();
    final accounts = accountProvider.getAccountsByUserId(user.id);
    final moneyFmt = NumberFormat('#,##,##0', 'en_IN');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Buy ${widget.typeConfig.name}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: InsuranceStepIndicator(current: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Selected Plan tile ────────────────────────
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Select Plan', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                      const SizedBox(height: 2),
                      Text(widget.planConfig.name,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 2),
                      Text(
                        'Coverage  ₹${moneyFmt.format(widget.planConfig.coverageAmount)}   '
                        'Premium  ₹${moneyFmt.format(widget.planConfig.premiumAmount)} / month',
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ]),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Change', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Debit Account ─────────────────────────────
              _label('Select Debit Account'),
              const SizedBox(height: 8),
              ...accounts.map((acc) {
                final isSelected = _selectedAccountId == acc.id;
                return GestureDetector(
                  onTap: () => setState(() => _selectedAccountId = acc.id),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryDark : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.account_balance_outlined, color: AppColors.primaryDark, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('${acc.accountType}  XXXX ${acc.accountNumber.substring(acc.accountNumber.length - 4)}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                            Text('₹${moneyFmt.format(acc.availableBalance)}',
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ]),
                        ),
                        if (isSelected) Icon(Icons.check_circle, color: AppColors.primaryDark, size: 20),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // ── Policy holder details ─────────────────────
              _label('Policy Holder Details'),
              const SizedBox(height: 12),

              _inputField(
                controller: _nameCtrl,
                label: 'Full Name',
                hint: 'Enter full name',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              _inputField(
                controller: _dobCtrl,
                label: 'Date of Birth',
                hint: 'DD MMM YYYY',
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(1990),
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(primary: AppColors.primaryDark),
                      ),
                      child: child!,
                    ),
                  );
                  if (picked != null) {
                    _dobCtrl.text = DateFormat('dd MMM yyyy').format(picked);
                  }
                },
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  if (_selectedAccountId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please select a debit account')));
                    return;
                  }
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BuyInsuranceNomineeScreen(
                      typeConfig:       widget.typeConfig,
                      planConfig:       widget.planConfig,
                      holderName:       _nameCtrl.text.trim(),
                      holderDob:        _dobCtrl.text,
                      debitAccountId:   _selectedAccountId!,
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)));

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryDark)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}