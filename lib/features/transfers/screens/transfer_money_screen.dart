import 'dart:async';
import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/text_styles.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:provider/provider.dart';

import '../../../core/routes/app_routes.dart';
import '../../auth/provider/auth_provider.dart';
import '../../Beneficiaries/provider/beneficiary_provider.dart';
import '../widgets/beneficiary_transfer_tile.dart';
import 'international_transfer_screen.dart';
import 'local_transfer_screen.dart';
import 'pbi_transfer_screen.dart';

class TransferMoneyScreen extends StatefulWidget {
  const TransferMoneyScreen({super.key});

  @override
  State<TransferMoneyScreen> createState() => _TransferMoneyScreenState();
}

class _TransferMoneyScreenState extends State<TransferMoneyScreen> {
  String searchQuery = "";
  String _activeFilter = "ALL";
  Timer? _ticker;

  final List<String> _filters = ["ALL", "PBI", "LOCAL", "INTERNATIONAL"];

  @override
  void initState() {
    super.initState();
    // Rebuild every second so cooling countdowns stay live
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final beneficiaryProvider = Provider.of<BeneficiaryProvider>(context);
    final user = authProvider.currentUser!;
    final beneficiaries = beneficiaryProvider.getBeneficiariesByUserId(user.id);

    final filtered = beneficiaries.where((b) {
      final matchSearch = b.nickname.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );
      final matchFilter =
          _activeFilter == "ALL" || b.beneficiaryType == _activeFilter;
      return matchSearch && matchFilter;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A3A6B), Color(0xFF2563B0)],
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
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.person_add_alt_1_outlined,
                            color: Colors.white,
                          ),
                          tooltip: "Add Beneficiary",
                          onPressed: () => Navigator.pushNamed(
                            context,
                            AppRoutes.beneficiaryType,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 4),
                    child: Text(
                      "Transfer Money",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: Text(
                      "Select a beneficiary to proceed",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: TextField(
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: "Search beneficiary",
                          hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.55),
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (v) => setState(() => searchQuery = v),
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
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: active ? const Color(0xFF2563B0) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? const Color(0xFF2563B0)
                              : const Color(0xFFE5E7EB),
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: active ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // ── Payments quick access ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Payments',
                        style: AppTextStyles.title(context)),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, AppRoutes.payments),
                      child: Text('See all',
                          style: AppTextStyles.small(context,
                              color: AppColors.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _PaymentShortcut(
                      icon: Icons.send_rounded,
                      label: 'Adhoc',
                      color: AppColors.blueButton,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.adhocTransfer),
                    ),
                    const SizedBox(width: 10),
                    _PaymentShortcut(
                      icon: Icons.schedule_rounded,
                      label: 'Scheduled',
                      color: AppColors.success,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.scheduledPayment),
                    ),
                    const SizedBox(width: 10),
                    _PaymentShortcut(
                      icon: Icons.star_rounded,
                      label: 'Favourites',
                      color: AppColors.warning,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.favourites),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Divider(height: 1, color: AppColors.grey200),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Text('Beneficiaries',
                style: AppTextStyles.title(context)),
          ),

          // ── List ──────────────────────────────────────────────────────
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No beneficiaries found",
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final b = filtered[index];
                      return BeneficiaryTransferTile(
                        name: b.nickname,
                        type: b.beneficiaryType,
                        accountNumber: b.accountNumber,
                        coolingSecondsRemaining: b.coolingSecondsRemaining,
                        onTap: () {
                          // Block transfer until cooling period elapses
                          if (!b.isTransferAllowed) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Transfer to ${b.nickname} is locked for '
                                  '${b.coolingSecondsRemaining} more second'
                                  '${b.coolingSecondsRemaining == 1 ? '' : 's'}. '
                                  'This is a security cooling period.',
                                ),
                                backgroundColor: AppColors.warningDark,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            return;
                          }
                          if (b.beneficiaryType == "PBI") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    PbiTransferScreen(beneficiary: b),
                              ),
                            );
                          } else if (b.beneficiaryType == "LOCAL") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    LocalTransferScreen(beneficiary: b),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    InternationalTransferScreen(beneficiary: b),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ── Payment shortcut chip ─────────────────────────────────────────────────

class _PaymentShortcut extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PaymentShortcut({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.small(context, color: color)
                    .copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}