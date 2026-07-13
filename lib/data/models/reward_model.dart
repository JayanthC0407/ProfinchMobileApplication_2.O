enum RewardCategory { cashback, voucher, offer, milestone }

class RewardModel {
  final String id;
  final String userId;
  final String title;
  final String description;
  final int points;
  final RewardCategory category;
  final DateTime earnedDate;
  final DateTime? expiryDate;
  final bool isRedeemed;

  RewardModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.points,
    required this.category,
    required this.earnedDate,
    this.expiryDate,
    required this.isRedeemed,
  });
}
