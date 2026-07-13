import 'package:profinch_mobile_application/data/models/wallet_model.dart';

class DummyWallet {
  DummyWallet._();

  static final WalletModel wallet = WalletModel(
    id: 'WLT001',
    userId: 'USR001',
    balance: 3250.00,
    dailyLimit: 10000.00,
    usedTodayLimit: 1500.00,
    isActive: true,
  );
}
