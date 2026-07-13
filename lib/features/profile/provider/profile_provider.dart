import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/user_model.dart';

class ProfileProvider extends ChangeNotifier {

  UserModel? user;

  void setUser(UserModel currentUser) {
    user = currentUser;
    notifyListeners();
  }

  void updateProfile({
    required String username,
    required String email,
    required String phone,
  }) {

    if (user == null) return;

    user = UserModel(
      id: user!.id,
      username: username,
      email: email,
      password: user!.password,
      phoneNumber: phone,
      panNumber: user!.panNumber,
      profileImage: user!.profileImage,
      accountNumber: user!.accountNumber,
      createdAt: user!.createdAt,
      isKycVerified: user!.isKycVerified,
      primaryAccountId: user!.primaryAccountId,
    );

    notifyListeners();
  }
}