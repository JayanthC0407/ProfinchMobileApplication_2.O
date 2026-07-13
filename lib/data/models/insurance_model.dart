enum InsuranceType { health, life, motor, travel, home }

enum InsurancePlan { silver, gold, platinum }

enum InsuranceStatus { active, expired, pending }

class InsuranceModel {
  final String id;
  final String userId;
  final String policyNumber;
  final InsuranceType type;
  final InsurancePlan plan;
  final String planName;
  final String policyHolderName;
  final double coverageAmount;
  final double premiumAmount; // monthly
  final double gstAmount;
  final double totalPremium; // premium + gst
  final DateTime startDate;
  final DateTime endDate;
  final DateTime nextPremiumDue;
  final String nomineeName;
  final String nomineeRelationship;
  final String nomineeDoB;
  final String nomineeMobile;
  final String debitAccountId;
  final InsuranceStatus status;
  final List<String> benefits;

  InsuranceModel({
    required this.id,
    required this.userId,
    required this.policyNumber,
    required this.type,
    required this.plan,
    required this.planName,
    required this.policyHolderName,
    required this.coverageAmount,
    required this.premiumAmount,
    required this.gstAmount,
    required this.totalPremium,
    required this.startDate,
    required this.endDate,
    required this.nextPremiumDue,
    required this.nomineeName,
    required this.nomineeRelationship,
    required this.nomineeDoB,
    required this.nomineeMobile,
    required this.debitAccountId,
    required this.status,
    required this.benefits,
  });
}

class InsuranceClaimModel {
  final String id;
  final String policyId;
  final String claimNumber;
  final String description;
  final double claimAmount;
  final DateTime date;
  final String status; // 'Approved', 'In Review', 'Rejected'

  InsuranceClaimModel({
    required this.id,
    required this.policyId,
    required this.claimNumber,
    required this.description,
    required this.claimAmount,
    required this.date,
    required this.status,
  });
}

// ── Available plan config used by plan-selection screen ──────────
class InsurancePlanConfig {
  final InsurancePlan plan;
  final String name;
  final double coverageAmount;
  final double premiumAmount;

  const InsurancePlanConfig({
    required this.plan,
    required this.name,
    required this.coverageAmount,
    required this.premiumAmount,
  });
}

class InsuranceTypeConfig {
  final InsuranceType type;
  final String name;
  final String subtitle;
  final List<InsurancePlanConfig> plans;
  final List<String> benefits;

  const InsuranceTypeConfig({
    required this.type,
    required this.name,
    required this.subtitle,
    required this.plans,
    required this.benefits,
  });
}