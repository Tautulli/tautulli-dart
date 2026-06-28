import '../../utils/cast.dart';

/// Aggregated watch time statistics for a user over a time period.
///
/// One entry per time window returned by `get_user_watch_time_stats`.
class UserWatchTimeStat {
  /// Number of days this stat covers (e.g. 1, 7, 30, or 0 for all-time).
  final int? queryDays;

  /// Total number of plays in this time window.
  final int? totalPlays;

  /// Total watch time in seconds in this time window.
  final int? totalTime;

  const UserWatchTimeStat({this.queryDays, this.totalPlays, this.totalTime});

  /// Parses a [UserWatchTimeStat] from a Tautulli API JSON map.
  factory UserWatchTimeStat.fromJson(Map<String, dynamic> json) {
    return UserWatchTimeStat(
      queryDays: Cast.castToInt(json['query_days']),
      totalPlays: Cast.castToInt(json['total_plays']),
      totalTime: Cast.castToInt(json['total_time']),
    );
  }
}
