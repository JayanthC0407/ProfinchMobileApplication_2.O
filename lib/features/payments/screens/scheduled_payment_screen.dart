import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/beneficiary_model.dart';
import 'package:profinch_mobile_application/data/models/payment_model.dart';
import 'package:profinch_mobile_application/features/Beneficiaries/provider/beneficiary_provider.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/payments/provider/payment_provider.dart';
import 'package:profinch_mobile_application/features/transfers/widgets/account_selector_widget.dart';
import 'package:profinch_mobile_application/features/transfers/widgets/amount_input_card.dart';
import 'package:provider/provider.dart';

class ScheduledPaymentScreen extends StatefulWidget {
  const ScheduledPaymentScreen({super.key});

  @override
  State<ScheduledPaymentScreen> createState() =>
      _ScheduledPaymentScreenState();
}

class _ScheduledPaymentScreenState extends State<ScheduledPaymentScreen> {
  final _amountCtrl  = TextEditingController();
  final _remarksCtrl = TextEditingController();

  BeneficiaryModel? _selectedBeneficiary;
  String? _selectedAccountId;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  RepeatInterval _repeat = RepeatInterval.once;

  String? _beneficiaryError;
  String? _amountError;
  String? _accountError;

  static const _repeatLabels = {
    RepeatInterval.once:    'Once',
    RepeatInterval.daily:   'Daily',
    RepeatInterval.weekly:  'Weekly',
    RepeatInterval.monthly: 'Monthly',
  };

  @override
  void dispose() {
    _amountCtrl.dispose();
    _remarksCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme:
              const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  bool _validate() {
    setState(() {
      _beneficiaryError =
          _selectedBeneficiary == null ? 'Select a beneficiary' : null;
      _amountError = _amountCtrl.text.trim().isEmpty
          ? 'Enter amount'
          : double.tryParse(_amountCtrl.text.trim()) == null
              ? 'Invalid amount'
              : null;
      _accountError =
          _selectedAccountId == null ? 'Select a debit account' : null;
    });
    return [_beneficiaryError, _amountError, _accountError]
        .every((e) => e == null);
  }

  void _schedule() {
    if (!_validate()) return;
    final user =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;
    final b = _selectedBeneficiary!;

    Provider.of<PaymentProvider>(context, listen: false).addPayment(
      PaymentModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.id,
        fromAccountId: _selectedAccountId!,
        beneficiaryId: b.id,
        receiverName: b.nickname,
        receiverAccount: b.accountNumber,
        receiverBank: b.bankName,
        ifscCode: b.ifscCode,
        transferMode: b.beneficiaryType,
        amount: double.parse(_amountCtrl.text.trim()),
        remarks: _remarksCtrl.text.trim(),
        scheduledDate: _scheduledDate,
        repeat: _repeat,
        createdAt: DateTime.now(),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Payment to ${b.nickname} scheduled for '
          '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/'
      '${d.year}';

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;
    final beneficiaries = Provider.of<BeneficiaryProvider>(context)
        .getBeneficiariesByUserId(user.id)
        .where((b) => b.isTransferAllowed)
        .toList();
    final accounts = Provider.of<AccountProvider>(context)
        .getAccountsByUserId(user.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: AppColors.light,
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.light,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: _schedule,
              icon: const Icon(Icons.schedule_rounded, size: 18),
              label: Text('Schedule Payment',
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
                    child: Text('Schedule Payment',
                        style: AppTextStyles.whiteHeading(context)),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      'Set up a one-time or recurring transfer',
                      style: AppTextStyles.whiteBody(context,
                          color: AppColors.light.withValues(alpha: 0.7)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Amount
                  AmountInputCard(controller: _amountCtrl),
                  if (_amountError != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, left: 4),
                      child: Text(_amountError!,
                          style: AppTextStyles.small(context,
                              color: AppColors.error)),
                    ),

                  const SizedBox(height: 16),

                  // Beneficiary picker
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
                        Text('Pay To', style: AppTextStyles.title(context)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _beneficiaryError != null
                                  ? AppColors.error
                                  : AppColors.grey300,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<BeneficiaryModel>(
                              value: _selectedBeneficiary,
                              isExpanded: true,
                              hint: Text('Select beneficiary',
                                  style: AppTextStyles.body(context,
                                      color: AppColors.grey400)),
                              icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.primary),
                              items: beneficiaries
                                  .map((b) => DropdownMenuItem(
                                        value: b,
                                        child: Text(
                                          '${b.nickname}  ••••${b.accountNumber.substring(b.accountNumber.length - 4)}',
                                          style: AppTextStyles.body(context),
                                        ),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedBeneficiary = v),
                            ),
                          ),
                        ),
                        if (_beneficiaryError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(_beneficiaryError!,
                                style: AppTextStyles.small(context,
                                    color: AppColors.error)),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date + Repeat + From account
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
                        Text('Schedule Details',
                            style: AppTextStyles.title(context)),
                        const SizedBox(height: 16),

                        // Date
                        Text('SCHEDULED DATE',
                            style: AppTextStyles.caption(context).copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: AppColors.textPrimary,
                            )),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 13),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.grey300),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 18, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Text(_formatDate(_scheduledDate),
                                    style: AppTextStyles.bodyBold(context)),
                                const Spacer(),
                                Text('Tap to change',
                                    style: AppTextStyles.small(context)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Repeat
                        Text('REPEAT',
                            style: AppTextStyles.caption(context).copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: AppColors.textPrimary,
                            )),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: RepeatInterval.values.map((r) {
                            final selected = _repeat == r;
                            return GestureDetector(
                              onTap: () => setState(() => _repeat = r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 7),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: selected
                                        ? AppColors.primary
                                        : AppColors.grey300,
                                  ),
                                ),
                                child: Text(_repeatLabels[r]!,
                                    style: AppTextStyles.smallBold(context,
                                        color: selected
                                            ? AppColors.light
                                            : AppColors.textPrimary)),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 16),

                        // From account
                        Text('DEBIT FROM',
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
                        if (_accountError != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 6, left: 4),
                            child: Text(_accountError!,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('REMARKS (OPTIONAL)',
                            style: AppTextStyles.caption(context).copyWith(
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: AppColors.textPrimary,
                            )),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.grey300),
                          ),
                          child: TextField(
                            controller: _remarksCtrl,
                            maxLines: 2,
                            style: AppTextStyles.body(context),
                            decoration: InputDecoration(
                              hintText: 'Add a note...',
                              hintStyle: AppTextStyles.body(context,
                                  color: AppColors.grey400),
                              prefixIcon: Icon(Icons.notes_outlined,
                                  color: AppColors.grey400, size: 18),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
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