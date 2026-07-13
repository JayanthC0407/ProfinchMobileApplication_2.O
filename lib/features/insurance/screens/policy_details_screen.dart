import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../../../data/models/insurance_model.dart';
import '../widgets/app_notification.dart';
import 'premium_payment_screen.dart';
import 'insurance_claims_screen.dart';

class PolicyDetailsScreen extends StatelessWidget {
  final InsuranceModel policy;
  const PolicyDetailsScreen({super.key, required this.policy});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final moneyFmt = NumberFormat('#,##,##0', 'en_IN');
    final isActive = policy.status == InsuranceStatus.active;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Policy Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Policy header card ────────────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: _typeColor(policy.type).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_typeIcon(policy.type), color: _typeColor(policy.type), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(policy.planName,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 2),
                        Text('Policy No. ${policy.policyNumber}',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
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
            ),

            const SizedBox(height: 14),

            // ── Details card ──────────────────────────────────
            _detailsCard([
              _DetailRow('Policy Holder',    policy.policyHolderName),
              _DetailRow('Coverage Amount',  '₹${moneyFmt.format(policy.coverageAmount)}'),
              _DetailRow('Policy Start Date', dateFmt.format(policy.startDate)),
              _DetailRow('Policy End Date',   dateFmt.format(policy.endDate)),
              _DetailRow('Premium',          '₹${moneyFmt.format(policy.premiumAmount)} / month'),
              _DetailRow('Next Premium Due',  dateFmt.format(policy.nextPremiumDue)),
              _DetailRow('Nominee',          policy.nomineeName),
            ]),

            const SizedBox(height: 16),

            // ── Action buttons ────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    context,
                    icon: Icons.payment_outlined,
                    label: 'Pay Premium',
                    color: AppColors.primaryDark,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => PremiumPaymentScreen(policy: policy))),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionBtn(
                    context,
                    icon: Icons.download_outlined,
                    label: 'Download Policy',
                    color: Colors.grey.shade700,
                    onTap: () => AppNotification.show(context,
                      message: 'Downloading policy document...',
                      type: AppNotificationType.info),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionBtn(
                    context,
                    icon: Icons.assignment_outlined,
                    label: 'Raise Claim',
                    color: Colors.orange.shade700,
                    onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => InsuranceClaimsScreen(policyId: policy.id))),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Benefits card ─────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Policy Benefits',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      Text('View All',
                          style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...policy.benefits.map((b) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Icon(Icons.check_circle_outline, size: 18, color: Colors.green.shade600),
                      const SizedBox(width: 8),
                      Text(b, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E))),
                    ]),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _detailsCard(List<_DetailRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: rows.asMap().entries.map((e) {
          final i = e.key;
          final r = e.value;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.label, style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                  Text(r.value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                ],
              ),
            ),
            if (i < rows.length - 1) Divider(height: 1, color: Colors.grey.shade100),
          ]);
        }).toList(),
      ),
    );
  }

  Widget _actionBtn(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500), textAlign: TextAlign.center),
        ]),
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

class _DetailRow {
  final String label;
  final String value;
  const _DetailRow(this.label, this.value);
}