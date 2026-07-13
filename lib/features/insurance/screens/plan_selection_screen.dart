import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import '../../../data/models/insurance_model.dart';
// ignore: unused_import
import '../widgets/app_notification.dart';
import 'buy_insurance_fill_screen.dart';

class PlanSelectionScreen extends StatefulWidget {
  final InsuranceTypeConfig typeConfig;
  const PlanSelectionScreen({super.key, required this.typeConfig});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  int _selectedTab = 0; // 0 = Individual, 1 = Family
  InsurancePlanConfig? _selectedPlan;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,##,##0', 'en_IN');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text('${widget.typeConfig.name} Plans',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // ── Individual / Family toggle ────────────────────
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
            ),
            child: Row(
              children: [
                _tab('Individual', 0),
                _tab('Family', 1),
              ],
            ),
          ),

          // ── Plan list ─────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.typeConfig.plans.length,
              itemBuilder: (context, i) {
                final plan = widget.typeConfig.plans[i];
                final isSelected = _selectedPlan == plan;
                return GestureDetector(
                  onTap: () => setState(() => _selectedPlan = plan),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? AppColors.primaryDark : Colors.transparent,
                        width: 2,
                      ),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(plan.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Coverage', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              Text('₹${fmt.format(plan.coverageAmount)}',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                            ]),
                            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text('Premium', style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                              Text('₹${fmt.format(plan.premiumAmount)} / month',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _showPlanDetails(context, plan),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primaryDark,
                                  side: BorderSide(color: AppColors.primaryDark.withValues(alpha: 0.3)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: const Text('View Details', style: TextStyle(fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(context,
                                  MaterialPageRoute(builder: (_) => BuyInsuranceFillScreen(
                                    typeConfig: widget.typeConfig,
                                    planConfig: plan,
                                  ))),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryDark,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                child: const Text('Buy Now', style: TextStyle(fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, int index) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryDark : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  void _showPlanDetails(BuildContext context, InsurancePlanConfig plan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PlanDetailsSheet(
        typeConfig: widget.typeConfig,
        plan: plan,
        onBuyNow: () {
          Navigator.pop(context);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => BuyInsuranceFillScreen(
              typeConfig: widget.typeConfig,
              planConfig: plan,
            ),
          ));
        },
      ),
    );
  }
}

class _PlanDetailsSheet extends StatelessWidget {
  final InsuranceTypeConfig typeConfig;
  final InsurancePlanConfig plan;
  final VoidCallback onBuyNow;

  const _PlanDetailsSheet({
    required this.typeConfig,
    required this.plan,
    required this.onBuyNow,
  });

  @override
  Widget build(BuildContext context) {
    final moneyFmt = NumberFormat('#,##,##0', 'en_IN');
    final gst      = plan.premiumAmount * 0.18;
    final total    = plan.premiumAmount + gst;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // drag handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                children: [

                  // ── Plan header ───────────────────────────
                  Row(
                    children: [
                      Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primaryDark.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.shield_outlined, color: AppColors.primaryDark, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(plan.name,
                                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                            Text(typeConfig.name,
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ── Coverage & Premium ────────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.primaryDark.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(child: _stat('Coverage', '₹${moneyFmt.format(plan.coverageAmount)}')),
                        Container(width: 1, height: 36, color: AppColors.primaryDark.withValues(alpha: 0.15)),
                        Expanded(child: _stat('Monthly Premium', '₹${moneyFmt.format(plan.premiumAmount)}')),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Price breakdown ───────────────────────
                  const Text('Price Breakdown',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        _priceRow('Base Premium',     '₹${moneyFmt.format(plan.premiumAmount)}',   false),
                        Divider(height: 1, color: Colors.grey.shade100),
                        _priceRow('GST (18%)',        '₹${moneyFmt.format(gst)}',                  false),
                        Divider(height: 1, color: Colors.grey.shade100),
                        _priceRow('Total / Month',    '₹${moneyFmt.format(total)}',                true),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Benefits ──────────────────────────────
                  const Text('Plan Benefits',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: typeConfig.benefits.map((b) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(children: [
                          Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, size: 13, color: Colors.green.shade700),
                          ),
                          const SizedBox(width: 10),
                          Expanded(child: Text(b, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E)))),
                        ]),
                      )).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Buy Now button ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: ElevatedButton(
                onPressed: onBuyNow,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Buy Now — ₹${moneyFmt.format(total)} / month',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) => Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
      const SizedBox(height: 4),
      Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primaryDark)),
    ],
  );

  Widget _priceRow(String label, String value, bool bold) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(
          fontSize: 13,
          color: bold ? const Color(0xFF1A1A2E) : Colors.grey.shade500,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      Text(value, style: TextStyle(
          fontSize: 13,
          color: const Color(0xFF1A1A2E),
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600)),
    ]),
  );
}