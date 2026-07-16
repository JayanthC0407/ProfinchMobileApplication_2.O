import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/data/models/user_session_model.dart';

/// GET /digx-common/user/v1/me/sessions
class SessionRepository {
  Future<List<UserSessionModel>> getActiveSessions() async {
    final response = await ApiClient.instance.get(
      ApiEndpoints.userSessions,
      queryParameters: {'locale': 'en-US'},
    );

    final rawList = response['userSessionDTOList'] ?? [];
    if (rawList is! List) return [];

    final sessions = rawList
        .whereType<Map>()
        .map((e) => UserSessionModel.fromJson(Map<String, dynamic>.from(e)))
        .toList()
      // Most recently active first.
      ..sort((a, b) => b.lastActive.compareTo(a.lastActive));

    return sessions;
  }
}