import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/features/accounts/provider/account_provider.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import '../provider/bills_provider.dart';
import '../widgets/biller_card.dart';
import '../widgets/bill_category_grid.dart';
import '../widgets/pay_bill_sheet.dart';
import 'add_biller_screen.dart';
import 'bill_payment_history_screen.dart';

class BillsScreen extends StatelessWidget {
  const BillsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // BillsProvider is registered globally in main.dart so state
    // persists across navigation — paid bills stay paid.
    return const _BillsView();
  }
}

class _BillsView extends StatelessWidget {
  const _BillsView();

  void _showPaySheet(
      BuildContext context, BillerModel biller, AccountProvider accountProvider) {
    final userId = context.read<AuthProvider>().currentUser?.id ?? '';
    final accounts = accountProvider.getAccountsByUserId(userId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<BillsProvider>(),
        child: PayBillSheet(biller: biller, accounts: accounts),
      ),
    );
  }

  void _showBillerDetails(BuildContext context, BillerModel biller,
      BillsProvider provider, AccountProvider accountProvider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: biller.category.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(biller.category.icon,
                      color: biller.category.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(biller.nickname,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(
                          '${biller.providerName} • ${biller.consumerNumber}',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: biller.reminderEnabled,
              onChanged: (_) {
                provider.toggleReminder(biller.id);
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
              title: const Text('Bill Reminders',
                  style: TextStyle(fontSize: 13)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: biller.autopayEnabled,
              onChanged: (_) {
                provider.toggleAutopay(biller.id);
                Navigator.pop(context);
              },
              activeColor: AppColors.primary,
              title: const Text('Enable Autopay',
                  style: TextStyle(fontSize: 13)),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton.icon(
                onPressed: () {
                  provider.removeBiller(biller.id);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove Biller'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade200),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BillsProvider>();
    final accountProvider = context.read<AccountProvider>();
    final formatter = NumberFormat('#,##,##0.00', 'en_IN');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Bills & Recharges',
            style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChangeNotifierProvider.value(
                  value: provider,
                  child: const BillPaymentHistoryScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Total due summary ─────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: provider.overdueBillers.isNotEmpty
                            ? [Colors.red.shade700, Colors.orange.shade600]
                            : [const Color(0xFF0A3D62), const Color(0xFF1A5FA5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Due',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 13)),
                            if (provider.overdueBillers.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${provider.overdueBillers.length} overdue',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${formatter.format(provider.totalDueAmount)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${provider.unpaidBillers.length} bills pending',
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Quick pay categories ───────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pay a New Bill',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E))),
                      TextButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChangeNotifierProvider.value(
                              value: provider,
                              child: const AddBillerScreen(),
                            ),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Biller'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  BillCategoryGrid(
                    onCategoryTap: (category) => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChangeNotifierProvider.value(
                          value: provider,
                          child: AddBillerScreen(prefillCategory: category),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Saved billers ──────────────────────────────
                  const Text('Saved Billers',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E))),

                  const SizedBox(height: 12),

                  if (provider.billers.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 48, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('No billers added yet',
                                style: TextStyle(
                                    color: Colors.grey.shade400,
                                    fontSize: 14)),
                          ],
                        ),
                      ),
                    )
                  else
                    ...provider.billers.map(
                      (biller) => BillerCard(
                        biller: biller,
                        onPayNow: () =>
                            _showPaySheet(context, biller, accountProvider),
                        onTap: () => _showBillerDetails(
                            context, biller, provider, accountProvider),
                      ),
                    ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}