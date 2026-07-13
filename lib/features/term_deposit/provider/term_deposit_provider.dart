import 'package:flutter/material.dart';

import '../../../data/dummy/dummy_term_deposits.dart';
import '../../../data/models/term_deposit_model.dart';

class TermDepositProvider extends ChangeNotifier {

  final List<TermDepositModel> _deposits =
      List.from(
        DummyTermDeposits.deposits,
      );

  List<TermDepositModel> get deposits =>
      _deposits;

  List<TermDepositModel>
      getDepositsByUserId(
    String userId,
  ) {
    return _deposits
        .where(
          (deposit) =>
              deposit.userId == userId,
        )
        .toList();
  }

  List<TermDepositModel>
      getActiveDeposits(
    String userId,
  ) {
    return _deposits
        .where(
          (deposit) =>
              deposit.userId == userId &&
              deposit.status == 'ACTIVE',
        )
        .toList();
  }
  List<TermDepositModel>
    getRedeemedDeposits(
    String userId,
  ) {
    return _deposits
        .where(
          (deposit) =>
              deposit.userId ==
                  userId &&
              deposit.status ==
                  'REDEEMED',
        )
        .toList();
  }

  double getTotalInvestment(
    String userId,
  ) {
    return getActiveDeposits(userId)
        .fold(
      0,
      (sum, deposit) =>
          sum +
          deposit.principalAmount,
    );
  }

  void addDeposit(
    TermDepositModel deposit,
  ) {
    _deposits.add(deposit);

    notifyListeners();
  }

  void redeemDeposit(
    String depositId,
  ) {
    final index =
        _deposits.indexWhere(
      (deposit) =>
          deposit.id == depositId,
    );

    if (index == -1) return;

    _deposits[index] =
        _deposits[index].copyWith(
      status: 'REDEEMED',
    );

    notifyListeners();
  }
}