import '../../utils/cast.dart';

/// Aggregated watch time statistics for a library section over a time period.
///
/// One entry per time window returned by `get_library_watch_time_stats`.
class LibraryWatchTimeStat {
  /// Number of days this stat covers (e.g. 1, 7, 30, or 0 for all-time).
  final int? queryDays;

  /// Total number of plays in this time window.
  final int? totalPlays;

  /// Total watch time in seconds in this time window.
  final int? totalTime;

  const LibraryWatchTimeStat({
    this.queryDays,
    this.totalPlays,
    this.totalTime,
  });

  /// Parses a [LibraryWatchTimeStat] from a Tautulli API JSON map.
  factory LibraryWatchTimeStat.fromJson(Map<String, dynamic> json) {
    return LibraryWatchTimeStat(
      queryDays: Cast.castToInt(json['query_days']),
      totalPlays: Cast.castToInt(json['total_plays']),
      totalTime: Cast.castToInt(json['total_time']),
    );
  }
}
