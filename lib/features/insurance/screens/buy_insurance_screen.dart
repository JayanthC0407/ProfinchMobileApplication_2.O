import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../../../data/models/insurance_model.dart';
import '../../../data/dummy/dummy_insurance.dart';
import 'plan_selection_screen.dart';

class BuyInsuranceScreen extends StatelessWidget {
  const BuyInsuranceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final types = DummyInsurance.insuranceTypes;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Buy Insurance', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Heading ─────────────────────────────────────
            const Text(
              'Buy Insurance',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 4),
            Text(
              'Choose the type of insurance\nthat suits your needs',
              style: TextStyle(fontSize: 14, color: AppColors.primary, height: 1.4),
            ),

            const SizedBox(height: 20),

            // ── Insurance type cards ─────────────────────────
            ...types.map((t) => _InsuranceTypeCard(typeConfig: t)),

            const SizedBox(height: 16),

            // ── Trusted partners banner ──────────────────────
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryDark.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.verified_outlined, color: AppColors.primaryDark, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Trusted Partners',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 2),
                      Text('All our insurance partners are IRDAI approved and trusted by millions',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                    ]),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InsuranceTypeCard extends StatelessWidget {
  final InsuranceTypeConfig typeConfig;
  const _InsuranceTypeCard({required this.typeConfig});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => PlanSelectionScreen(typeConfig: typeConfig))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_icon, color: _color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(typeConfig.name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                const SizedBox(height: 2),
                Text(typeConfig.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ]),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    switch (typeConfig.type) {
      case InsuranceType.health: return Icons.favorite_border_rounded;
      case InsuranceType.life:   return Icons.shield_outlined;
      case InsuranceType.motor:  return Icons.directions_car_outlined;
      case InsuranceType.travel: return Icons.flight_outlined;
      case InsuranceType.home:   return Icons.home_outlined;
    }
  }

  Color get _color {
    switch (typeConfig.type) {
      case InsuranceType.health: return Colors.red;
      case InsuranceType.life:   return Colors.blue;
      case InsuranceType.motor:  return Colors.orange;
      case InsuranceType.travel: return Colors.teal;
      case InsuranceType.home:   return Colors.purple;
    }
  }
}