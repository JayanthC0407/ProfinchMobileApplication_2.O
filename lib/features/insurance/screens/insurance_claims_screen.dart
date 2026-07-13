import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:profinch_mobile_application/core/constants/colors.dart';
import 'package:profinch_mobile_application/features/auth/provider/auth_provider.dart';
import '../provider/insurance_provider.dart';
import '../../../data/models/insurance_model.dart';
import '../widgets/app_notification.dart';

class InsuranceClaimsScreen extends StatefulWidget {
  final String? policyId;
  const InsuranceClaimsScreen({super.key, this.policyId});

  @override
  State<InsuranceClaimsScreen> createState() => _InsuranceClaimsScreenState();
}

class _InsuranceClaimsScreenState extends State<InsuranceClaimsScreen> {
  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().currentUser!;
    return Consumer<InsuranceProvider>(
      builder: (context, provider, _) {
        final allClaims = provider.getAllClaims(user.id);
        final policies  = provider.getActivePolicies(user.id);

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: AppColors.primaryDark,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text('Claims', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Action cards ──────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8)],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        onTap: () => _showRaiseClaimSheet(context, provider, policies),
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.assignment_add, color: Colors.orange.shade700, size: 20),
                        ),
                        title: const Text('Raise New Claim',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                        subtitle: Text('Start a new claim request',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ),
                      Divider(height: 1, indent: 68, color: Colors.grey.shade100),
                      ListTile(
                        onTap: () {},
                        leading: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.track_changes, color: Colors.blue.shade700, size: 20),
                        ),
                        title: const Text('Track Claims',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                        subtitle: Text('Track your claim status',
                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Recent Claims ─────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recent Claims',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                    if (allClaims.length > 3)
                      TextButton(
                        onPressed: () {},
                        child: Text('View All', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                if (allClaims.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.assignment_outlined, size: 52, color: Colors.grey.shade300),
                        const SizedBox(height: 10),
                        Text('No claims yet', style: TextStyle(color: Colors.grey.shade500, fontSize: 14)),
                      ]),
                    ),
                  )
                else
                  ...allClaims.take(10).map((c) => _ClaimCard(claim: c)),

                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRaiseClaimSheet(BuildContext context, InsuranceProvider provider, List<InsuranceModel> policies) {
    if (policies.isEmpty) {
      AppNotification.showDialog(
        context,
        title: 'No Active Policies',
        message: 'You don\'t have any active policies to raise a claim for. Buy insurance first.',
        type: AppNotificationType.info,
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _RaiseClaimSheet(
        policies: policies,
        preSelectedPolicyId: widget.policyId,
        onSubmit: (policyId, desc, amount) {
          provider.raiseClaim(policyId: policyId, description: desc, amount: amount);
          Navigator.pop(context);
          AppNotification.show(
            context,
            message: 'Claim raised! Our team will review it shortly.',
            type: AppNotificationType.success,
          );
          setState(() {});
        },
      ),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  final InsuranceClaimModel claim;
  const _ClaimCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final dateFmt = DateFormat('dd MMM yyyy');
    final moneyFmt = NumberFormat('#,##,##0', 'en_IN');
    Color statusColor;
    Color statusBg;
    switch (claim.status) {
      case 'Approved': statusColor = Colors.green.shade700; statusBg = Colors.green.shade50; break;
      case 'Rejected': statusColor = Colors.red.shade700;   statusBg = Colors.red.shade50;   break;
      default:         statusColor = Colors.orange.shade700; statusBg = Colors.orange.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(claim.claimNumber,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 3),
              Text(claim.description, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 3),
              Text('Amount: ₹${moneyFmt.format(claim.claimAmount)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 2),
              Text(dateFmt.format(claim.date), style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(20)),
            child: Text(claim.status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
          ),
        ],
      ),
    );
  }
}

class _RaiseClaimSheet extends StatefulWidget {
  final List<InsuranceModel> policies;
  final String? preSelectedPolicyId;
  final void Function(String policyId, String description, double amount) onSubmit;
  const _RaiseClaimSheet({required this.policies, required this.onSubmit, this.preSelectedPolicyId});

  @override
  State<_RaiseClaimSheet> createState() => _RaiseClaimSheetState();
}

class _RaiseClaimSheetState extends State<_RaiseClaimSheet> {
  final _formKey    = GlobalKey<FormState>();
  final _descCtrl   = TextEditingController();
  final _amountCtrl = TextEditingController();
  String? _policyId;

  @override
  void initState() {
    super.initState();
    _policyId = widget.preSelectedPolicyId ?? widget.policies.first.id;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Raise New Claim',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 20),

              DropdownButtonFormField<String>(
                value: _policyId,
                items: widget.policies.map((p) => DropdownMenuItem(
                  value: p.id,
                  child: Text('${p.planName} (${p.policyNumber})', style: const TextStyle(fontSize: 13)),
                )).toList(),
                onChanged: (v) => setState(() => _policyId = v),
                validator: (v) => v == null ? 'Select a policy' : null,
                decoration: _dec('Select Policy'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                decoration: _dec('Description (e.g. Hospitalization)'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (double.tryParse(v) == null) return 'Enter valid amount';
                  return null;
                },
                decoration: _dec('Claim Amount (₹)'),
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () {
                  if (!_formKey.currentState!.validate()) return;
                  widget.onSubmit(
                    _policyId!,
                    _descCtrl.text.trim(),
                    double.parse(_amountCtrl.text),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Claim', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    labelStyle: TextStyle(fontSize: 13, color: Colors.grey.shade600),
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.primaryDark)),
    errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Colors.red)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}