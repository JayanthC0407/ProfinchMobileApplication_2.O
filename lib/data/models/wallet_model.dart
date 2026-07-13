class WalletModel {
  final String id;
  final String userId;
  final double balance;
  final double dailyLimit;
  final double usedTodayLimit;
  final bool isActive;

  WalletModel({
    required this.id,
    required this.userId,
    required this.balance,
    required this.dailyLimit,
    required this.usedTodayLimit,
    required this.isActive,
  });

  double get remainingDailyLimit => dailyLimit - usedTodayLimit;
}
