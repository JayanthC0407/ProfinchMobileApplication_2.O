import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import '../provider/upi_provider.dart';
import '../widgets/upi_contact_tile.dart';
import 'send_money_screen.dart';

class UpiHomeScreen extends StatelessWidget {
  const UpiHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => UpiProvider(ctx.read<AuthProvider>(), ctx.read<AccountProvider>()),
      child: const _UpiHomeView(),
    );
  }
}

class _UpiHomeView extends StatelessWidget {
  const _UpiHomeView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UpiProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'UPI Payments',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── 3 Main action cards ────────────────────────────
            Row(
              children: [
                const SizedBox(width: 12),
                _buildActionCard(
                  context,
                  icon: Icons.send_rounded,
                  label: 'Send Money',
                  color: AppColors.primaryDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<UpiProvider>(),
                        child: const SendMoneyScreen(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── UPI ID card ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.alternate_email_rounded,
                        color: AppColors.primaryDark, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your UPI ID',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey),
                        ),
                        Text(
                          provider.myUpiId,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.verified_rounded,
                      color: Colors.green.shade600, size: 20),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Recent contacts ────────────────────────────────
            const Text(
              'Recent',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: provider.recentContacts.map((contact) {
                return UpiContactTile(
                  contact: contact,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: context.read<UpiProvider>(),
                        child: SendMoneyScreen(
                          prefillUpiId: contact.upiId,
                          prefillName: contact.name,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ── Quick pay options ──────────────────────────────
            const Text(
              'Pay to',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),

            const SizedBox(height: 14),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
              children: [
                _buildPayOption(Icons.phone_outlined, 'Mobile', const Color(0xFF0EA5E9)),
                _buildPayOption(Icons.account_balance_outlined, 'Bank', const Color(0xFF7C3AED)),
                _buildPayOption(Icons.credit_card_outlined, 'Card', AppColors.primaryDark),
                _buildPayOption(Icons.receipt_outlined, 'Bill', const Color(0xFFF59E0B)),
                _buildPayOption(Icons.electric_bolt_outlined, 'Electricity', const Color(0xFF10B981)),
                _buildPayOption(Icons.local_gas_station_outlined, 'Gas', const Color(0xFFEF4444)),
                _buildPayOption(Icons.wifi_outlined, 'Internet', const Color(0xFF8B5CF6)),
                _buildPayOption(Icons.more_horiz, 'More', Colors.grey),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Action card ────────────────────────────────────────────────
  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pay option item ────────────────────────────────────────────
  Widget _buildPayOption(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1A1A2E),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}