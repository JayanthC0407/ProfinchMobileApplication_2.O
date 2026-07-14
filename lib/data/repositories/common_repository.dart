import 'package:profinch_mobile_application/core/network/api_client.dart';
import 'package:profinch_mobile_application/core/network/api_endpoints.dart';

/// OBDX's core banking system runs on its own "business date"
/// (`branchDateDefinitionDTO.currentDate`), which is entirely independent
/// of the device/server's real wall-clock time — in this sandbox it's
/// frozen at 2022-12-22 regardless of what today's actual date is.
///
/// This matters anywhere a date range or "today" gets sent back to OBDX:
/// using `DateTime.now()` for that will get rejected once it's later than
/// the core's business date (see `DIGX_DDA_051` on the transactions
/// endpoint — "From Date should not be greater the current Date"). Always
/// fetch this and use it as "now" for anything that becomes a request
/// parameter; `DateTime.now()` is still fine for purely local/UI-only
/// concerns (e.g. picker's `firstDate` far in the past).
class CommonRepository {
  DateTime? _cachedCurrentDate;

  /// GET /digx-common/common/v1/currentDate
  ///
  /// Cached for the lifetime of this repository instance since the
  /// business date doesn't change mid-session — avoid re-fetching it on
  /// every screen that needs it. Construct a fresh [CommonRepository] (or
  /// add a manual invalidation if needed) if the app can stay open across
  /// a core banking end-of-day rollover.
  Future<DateTime> getCurrentDate({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCurrentDate != null) {
      return _cachedCurrentDate!;
    }

    final response = await ApiClient.instance.get(ApiEndpoints.currentDate);
    final dto = response['branchDateDefinitionDTO'] as Map<String, dynamic>?;
    final parsed = DateTime.tryParse(dto?['currentDate']?.toString() ?? '');

    // If this ever fails to parse, falling back to the device clock is the
    // safer choice than throwing and blocking the screen — worst case you
    // hit the same DIGX_DDA_051-style validation error downstream, which
    // is already surfaced to the user rather than silently wrong.
    _cachedCurrentDate = parsed ?? DateTime.now();
    return _cachedCurrentDate!;
  }
}