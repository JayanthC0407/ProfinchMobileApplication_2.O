import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../../../data/models/insurance_model.dart';
import '../widgets/insurance_step_indicator.dart';
import 'buy_insurance_payment_screen.dart';

class BuyInsuranceNomineeScreen extends StatefulWidget {
  final InsuranceTypeConfig typeConfig;
  final InsurancePlanConfig planConfig;
  final String holderName;
  final String holderDob;
  final String debitAccountId;

  const BuyInsuranceNomineeScreen({
    super.key,
    required this.typeConfig,
    required this.planConfig,
    required this.holderName,
    required this.holderDob,
    required this.debitAccountId,
  });

  @override
  State<BuyInsuranceNomineeScreen> createState() => _BuyInsuranceNomineeScreenState();
}

class _BuyInsuranceNomineeScreenState extends State<BuyInsuranceNomineeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _dobCtrl    = TextEditingController();
  final _mobileCtrl = TextEditingController();
  String? _relationship;

  final _relationships = ['Husband', 'Wife', 'Father', 'Mother', 'Son', 'Daughter', 'Sibling', 'Other'];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dobCtrl.dispose();
    _mobileCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('Buy ${widget.typeConfig.name}',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: InsuranceStepIndicator(current: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Nominee Details',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 20),

              _inputField(
                controller: _nameCtrl,
                label: 'Nominee Name',
                hint: 'Enter full name',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Relationship dropdown
              DropdownButtonFormField<String>(
                value: _relationship,
                items: _relationships.map((r) => DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 14)))).toList(),
                onChanged: (v) => setState(() => _relationship = v),
                validator: (v) => v == null ? 'Select relationship' : null,
                decoration: _dropdownDecoration('Relationship'),
              ),
              const SizedBox(height: 16),

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
                    lastDate: DateTime.now(),
                    builder: (context, child) => Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(primary: AppColors.primaryDark)),
                      child: child!,
                    ),
                  );
                  if (picked != null) _dobCtrl.text = '${picked.day.toString().padLeft(2, '0')} ${_month(picked.month)} ${picked.year}';
                },
                validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _mobileCtrl.text.isEmpty ? null : _mobileCtrl.text,
                items: const [],
                onChanged: null,
                decoration: _dropdownDecoration('Mobile Number'),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: _mobileCtrl,
                keyboardType: TextInputType.phone,
                maxLength: 10,
                validator: (v) => (v == null || v.length < 10) ? 'Enter valid mobile' : null,
                decoration: InputDecoration(
                  hintText: '10-digit mobile number',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryDark)),
                  errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => BuyInsurancePaymentScreen(
                      typeConfig:      widget.typeConfig,
                      planConfig:      widget.planConfig,
                      holderName:      widget.holderName,
                      holderDob:       widget.holderDob,
                      debitAccountId:  widget.debitAccountId,
                      nomineeName:     _nameCtrl.text.trim(),
                      nomineeRelationship: _relationship!,
                      nomineeDoB:      _dobCtrl.text,
                      nomineeMobile:   _mobileCtrl.text.trim(),
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

  InputDecoration _dropdownDecoration(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primaryDark)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.red)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );

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

  String _month(int m) => ['', 'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m];
}