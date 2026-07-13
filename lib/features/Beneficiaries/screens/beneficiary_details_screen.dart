import 'dart:async';

import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/data/models/beneficiary_model.dart';
import 'package:profinch_mobile_application/features/Beneficiaries/provider/beneficiary_provider.dart';
import 'package:profinch_mobile_application/features/Beneficiaries/screens/edit_beneficiary_screen.dart';
import 'package:provider/provider.dart';

class BeneficiaryDetailsScreen extends StatefulWidget {
  final BeneficiaryModel beneficiary;

  const BeneficiaryDetailsScreen({super.key, required this.beneficiary});

  @override
  State<BeneficiaryDetailsScreen> createState() =>
      _BeneficiaryDetailsScreenState();
}

class _BeneficiaryDetailsScreenState extends State<BeneficiaryDetailsScreen> {
  Timer? _timer;
  int _secondsRemaining = 0;
  // Track the addedAt we last synced from — when provider gives us a new
  // addedAt (after an edit) we immediately restart the countdown without
  // waiting for the edit screen's Navigator.pop await to resolve.
  DateTime? _lastSyncedAddedAt;

  /// Always read the live object from provider, not widget.beneficiary.
  BeneficiaryModel _live(BuildContext context) {
    final provider = Provider.of<BeneficiaryProvider>(context, listen: false);
    return provider.getById(widget.beneficiary.id) ?? widget.beneficiary;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncCooling());
  }

  /// Called every build() via _checkProviderChange() so we react immediately
  /// when provider notifies (i.e. right after editBeneficiary sets new addedAt),
  /// not just after the edit screen's await resolves.
  void _checkProviderChange(BeneficiaryModel live) {
    if (_lastSyncedAddedAt != live.addedAt) {
      _lastSyncedAddedAt = live.addedAt;
      // Schedule sync after current build frame
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncCooling());
    }
  }

  void _syncCooling() {
    if (!mounted) return;
    final remaining = _live(context).coolingSecondsRemaining;
    setState(() => _secondsRemaining = remaining);
    _timer?.cancel();
    if (remaining > 0) _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final remaining = _live(context).coolingSecondsRemaining;
      setState(() => _secondsRemaining = remaining);
      if (remaining <= 0) _timer?.cancel();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────

  Color get _typeColor {
    switch (widget.beneficiary.beneficiaryType) {
      case 'PBI':           return AppColors.blueButton;
      case 'LOCAL':         return AppColors.success;
      case 'INTERNATIONAL': return AppColors.warningDark;
      default:              return AppColors.primary;
    }
  }

  Widget _detailRow(String label, String value) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(label,
                    style: AppTextStyles.bodySecondary(context)),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value.isEmpty ? '—' : value,
                  textAlign: TextAlign.right,
                  style: AppTextStyles.bodyBold(context),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.surfaceLight),
      ],
    );
  }

  // ── Cooling period widget ──────────────────────────────────────

  Widget _coolingBanner() {
    final allowed = _secondsRemaining <= 0;

    if (allowed) {
      return Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.successLight,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.success,
              child: Icon(Icons.check_rounded,
                  color: AppColors.light, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Transfer Allowed',
                      style: AppTextStyles.bodyBold(context,
                          color: AppColors.successDark)),
                  Text('Cooling period complete',
                      style: AppTextStyles.small(context,
                          color: AppColors.successDark)),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Still cooling — show countdown
    final live = _live(context);
    final progress = 1.0 -
        (_secondsRemaining / live.coolingSeconds).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.warning,
                child: Icon(Icons.hourglass_top_rounded,
                    color: AppColors.light, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Cooling Period Active',
                        style: AppTextStyles.bodyBold(context,
                            color: AppColors.warningDark)),
                    Text(
                      'Transfers allowed in $_secondsRemaining second${_secondsRemaining == 1 ? '' : 's'}',
                      style: AppTextStyles.small(context,
                          color: AppColors.warningDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.warning.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Added', style: AppTextStyles.caption(context)),
              Text('Transfer allowed', style: AppTextStyles.caption(context)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Delete confirm ─────────────────────────────────────────────

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18)),
        title: Text('Remove Beneficiary',
            style: AppTextStyles.title(context)),
        content: Text(
          'Are you sure you want to remove '
          '${widget.beneficiary.nickname}?',
          style: AppTextStyles.body(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: AppTextStyles.body(context,
                    color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Provider.of<BeneficiaryProvider>(context, listen: false)
                  .removeBeneficiary(widget.beneficiary.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // back to list
            },
            child: Text('Remove',
                style: AppTextStyles.bodyBold(context,
                    color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Re-read from provider so edits are reflected immediately
    final provider = Provider.of<BeneficiaryProvider>(context);
    final b = provider.getById(widget.beneficiary.id) ?? widget.beneficiary;
    // Detect addedAt change immediately when provider notifies after edit
    _checkProviderChange(b);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ───────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _typeColor.withValues(alpha: 0.85),
                  _typeColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Back + Edit row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back,
                              color: AppColors.light),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EditBeneficiaryScreen(beneficiary: b),
                              ),
                            );
                            // Re-sync cooling after edit — provider has new addedAt
                            _syncCooling();
                          },
                          icon: const Icon(Icons.edit_outlined,
                              color: AppColors.light, size: 16),
                          label: Text('Edit',
                              style: AppTextStyles.whiteBody(context)),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Avatar
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.light.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        b.nickname[0].toUpperCase(),
                        style: AppTextStyles.whiteHeading(context),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Text(b.nickname,
                      style: AppTextStyles.whiteTitle(context)),
                  const SizedBox(height: 4),

                  // Type badge
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.light.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      b.beneficiaryType,
                      style: AppTextStyles.smallBold(context,
                          color: AppColors.light),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Cooling banner (live countdown)
                  _coolingBanner(),

                  // Account details card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.light,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.grey200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _detailRow(
                          'Account No.',
                          '••••  ••••  ${b.accountNumber.length > 4 ? b.accountNumber.substring(b.accountNumber.length - 4) : b.accountNumber}',
                        ),
                        _detailRow('Bank', b.bankName),
                        _detailRow('IFSC', b.ifscCode),
                        if (b.ibanNumber != null && b.ibanNumber!.isNotEmpty)
                          _detailRow('IBAN', b.ibanNumber!),
                        if (b.swiftCode != null && b.swiftCode!.isNotEmpty)
                          _detailRow('SWIFT', b.swiftCode!),
                        if (b.country != null && b.country!.isNotEmpty)
                          _detailRow('Country', b.country!),
                        _detailRow(
                          'Verified',
                          b.isVerified ? '✓ Verified' : 'Pending',
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Remove button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: BorderSide(
                            color: AppColors.error.withValues(alpha: 0.4)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _confirmDelete,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text('Remove Beneficiary',
                          style: AppTextStyles.bodyBold(context,
                              color: AppColors.error)),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}