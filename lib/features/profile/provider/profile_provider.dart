import 'package:flutter/material.dart';
import 'package:profinch_mobile_application/data/models/user_model.dart';
import 'package:profinch_mobile_application/data/models/country_model.dart';
import 'package:profinch_mobile_application/data/models/party_model.dart';
import 'package:profinch_mobile_application/data/models/profile_config_model.dart';
import 'package:profinch_mobile_application/data/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _repository = ProfileRepository();

  UserModel? user;

  bool isLoading = false;

  /// Set if the last [loadProfileDetails] call failed — UI can show a
  /// retry banner instead of silently showing stale/local data.
  String? loadError;

  List<CountryModel> countries = [];
  PartyModel? party;
  ProfileConfigModel? profileConfig;

  /// Fires the three profile-screen calls (country enum, party details,
  /// profile config) in parallel. Call this from `ProfileScreen.initState`
  /// (via a post-frame callback, same pattern as
  /// `AccountProvider.loadAccounts`) so it reloads fresh data every time
  /// the screen opens rather than only once at login.
  Future<void> loadProfileDetails() async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      final bundle = await _repository.loadProfileDetails();
      countries = bundle.countries;
      party = bundle.party;
      profileConfig = bundle.profileConfig;
    } catch (e) {
      loadError = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Resolves a country code (e.g. `IN`) to its display name (`India`)
  /// using the list fetched by [loadProfileDetails]. Falls back to the
  /// raw code if the list hasn't loaded yet or the code isn't found.
  String countryName(String code) {
    if (code.isEmpty) return '';
    try {
      return countries.firstWhere((c) => c.code == code).description;
    } catch (_) {
      return code;
    }
  }

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