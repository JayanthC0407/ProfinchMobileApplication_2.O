import 'package:flutter/material.dart';

import '../../../data/models/transfer_model.dart';

class TransferProvider extends ChangeNotifier {

  final List<TransferModel> _transfers = [];

  List<TransferModel> get transfers =>
      _transfers;

  List<TransferModel>
      getTransfersByUserId(
    String userId,
  ) {
    return _transfers
        .where(
          (transfer) =>
              transfer.userId ==
              userId,
        )
        .toList();
  }

  void addTransfer(
    TransferModel transfer,
  ) {
    _transfers.add(
      transfer,
    );

    notifyListeners();
  }
}