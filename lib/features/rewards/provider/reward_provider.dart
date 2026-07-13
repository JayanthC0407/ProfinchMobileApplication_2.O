import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/dummy/dummy_rewards.dart';
import 'package:profinch_mobile_application/data/models/reward_model.dart';

enum VoucherCategory { shopping, food, travel, entertainment, fuel }

class VoucherModel {
  final String id;
  final String title;
  final String brand;
  final String description;
  final int pointsRequired;
  final String value;          // e.g. "₹100 off"
  final VoucherCategory category;
  final IconData icon;
  final Color color;
  final DateTime expiryDate;
  bool isRedeemed;

  VoucherModel({
    required this.id,
    required this.title,
    required this.brand,
    required this.description,
    required this.pointsRequired,
    required this.value,
    required this.category,
    required this.icon,
    required this.color,
    required this.expiryDate,
    this.isRedeemed = false,
  });
}

class OfferModel {
  final String id;
  final String title;
  final String description;
  final String tag;           // e.g. "5% cashback"
  final Color color;
  final IconData icon;
  final DateTime validTill;

  const OfferModel({
    required this.id,
    required this.title,
    required this.description,
    required this.tag,
    required this.color,
    required this.icon,
    required this.validTill,
  });
}

class RewardsProvider extends ChangeNotifier {

  // ── Points ────────────────────────────────────────────────────
  final List<RewardModel> _rewards = List.from(DummyRewards.allRewards);
  List<RewardModel> get rewards => _rewards;

  int get totalPoints => _rewards
      .where((r) => !r.isRedeemed)
      .fold(0, (sum, r) => sum + r.points);

  int get redeemedPoints => _rewards
      .where((r) => r.isRedeemed)
      .fold(0, (sum, r) => sum + r.points);

  // ── Vouchers ──────────────────────────────────────────────────
  final List<VoucherModel> _vouchers = [
    VoucherModel(
      id: 'VCH001',
      title: 'Amazon Gift Card',
      brand: 'Amazon',
      description: '₹100 off on your next purchase',
      pointsRequired: 100,
      value: '₹100 off',
      category: VoucherCategory.shopping,
      icon: Icons.shopping_bag_outlined,
      color: const Color(0xFFFF9900),
      expiryDate: DateTime(2026, 12, 31),
    ),
    VoucherModel(
      id: 'VCH002',
      title: 'Swiggy Voucher',
      brand: 'Swiggy',
      description: '₹75 off on orders above ₹200',
      pointsRequired: 75,
      value: '₹75 off',
      category: VoucherCategory.food,
      icon: Icons.restaurant_outlined,
      color: const Color(0xFFFC8019),
      expiryDate: DateTime(2026, 9, 30),
    ),
    VoucherModel(
      id: 'VCH003',
      title: 'Zomato Voucher',
      brand: 'Zomato',
      description: '₹50 off on your next order',
      pointsRequired: 50,
      value: '₹50 off',
      category: VoucherCategory.food,
      icon: Icons.fastfood_outlined,
      color: const Color(0xFFE23744),
      expiryDate: DateTime(2026, 8, 31),
    ),
    VoucherModel(
      id: 'VCH004',
      title: 'MakeMyTrip Voucher',
      brand: 'MakeMyTrip',
      description: '₹200 off on flight bookings',
      pointsRequired: 200,
      value: '₹200 off',
      category: VoucherCategory.travel,
      icon: Icons.flight_outlined,
      color: const Color(0xFF0063B1),
      expiryDate: DateTime(2026, 11, 30),
    ),
    VoucherModel(
      id: 'VCH005',
      title: 'BookMyShow',
      brand: 'BookMyShow',
      description: '₹100 off on movie tickets',
      pointsRequired: 100,
      value: '₹100 off',
      category: VoucherCategory.entertainment,
      icon: Icons.movie_outlined,
      color: const Color(0xFFE63946),
      expiryDate: DateTime(2026, 10, 31),
    ),
    VoucherModel(
      id: 'VCH006',
      title: 'HPCL Fuel Card',
      brand: 'HPCL',
      description: '₹50 cashback on fuel',
      pointsRequired: 50,
      value: '₹50 off',
      category: VoucherCategory.fuel,
      icon: Icons.local_gas_station_outlined,
      color: const Color(0xFF2196F3),
      expiryDate: DateTime(2026, 7, 31),
    ),
  ];

  List<VoucherModel> get availableVouchers =>
      _vouchers.where((v) => !v.isRedeemed).toList();

  List<VoucherModel> get redeemedVouchers =>
      _vouchers.where((v) => v.isRedeemed).toList();

  // ── Offers ────────────────────────────────────────────────────
  final List<OfferModel> _offers = [
    OfferModel(
      id: 'OFF001',
      title: '5% Cashback on Shopping',
      description: 'Use ProFinch credit card on Amazon & Flipkart',
      tag: '5% Cashback',
      color: const Color(0xFF0063B1),
      icon: Icons.shopping_cart_outlined,
      validTill: DateTime(2026, 7, 31),
    ),
    OfferModel(
      id: 'OFF002',
      title: '10X Reward Points',
      description: 'Earn 10X points on all UPI payments this weekend',
      tag: '10X Points',
      color: const Color(0xFF7C3AED),
      icon: Icons.bolt_outlined,
      validTill: DateTime(2026, 6, 30),
    ),
    OfferModel(
      id: 'OFF003',
      title: 'Free Movie Ticket',
      description: 'Spend ₹5000+ and get a free BookMyShow ticket',
      tag: 'Free Ticket',
      color: const Color(0xFFE63946),
      icon: Icons.movie_outlined,
      validTill: DateTime(2026, 8, 15),
    ),
    OfferModel(
      id: 'OFF004',
      title: 'Fuel Surcharge Waiver',
      description: 'No fuel surcharge on transactions above ₹500',
      tag: '1% Waiver',
      color: const Color(0xFF0F6E56),
      icon: Icons.local_gas_station_outlined,
      validTill: DateTime(2026, 9, 30),
    ),
  ];

  List<OfferModel> get offers => _offers;

  // ── Redeem voucher ────────────────────────────────────────────
  bool redeemVoucher(String voucherId) {
    final vIdx = _vouchers.indexWhere((v) => v.id == voucherId);
    if (vIdx == -1) return false;

    final voucher = _vouchers[vIdx];
    if (voucher.pointsRequired > totalPoints) return false;
    if (voucher.isRedeemed) return false;

    // Deduct points — mark oldest unredeemed rewards as used
    int pointsToDeduct = voucher.pointsRequired;
    for (int i = 0; i < _rewards.length && pointsToDeduct > 0; i++) {
      if (!_rewards[i].isRedeemed && _rewards[i].points <= pointsToDeduct) {
        pointsToDeduct -= _rewards[i].points;
        _rewards[i] = RewardModel(
          id: _rewards[i].id,
          userId: _rewards[i].userId,
          title: _rewards[i].title,
          description: _rewards[i].description,
          points: _rewards[i].points,
          category: _rewards[i].category,
          earnedDate: _rewards[i].earnedDate,
          expiryDate: _rewards[i].expiryDate,
          isRedeemed: true,
        );
      }
    }

    // Mark voucher as redeemed
    _vouchers[vIdx].isRedeemed = true;

    notifyListeners();
    return true;
  }

  // ── Add points (called by UPI / Wallet / Card transactions) ───
  void addPoints({
    required String title,
    required int points,
    RewardCategory category = RewardCategory.cashback,
  }) {
    _rewards.add(RewardModel(
      id: 'RWD${DateTime.now().millisecondsSinceEpoch}',
      userId: 'USR001',
      title: title,
      description: 'Points earned from transaction',
      points: points,
      category: category,
      earnedDate: DateTime.now(),
      expiryDate: DateTime.now().add(const Duration(days: 180)),
      isRedeemed: false,
    ));
    notifyListeners();
  }
}