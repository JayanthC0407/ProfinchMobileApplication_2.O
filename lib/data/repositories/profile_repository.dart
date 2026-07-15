import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';
import 'package:profinch_mobile_application/data/models/country_model.dart';
import 'package:profinch_mobile_application/data/models/party_model.dart';
import 'package:profinch_mobile_application/data/models/profile_config_model.dart';

/// Wires up the three calls the browser network tab shows firing together
/// (in parallel, not sequentially) when the Profile screen opens:
///   GET /digx-retail/origination/v1/enumerations/country
///   GET /digx-common/user/v1/me/party
///   GET /digx-common/user/v1/profileConfig
class ProfileRepository {
  Future<ProfileBundle> loadProfileDetails() async {
    final results = await Future.wait([
      ApiClient.instance.get(ApiEndpoints.countryEnum),
      ApiClient.instance.get(ApiEndpoints.partyDetails),
      ApiClient.instance.get(ApiEndpoints.profileConfig),
    ]);

    return ProfileBundle(
      countries: CountryModel.listFromResponse(results[0]),
      party: PartyModel.fromJson(results[1]),
      profileConfig: ProfileConfigModel.fromJson(results[2]),
    );
  }
}

class ProfileBundle {
  final List<CountryModel> countries;
  final PartyModel party;
  final ProfileConfigModel profileConfig;

  ProfileBundle({
    required this.countries,
    required this.party,
    required this.profileConfig,
  });
}
