import 'package:flutter/material.dart';
import '../../../data/dummy/dummy_beneficiaries.dart';
import '../../../data/models/beneficiary_model.dart';

class BeneficiaryProvider extends ChangeNotifier {
  final List<BeneficiaryModel> _beneficiaries =
      List.from(DummyBeneficiaries.beneficiaries);

  List<BeneficiaryModel> getBeneficiariesByUserId(String userId) {
    return _beneficiaries.where((b) => b.userId == userId).toList();
  }

  BeneficiaryModel? getById(String id) {
    try {
      return _beneficiaries.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  void addBeneficiary(BeneficiaryModel beneficiary) {
    _beneficiaries.add(beneficiary);
    notifyListeners();
  }

  /// Edit mutable fields — resets addedAt to now so the cooling period
  /// restarts. Preserves id, userId, and beneficiaryType.
  void editBeneficiary(String id, {
    required String nickname,
    required String accountNumber,
    required String bankName,
    required String ifscCode,
    String? ibanNumber,
    String? swiftCode,
    String? country,
  }) {
    final index = _beneficiaries.indexWhere((b) => b.id == id);
    if (index == -1) return;

    _beneficiaries[index] = _beneficiaries[index].copyWith(
      nickname: nickname,
      accountNumber: accountNumber,
      bankName: bankName,
      ifscCode: ifscCode,
      ibanNumber: ibanNumber,
      swiftCode: swiftCode,
      country: country,
      addedAt: DateTime.now(), // reset — cooling restarts after every edit
    );
    notifyListeners();
  }

  void removeBeneficiary(String id) {
    _beneficiaries.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  /// Whether the cooling period has elapsed for this beneficiary.
  bool canTransfer(String id) {
    final b = getById(id);
    return b?.isTransferAllowed ?? false;
  }
}