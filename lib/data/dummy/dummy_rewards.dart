import 'package:profinch_mobile_application/data/models/reward_model.dart';

class DummyRewards {
  DummyRewards._();

  static final List<RewardModel> allRewards = [
    RewardModel(
      id: 'RWD001',
      userId: 'USR001',
      title: 'Shopping Cashback',
      description: 'Earned on Amazon purchase',
      points: 32,
      category: RewardCategory.cashback,
      earnedDate: DateTime(2026, 5, 5),
      expiryDate: DateTime(2026, 11, 5),
      isRedeemed: false,
    ),
    RewardModel(
      id: 'RWD002',
      userId: 'USR001',
      title: 'UPI Transfer Reward',
      description: 'Bonus points on UPI payment',
      points: 20,
      category: RewardCategory.milestone,
      earnedDate: DateTime(2026, 5, 8),
      expiryDate: DateTime(2026, 11, 8),
      isRedeemed: false,
    ),
    RewardModel(
      id: 'RWD003',
      userId: 'USR001',
      title: 'Swiggy Voucher',
      description: '₹100 off on next order',
      points: 100,
      category: RewardCategory.voucher,
      earnedDate: DateTime(2026, 4, 20),
      expiryDate: DateTime(2026, 6, 20),
      isRedeemed: true,
    ),
    RewardModel(
      id: 'RWD004',
      userId: 'USR001',
      title: 'Bill Payment Offer',
      description: '5% cashback on electricity bill',
      points: 50,
      category: RewardCategory.offer,
      earnedDate: DateTime(2026, 5, 10),
      expiryDate: DateTime(2026, 7, 10),
      isRedeemed: false,
    ),
  ];

  /// Total available (unredeemed) points
  static int get totalPoints {
    return allRewards
        .where((r) => !r.isRedeemed)
        .fold(0, (sum, r) => sum + r.points);
  }
}
