import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import '../provider/insurance_provider.dart';
import '../../../data/models/insurance_model.dart';
import '../../../data/dummy/dummy_insurance.dart';
import 'my_policies_screen.dart';
import 'buy_insurance_screen.dart';
import 'insurance_claims_screen.dart';
// ignore: unused_import
import 'premium_payment_screen.dart';
import 'plan_selection_screen.dart';

class InsuranceScreen extends StatelessWidget {
  const InsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    return Consumer<InsuranceProvider>(
      builder: (context, provider, _) {
        final active = provider.getActivePolicies(user.id);
        final totalCoverage = provider.getTotalCoverage(user.id);
        final fmt = NumberFormat('#,##,##0', 'en_IN');

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          body: CustomScrollView(
            slivers: [
              // ── AppBar ────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: AppColors.primaryDark,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primaryDark, const Color(0xFF2A1F8F)],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // decorative circles
                        Positioned(
                          right: -30,
                          top: -20,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 60,
                          top: 40,
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 70, 20, 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Insurance',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Protect what matters',
                                      style: TextStyle(
                                        color: Colors.white.withValues(alpha: 0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        _statChip('Active Policies', '${active.length}  >'),
                                        const SizedBox(width: 24),
                                        _statChip('Total Coverage', '₹${fmt.format(totalCoverage)}'),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              // umbrella illustration placeholder
                              Container(
                                width: 90,
                                height: 90,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.umbrella_rounded,
                                  size: 48,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                title: const Text(
                  'Insurance',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),

              // ── Body ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Manage Insurance section ──────────────
                      _sectionTitle('Manage Insurance'),
                      const SizedBox(height: 12),
                      _manageCard(context),
                      const SizedBox(height: 24),

                      // ── Featured Plans ────────────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _sectionTitle('Featured Plans'),
                          TextButton(
                            onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const BuyInsuranceScreen())),
                            child: Text('View All', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _featuredPlansRow(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 11)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _sectionTitle(String t) => Text(t,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)));

  Widget _manageCard(BuildContext context) {
    final items = [
      _ManageItem(Icons.policy_outlined,       'My Policies',      'View all your policies',      Colors.orange.shade50,   Colors.orange,      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPoliciesScreen()))),
      _ManageItem(Icons.add_circle_outline,    'Buy Insurance',    'Explore new plans',            Colors.blue.shade50,     Colors.blue,         () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BuyInsuranceScreen()))),
      _ManageItem(Icons.autorenew_outlined,    'Renew Policy',     'Renew your existing policies', Colors.purple.shade50,   Colors.purple,      () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPoliciesScreen()))),
      _ManageItem(Icons.assignment_outlined,   'Claims',           'Raise and track claims',       Colors.red.shade50,      Colors.red,          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InsuranceClaimsScreen()))),
      _ManageItem(Icons.payment_outlined,      'Premium Payment',  'Pay your policy premium',      Colors.green.shade50,    Colors.green,        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPoliciesScreen(openPremium: true)))),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return Column(
            children: [
              ListTile(
                onTap: item.onTap,
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: item.bg, borderRadius: BorderRadius.circular(10)),
                  child: Icon(item.icon, color: item.color, size: 20),
                ),
                title: Text(item.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                subtitle: Text(item.subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              ),
              if (i < items.length - 1)
                Divider(height: 1, indent: 68, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _featuredPlansRow(BuildContext context) {
    final types = DummyInsurance.insuranceTypes;
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: types.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final t = types[i];
          return GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => PlanSelectionScreen(typeConfig: t))),
            child: Container(
              width: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _typeColor(t.type).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_typeIcon(t.type), color: _typeColor(t.type), size: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(t.name.split(' ').first,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                    textAlign: TextAlign.center),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _typeIcon(InsuranceType t) {
    switch (t) {
      case InsuranceType.health: return Icons.favorite_border_rounded;
      case InsuranceType.life:   return Icons.shield_outlined;
      case InsuranceType.motor:  return Icons.directions_car_outlined;
      case InsuranceType.travel: return Icons.flight_outlined;
      case InsuranceType.home:   return Icons.home_outlined;
    }
  }

  Color _typeColor(InsuranceType t) {
    switch (t) {
      case InsuranceType.health: return Colors.red;
      case InsuranceType.life:   return Colors.blue;
      case InsuranceType.motor:  return Colors.orange;
      case InsuranceType.travel: return Colors.teal;
      case InsuranceType.home:   return Colors.purple;
    }
  }
}

class _ManageItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bg;
  final Color color;
  final VoidCallback onTap;
  _ManageItem(this.icon, this.title, this.subtitle, this.bg, this.color, this.onTap);
}