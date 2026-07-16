import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/data/models/user_preferences_model.dart';

/// Backs the "primary account" edit flow. In the base app this is a
/// dedicated picker screen that, on open, fires GET userPreferences +
/// GET demandDeposit together, then PUTs the whole (mutated)
/// userPreferences object back on Submit — confirmed against real
/// GET/PUT payloads.
class UserPreferencesRepository {
  Future<UserPreferencesModel> getUserPreferences() async {
    final response = await ApiClient.instance.get(ApiEndpoints.userPreferences);
    return UserPreferencesModel.fromJson(response);
  }

  /// PUTs the full object back — OBDX expects the whole thing round-tripped,
  /// not a partial patch (confirmed from the real request payload, which
  /// carries every field including the ones that didn't change).
  Future<void> updateUserPreferences(UserPreferencesModel preferences) {
    return ApiClient.instance.put(
      ApiEndpoints.userPreferences,
      data: preferences.toJson(),
    );
  }
}
