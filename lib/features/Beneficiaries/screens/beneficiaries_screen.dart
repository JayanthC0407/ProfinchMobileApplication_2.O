// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/core/constants/fonts_size.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/core/utils/responsive_text.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../auth/provider/auth_provider.dart';
import '../provider/beneficiary_provider.dart';
import '../widgets/beneficiary_card.dart';
import 'beneficiary_details_screen.dart';

class BeneficiariesScreen extends StatefulWidget {
  const BeneficiariesScreen({super.key});

  @override
  State<BeneficiariesScreen> createState() => _BeneficiariesScreenState();
}

class _BeneficiariesScreenState extends State<BeneficiariesScreen> {
  String _activeFilter = "ALL";
  final List<String> _filters = ["ALL", "PBI", "LOCAL", "INTERNATIONAL"];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final beneficiaryProvider = Provider.of<BeneficiaryProvider>(context);
    final user = authProvider.currentUser!;
    final allBeneficiaries =
        beneficiaryProvider.getBeneficiariesByUserId(user.id);
    final beneficiaries = _activeFilter == "ALL"
        ? allBeneficiaries
        : allBeneficiaries
            .where((b) => b.beneficiaryType == _activeFilter)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.navy, AppColors.blueButton],
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
                    padding: const EdgeInsets.fromLTRB(4, 4, 8, 0),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.light),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.notifications_outlined,
                              color: AppColors.light),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Text(
                      "Beneficiaries",
                      style: TextStyle(
                        color: AppColors.light,
                        fontSize: RT.fs(context, 24),
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: Text(
                      "${allBeneficiaries.length} saved recipient${allBeneficiaries.length == 1 ? '' : 's'}",
                      style: AppTextStyles.whiteBody(context,color: AppColors.light.withValues(alpha: 0.65)),
                    ),
                  ),
                  // Transfer Money quick action inside header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    child: GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.transferMoney),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.light.withValues(alpha:0.15),
                          borderRadius: BorderRadius.circular(14),
                          border:
                              Border.all(color: AppColors.light.withValues(alpha:0.2)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: AppColors.light.withValues(alpha:0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.swap_horiz_rounded,
                                  color: AppColors.light, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Transfer Money",
                                    style: TextStyle(
                                        color: AppColors.light,
                                        fontSize: AppFontSize.body(context),
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    "Send to a beneficiary",
                                    style: TextStyle(
                                        color: AppColors.light.withValues(alpha:0.65),
                                        fontSize: AppFontSize.small(context)),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios_rounded,
                                color: AppColors.light.withValues(alpha: 0.7), size: 14),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Filter chips ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              children: _filters.map((f) {
                final active = _activeFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _activeFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: active
                            ? AppColors.blueButton
                            : AppColors.light,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? AppColors.blueButton
                              : AppColors.surface,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: AppFontSize.small(context),
                          fontWeight: FontWeight.w600,
                          color: active ? AppColors.light : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── List ─────────────────────────────────────────────────────
          Expanded(
            child: beneficiaries.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people_outline,
                            size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          "No beneficiaries yet",
                          style: TextStyle(
                              fontSize: AppFontSize.medium(context),
                              color: Colors.grey.shade400,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tap + to add one",
                          style: TextStyle(
                              fontSize: AppFontSize.body(context), color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: beneficiaries.length,
                    itemBuilder: (context, index) {
                      final b = beneficiaries[index];
                      return BeneficiaryCard(
                        name: b.nickname,
                        accountNumber: b.accountNumber,
                        type: b.beneficiaryType,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  BeneficiaryDetailsScreen(beneficiary: b)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.blueButton,
        foregroundColor: AppColors.light,
        elevation: 4,
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.beneficiaryType),
        icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
        label: Text(
          "Add Beneficiary",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppFontSize.body(context)),
        ),
      ),
    );
  }
}