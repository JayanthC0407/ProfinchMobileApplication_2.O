import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import '../provider/insurance_provider.dart';
import '../../../data/models/insurance_model.dart';
import 'policy_details_screen.dart';
import 'buy_insurance_screen.dart';
// ignore: unused_import
import 'premium_payment_screen.dart';

class MyPoliciesScreen extends StatefulWidget {
  final bool openPremium;
  const MyPoliciesScreen({super.key, this.openPremium = false});

  @override
  State<MyPoliciesScreen> createState() => _MyPoliciesScreenState();
}

class _MyPoliciesScreenState extends State<MyPoliciesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    if (widget.openPremium) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _tab.animateTo(0);
      });
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    return Consumer<InsuranceProvider>(
      builder: (context, provider, _) {
        final active  = provider.getActivePolicies(user.id);
        final expired = provider.getExpiredPolicies(user.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('My Policies', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            bottom: TabBar(
              controller: _tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              indicatorColor: Colors.white,
              tabs: [
                Tab(text: 'Active (${active.length})'),
                Tab(text: 'Expired (${expired.length})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tab,
            children: [
              _PolicyList(policies: active, isActive: true),
              _PolicyList(policies: expired, isActive: false),
            ],
          ),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: ElevatedButton.icon(
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const BuyInsuranceScreen())),
              icon: const Icon(Icons.add),
              label: const Text('Buy New Insurance'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryDark,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PolicyList extends StatelessWidget {
  final List<InsuranceModel> policies;
  final bool isActive;
  const _PolicyList({required this.policies, required this.isActive});

  @override
  Widget build(BuildContext context) {
    if (policies.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.policy_outlined, size: 60, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text('No ${isActive ? 'active' : 'expired'} policies',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: policies.length,
      itemBuilder: (context, i) => _PolicyCard(policy: policies[i]),
    );
  }
}

class _PolicyCard extends StatelessWidget {
  final InsuranceModel policy;
  const _PolicyCard({required this.policy});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final isActive = policy.status == InsuranceStatus.active;

    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => PolicyDetailsScreen(policy: policy))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                    color: _typeColor(policy.type).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(_typeIcon(policy.type), color: _typeColor(policy.type), size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(policy.planName,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 2),
                      Text('Policy No. ${policy.policyNumber}',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isActive ? 'Active' : 'Expired',
                    style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: isActive ? Colors.green.shade700 : Colors.grey.shade500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _infoCol('Coverage', '₹${NumberFormat('#,##,##0', 'en_IN').format(policy.coverageAmount)}')),
                Expanded(child: _infoCol('Expires on', dateFmt.format(policy.endDate))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCol(String label, String value) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
    ]);
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