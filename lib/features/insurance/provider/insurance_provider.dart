import 'package:flutter/material.dart';
import '../../../data/models/insurance_model.dart';
import '../../../data/dummy/dummy_insurance.dart';

class InsuranceProvider extends ChangeNotifier {
  final List<InsuranceModel> _policies = List.from(DummyInsurance.policies);
  final List<InsuranceClaimModel> _claims = List.from(DummyInsurance.claims);

  // ── Getters ───────────────────────────────────────────────────
  List<InsuranceModel> get allPolicies => _policies;

  List<InsuranceModel> getPoliciesByUserId(String userId) =>
      _policies.where((p) => p.userId == userId).toList();

  List<InsuranceModel> getActivePolicies(String userId) => _policies
      .where((p) => p.userId == userId && p.status == InsuranceStatus.active)
      .toList();

  List<InsuranceModel> getExpiredPolicies(String userId) => _policies
      .where((p) => p.userId == userId && p.status == InsuranceStatus.expired)
      .toList();

  double getTotalCoverage(String userId) => getActivePolicies(userId)
      .fold(0, (sum, p) => sum + p.coverageAmount);

  List<InsuranceClaimModel> getClaimsForPolicy(String policyId) =>
      _claims.where((c) => c.policyId == policyId).toList();

  List<InsuranceClaimModel> getAllClaims(String userId) {
    final policyIds = getPoliciesByUserId(userId).map((p) => p.id).toSet();
    return _claims.where((c) => policyIds.contains(c.policyId)).toList();
  }

  InsuranceModel? getPolicyById(String id) {
    try {
      return _policies.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  // ── Add a newly purchased policy ─────────────────────────────
  InsuranceModel addPolicy({
    required String userId,
    required InsuranceType type,
    required InsurancePlanConfig planConfig,
    required String policyHolderName,
    required String policyHolderDob,
    required String nomineeName,
    required String nomineeRelationship,
    required String nomineeDoB,
    required String nomineeMobile,
    required String debitAccountId,
    required String typeConfig_name,
    required List<String> benefits,
  }) {
    final now = DateTime.now();
    final gst = planConfig.premiumAmount * 0.18;
    final policy = InsuranceModel(
      id: 'INS${now.millisecondsSinceEpoch}',
      userId: userId,
      policyNumber: 'INS${now.millisecondsSinceEpoch % 1000000000}',
      type: type,
      plan: planConfig.plan,
      planName: typeConfig_name,
      policyHolderName: policyHolderName,
      coverageAmount: planConfig.coverageAmount,
      premiumAmount: planConfig.premiumAmount,
      gstAmount: gst,
      totalPremium: planConfig.premiumAmount + gst,
      startDate: now,
      endDate: DateTime(now.year + 1, now.month, now.day),
      nextPremiumDue: DateTime(now.year, now.month + 1, now.day),
      nomineeName: nomineeName,
      nomineeRelationship: nomineeRelationship,
      nomineeDoB: nomineeDoB,
      nomineeMobile: nomineeMobile,
      debitAccountId: debitAccountId,
      status: InsuranceStatus.active,
      benefits: benefits,
    );
    _policies.add(policy);
    notifyListeners();
    return policy;
  }

  // ── Pay a premium ─────────────────────────────────────────────
  void payPremium(String policyId) {
    final idx = _policies.indexWhere((p) => p.id == policyId);
    if (idx == -1) return;
    final p = _policies[idx];
    _policies[idx] = InsuranceModel(
      id: p.id,
      userId: p.userId,
      policyNumber: p.policyNumber,
      type: p.type,
      plan: p.plan,
      planName: p.planName,
      policyHolderName: p.policyHolderName,
      coverageAmount: p.coverageAmount,
      premiumAmount: p.premiumAmount,
      gstAmount: p.gstAmount,
      totalPremium: p.totalPremium,
      startDate: p.startDate,
      endDate: p.endDate,
      nextPremiumDue: DateTime(
        p.nextPremiumDue.year,
        p.nextPremiumDue.month + 1,
        p.nextPremiumDue.day,
      ),
      nomineeName: p.nomineeName,
      nomineeRelationship: p.nomineeRelationship,
      nomineeDoB: p.nomineeDoB,
      nomineeMobile: p.nomineeMobile,
      debitAccountId: p.debitAccountId,
      status: p.status,
      benefits: p.benefits,
    );
    notifyListeners();
  }

  // ── Raise a claim ─────────────────────────────────────────────
  InsuranceClaimModel raiseClaim({
    required String policyId,
    required String description,
    required double amount,
  }) {
    final claim = InsuranceClaimModel(
      id: 'CLM${DateTime.now().millisecondsSinceEpoch}',
      policyId: policyId,
      claimNumber: 'CLM#CLM${DateTime.now().millisecondsSinceEpoch % 10000000}',
      description: description,
      claimAmount: amount,
      date: DateTime.now(),
      status: 'In Review',
    );
    _claims.add(claim);
    notifyListeners();
    return claim;
  }
}